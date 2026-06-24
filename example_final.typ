#import "final.typ": conf, resumen, dedicatoria, agradecimientos, start-doc, end-doc, capitulo, apendice
#import "metadata.typ": example-metadata

#show: conf.with(metadata: example-metadata)

#resumen(metadata: example-metadata)[

 El siguiente documento aborda la construcción y experimentación de un indice basado en la compresión del arreglo diferencial de sufijos DSA mediante Repair, utilizando metadata en los nodos no-terminales y terminales, de forma que dado un intervalo [sp,ep] en el arreglo de sufijos SA, encontrar min(SA[sp..ep]) (la ocurrencia más a la izquierda del texto) y max(SA[sp..ep]) (la ocurrencia más a la derecha en el texto), sin tener que leer todas las ep - sp +1 posiciones del SA.

El DSA de textos repetitivos (como colecciones de genomas) tiene muchos valores repetidos, por esta razón se comprime bien usando Repair, un algoritmo que reemplaza pares frecuentes por nuevos símbolos, produciendo una gramática. Adaptando las ideas,lemas y algoritmos expuestos en el paper \textit{Fully-Functional Trees and Optimal Text Searching in BWT-runs Bounded Space~\cite{gagie2019jacm}} , se construyó el indice basado en el DSA comprimido con Repair. 

Se comparará contra otros indices (en particular el sr-index) para ver su desempeño en términos de tiempo y espacio. donde todo esto será representado mediante gráficos y tablas comparativas. 
]

#dedicatoria[
    Para mis padres.
]

#agradecimientos[
    #lorem(150)
    
    #lorem(100)
    
    #lorem(100)
]

#show: start-doc

#capitulo(title: "Introducción")[
    == Contexto y problemática

    El estudio de la evolución de las especies es uno de los objetivos principales de la bioinformatica, una disciplina que combina ciencias informáticas para almacenar y analizar grandes volúmenes de datos biológicos como secuencias de ADN, aminoácidos y demás moléculas biológicas. Un gen es un segmento de ADN, y un genoma es la suma total de toda la información genética de un organismo. Teniendo en cuenta la gran cantidad de especies que existe y que ademas se tienen una enorme cantidad de colecciones de genomas, es desafiante y complejo al mismo tiempo contestar preguntas como: ¿Donde aparece una secuencia particular dentro de un genoma?, ¿Cuántas veces aparece una secuencia en un conjunto de genomas?.

    Un árbol filogenético es una estructura que permite representar las relaciones de parentesco entre especies y que muestra los cambios en los genes con el pasar del tiempo. Una colección de genomas se organiza según esta estructura y la problemática principal surge a partir de esto: se busca una secuencia de ADN o un gen en esta colección, y se quiere identificar todas sus ocurrencias, mapearlas a los genomas que las contienen, y calcular el ancestro común mas bajo (Lowest Common Ancestor LCA) de esos nodos, el cual, es un candidato para la especie donde comenzó a expresarse este gen. Lo difícil radica en que las secuencias no suelen encontrase exactamente debido a mutaciones, inserciones o recombinaciones. Por lo tanto, la búsqueda se basa en encontrar las coincidencias máximas, las cuales se representan con una estructura llamada Maximal Exact Matches (MEMs). Calcular MEMs requiere estructuras de datos como los Suffix Array (SA) , FM-indexes, entre otros que serán definidos mas adelante. 

    Una gramática libre de contexto es un conjunto de reglas de reemplazo. Tiene dos tipos de símbolos: los terminales (valores finales) y los no-terminales (nombres que representan patrones). Cada regla dice los símbolos que reemplazan cierto no-terminal. 
    
    Partiendo del símbolo S, se aplican las reglas hasta que no queden no-terminales, y lo que queda es la cadena que la gramática genera. La compresión por gramáticas es un caso particular donde la gramática genera exactamente una cadena (la secuencia original S). 

    Esto se logra restringiendo la gramática para que cada no-terminal tenga exactamente una regla, y que no haya ciclos. Cada no-terminal captura un patrón repetido de la secuencia: en vez de almacenar todas sus ocurrencias, se almacena una sola regla que lo define, y se referencia por su nombre. El tamaño de la gramática (la suma de símbolos en los lados derechos de todas las reglas) es la medida de compresión, y para secuencias altamente repetitivas puede ser dramáticamente menor que el largo original.


    Se ha demostrado que la compresión por gramáticas es una herramienta muy
    efectiva para representar secuencias diferenciales altamente repetitivas, como el arreglo diferencial de LCP (Longest Common Prefix: almacena, para cada par de sufijos consecutivos en el orden lexicográfico del arreglo de sufijos, cuántos caracteres comparten al inicio), peremitiendo responder consultas de rango y de prefijos a partir de metadatos
    almacenados en cada no terminal de la gramática. 
    Este enfoque sugiere que, si en lugar de
    comprimir LCP se comprime directamente el DSA, y si a cada regla se le asocia la suma
    de su expansión junto con el mínimo y máximo de sumas parciales es posible reconstruir
    implícitamente la información relevante del SA y responder consultas de tipo RMQ sobre SA
    sin necesidad de mantenerlo explícito. De esta forma, el costo de calcular min(SA[sp..ep]) y
    max(SA[sp..ep]) se traslada a operaciones sobre la gramática (en tiempo sublineal o logarítmico respecto al tamaño del texto) mientras que el espacio ocupado depende del tamaño de
    la gramática y no del número total de sufijos. Esta combinación de compresión y soporte de
    consultas de rango es precisamente lo que hace atractivo el uso de gramáticas sobre el DSA
    como base para el indice propuesto en esta memoria.

    == Baseline

    El baseline con el cual se compara la propuesta es el sr-index. Este indice resuelve el mismo problema pero de manera diferente. La implementación se puede encontrar en https://github.com/duscob/sr-index la cual fue hecha por Dustin Cobas.

    == Contribución de la memoria

    + *Comprimir el DSA con Repair*: Almacenar en cada no-terminal seis campos: longitud l(X), suma total d(X), mínimo de sumas parciales $m_{min}(X)$, posición del mínimo $p_{min}(X)$, máximo de sumas parciales $m_{max}(X)$, y posición del máximo $p_{max}(X).$
    + *Responder min(SA[sp..ep]) y max(SA[sp..ep]) en tiempo o(h)*: Siendo h la altura de la gramática, descendemos recursivamente combinando la metadata, sin necesidad de enumerar las ocurrencias.
    + *Integrar esta estructura en el pipeline de clasificación taxonómica*: Los intervalos [sp, ep] producidos por el FM-index para cada MEM se consultan sobre la gramática del DSA para obtener la primera y última posición en el texto.
]

#capitulo(title: "Conceptos Básicos")[
   == Arbol filogenetico

        Un árbol filogenético es un árbol con raíz donde las hojas representan genomas y los
    nodos internos representan ancestros comunes hipotéticos. Las hojas tienen un orden de
    izquierda a derecha el cual cumple la siguiente propiedad: si dos hojas $h_1$ y $h_2$ están en el
    mismo subarbol de un nodo interno v, entonces todas las hojas entre $h_1$ y $h_2$ en el orden de
    izquierda a derecha también están en el subárbol de v. Esta propiedad forma la base de lo que
    se se quiere lograr: si un patrón P aparecen en los genomas de las hojas $h_1$ y $h_2$, y el LCA de
    $h_1$ y $h_2$ es v, entonces sabemos que P podría aparecer en cualquier genoma del subárbol de v.
    Al concatenar los genomas en el orden de las hojas, las ocurrencias de P en la concatenación
    forman un rango contiguo de posiciones, y los genomas que contienen esas posiciones forman
    un rango contiguo de hojas del árbol. Por lo tanto, basta con encontrar la primera y la última
    ocurrencia (la de más a la izquierda y la de más a la derecha en la concatenación) para
    determinar el subábol completo. Dados $h_1$, $h_2$,...,$h_d$ las hojas de árbol en orden (diremos
    solamente en orden desde ahora dando por hecho que están de izquierda a derecha), con
    genomas $G_1$, $G_2$,...,$G_d$ respectivamente, entonces la concatenación esta definida como sigue:
    T[1...n]= $G_1 $ $G_2 $...$G_d $, donde \$ es un carácter separador y que es lexicograficamente menor
    que cualquier caracter del alfabeto que se define mediante los genomas del árbol

   == Bitvector B

    Se define el bitvector B[1..n] donde B[j]=1 si y solo si T[j]=$\$$. A partir de esta arreglo se puede definir la opeción B.rank(j), la cual cuenta el numero de 1s en B[1..j]. Esto dice a qué genoma pertenece la posición j.

    #pagebreak()
   == Arreglo de sufijos SA

    El Suffix Array SA[1..n] es una permutación de {1,2,...,n} tal que:

    T[SA[1]] $<$ T[SA[2]] $<$ ...$<$ T[SA[n]]

    en orden lexicográfico. Es decir, SA[i ] es la posición de inicio del i-esimo sufijo en orden lexicográfico. T[j..] denota el sufijo de T que empieza en la posición j, osea, T[j],T[j+1],...,T[n]. En palabras simples, es un arreglo que ordena todos los sufijos de la concatenación en orden lexicográfico. 
   == Transformada de Burrows-Wheeler BWT

    La transformada de Burrows-Wheeler BWT de T es una cadena BWT[1..n] definida como:

    BWT[i] = T[SA[i]-1] si SA[i] $>$1

    BWT[i] = T[n] si SA[i] = 1

    BWT[i] es el carácter que precede inmediatamente al i-ésimo sufijo en orden lexicográfico. La BWT es una permutación de los caracteres de T y la transformación es reversible, es decir, se puede reconstruir T a partir de BWT. Su propiedad clave es que tiende a agrupar caracteres iguales en posiciones consecutivas, lo que facilita la compresión. 

    Una run de la BWT es una subsecuencia maximal de posiciones consecutivas BWT[i..j] donde todos los caracteres son iguales. El numero de runs de la BWT se denota por r. Es una medida de la repetitividad del texto: textos altamente repetitivos tienen un numero de r mucho menor que n (el largo del texto). El numero r juega un rol fundamental dado que  como demostraron Gagie et al.(2020), las runs de la BWT inducen repeticiones en el arreglo diferencial de sufijos (DSA), lo que permite comprimir el DSA con una gramatica de tamaño proporcional a r.

   == Run-Length FM-index

   El FM-index es un indice comprimido que permite buscar patrones en T sin alamacenar T explicitamente, y se basa en en la BWT. El Run-Length FM-index es una variante del F-index, diseñada para textos repetitivos. Usa el hecho de que la BWT de un texto repetitivo tiene pocas runs: alcmacena la BWT de forma compacta representando cada run por su carácter y su longitud. 

   == Arreglo diferencial de sufijos DSA
   
   == Compresión gramatical Repair
   
   == RMQ, PSV y NSV
    #figure(
        table(
            columns: 3,
            "Campo 1", "Campo 2", "Num", 
            "Valor 1a", "Valor 2a", "3",
            "Valor 1b", "Valor 2b", "3",
        ),
        caption: "Tabla 1",
    )

    #figure(
        table(
            columns: 3,
            "Campo 1", "Campo 2", "Num",
            "Valor 1a", "Valor 2a", "3",
            "Valor 1b", "Valor 2b", "3",
        ),
        caption: "Tabla 2",
    )
    
    #lorem(100)
]

#capitulo(title: "Estado del arte")[
    == Fully-Functional Trees and Optimal Text Searching in BWT-runs Bounded Space

    == Taxonomic classification with maximal exact matches in katka kernels and minimizers digests

    == Fast and small subsampled r-indexes.
    
    #lorem(50) @CorlessJK97 @Turing38

    #figure(
        image("imagenes/institucion/fcfm.svg", width: 20%),
        caption: "Logo de la facultad",
    )
    
    #lorem(100)
    @NewmanT42
]

#capitulo(title: "Compresión del arreglo diferencial de sufijos")[
   
    == Definición de la metadata
 
    == Calculo de la metadata 

    == Complejidad del calculo de la metadata 

    == Estructuras auxiliares

    == Algoritmo de consulta

    == Ejemplo completo 

    == Integración con el pipeline
    
    == Implementación
    #lorem(100)
    @NewmanT42
]

#capitulo(title: "Experimentación")[
   
    == Definición de la metadata
 
    
    #lorem(100)
    @NewmanT42
]

#capitulo(title: "Conclusión")[
    #lorem(100)
    
    #lorem(100)
    
    #lorem(100)
]

#show: end-doc

#apendice(title: "Anexo")[
    #lorem(100)
    
    #lorem(100)
    
    #lorem(100)
]