#import "final.typ": conf, resumen, dedicatoria, agradecimientos, start-doc, end-doc, capitulo, apendice

#import "metadata.typ": example-metadata

#show: conf.with(metadata: example-metadata)
#import "@preview/ctheorems:1.1.3": *
#show: thmrules.with(qed-symbol: $square$)
#set heading(numbering: "1.1.")

#let theorema = thmbox("teorema", "Teorema")

#let corollary = thmplain(
  "corollary",
  "Corollary",
  base: "teorema",
  titlefmt: strong
)
#let definition = thmenv(
  "definición",
  "heading",
  none,
  (name, number, body, color: black) => {
    let title = [*Definición #number:*]
    
    block(
      stroke: (left: 1.5pt + black, bottom: none, top: none, right: none),
      inset: (left: 0.75em, top: 0.4em, bottom: 0.4em),
      width: 100%,
      fill: luma(97.9%),
      if body == [] {
        block(width: 100%)[
          #align(center, name)
          #place(left + horizon, title)
        ]
      } else {
        [#title #name \ #body]
      }
    )
  }
)

#let example = thmplain("example", "Example").with(numbering: none)
#let proof = thmproof("proof", "Proof")
#let property = thmenv(
  "propiedad",
  "heading",
  none,
  (name, number, body, color: black) => {
    let title = [*Propiedad #number:*]
    
    block(
      stroke: (left: 1.5pt + black, bottom: none, top: none, right: none),
      inset: (left: 0.75em, top: 0.4em, bottom: 0.4em),
      width: 100%,
      fill: luma(97.9%),
      if body == [] {
        block(width: 100%)[
          #align(center, name)
          #place(left + horizon, title)
        ]
      } else {
        [#title #name \ #body]
      }
    )
  }
)

#let metadata_thm = thmenv(
  "metadata",
  "heading",
  none,
  (name, number, body, color: black) => {
    let title = if name == [] or name == "" {
      [*Metadata #number.*]
    } else {
      [*Metadata #number.* (#name)]
    }
    
    block(
      stroke: 0.8pt + black,
      inset: (x: 1em, y: 0.75em),
      width: 100%,
      radius: 0pt,
      [#title #body]
    )
  }
)
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
   #pagebreak()
   == Arreglo diferencial de sufijos DSA

   El Arreglo diferencial de sufijos se define de la siguiente manera: 

    DAS[1] = SA[1]

    DSA[p] = SA[p] - SA[p-1] para todo p$\geq$2

    Es decir, DSA almacena las diferencias entre valores consecutivos del arreglo de sufijos. Los valores del SA son enteros con signo, que pueden ser positivos o negativos.

    El arreglo de sufijos original que puede reconstruir a partir del DSA mediante sumas parciales: para cualquier posición de referencia q$<$p:
     
 
       #property($ S A [p]= S A [q] + sum_(j=q+1)^p D S A[j]  $)[]

   Esta propiedad es bastante directa y se verá mas adelante.
   
   == Compresión gramatical Repair

   Repair es un algoritmo de compresión gramatical que transforma una secuencia de símbolos en una gramática libre de contexto que genera unicamente esa secuencia. Funciona iterativamente: en cada paso identifica el par de simbolos adyacentes que aparece con mayor frecuencia en la secuencia actual, crea un nuevo no-terminal que lo representa, reemplaza todas las ocurrencias de ese par por el nuevo no-terminal, y repite hasta que no quede ningún par con frecuencia mayor que uno. El resultado es un conjunto de reglas donde cada regla tiene exactamente dos símbolos en el lado derecho (X -$>$ $Y_{1}Y_{2}$), mas una secuencia comprimida (la regla del símbolo inicial) que contiene los símbolos que no fueron reemplazados.

    En el contexto de este trabajo, RePair se aplica sobre el arreglo diferencial de sufijos DSA. La repetitividad del DSA  hace que muchos pares de valores adyacentes se repitan a lo largo de la secuencia, lo que permite a RePair capturarlos jerárquicamente: primero los pares más frecuentes de valores originales, luego pares de no-terminales que representan patrones cada vez más largos. La gramática resultante tiene un tamaño dramáticamente menor que la secuencia original para colecciones genómicas repetitivas, y su estructura de árbol binario (cada no-terminal tiene exactamente dos hijos) permite almacenar metadata agregada en cada nodo y responder consultas por descenso recursivo sin descomprimir.
   #pagebreak()
   == RMQ, PSV y NSV
  
  - * RMQ (Range Minimum Query)*: Dado un arreglo A[1..n] y un rango [p,q], 
        RMQ(p,q) devuelve la posición del valor mínimo en A[p..q]. 
        Es decir, RMQ(p,q) = $a r g m i n_{p\leq k \leq q} A[k]$. 
        Dado un preprocesamiento en o(n), se puede responder cualquier 
        consulta RMQ en o(1) usando estructuras sucintas.  

  
  - *PSV (Previous Smaller Value)* : Dado un arreglo A[1..n] y una posición p, PSV(p) devuelve 
        la mayor posición q < p tal que A[q] > A[p]. Es decir, busca hacia la izquierda la
        posición mas cercana donde el valor del arreglo es estrictamente menor que el valor actual.
  
  - *NSV (Next Smaller Value)*: Dado un arreglo A[1..n] y una posición p, NSV(p) devuelve la menor
        posición q > p tal que A[p]>A[q]. Es decir, busca hacia la derecha la posición mas cercana
        donde el valor del arreglo es estrictamente menor que el valor actual.

   
]

#capitulo(title: "Estado del arte")[
    == Fully-Functional Trees and Optimal Text Searching in BWT-runs Bounded Space

        Este paper (que a partir de ahora llamaremos Jacm19) resuelve como indexar textos alta
        mente repetitivos en espacio proporcional a r, manteniendo las operaciones eficientes. Antes
        de este paper, existía el Run-Length FM-index que podía contar ocurrencias de un patrón
        en O(r) espacio, pero no podía localizar las posiciones de esas ocurrencias eficientemente sin
        agregar O(n/s) espacio extra para muestreo del suffix array. Es decir, o usabas poco espacio
        pero localizabas lento, o localizabas rápido pero el espacio ya no dependía solo de r. El paper
        presenta el r-index junto con los siguiente resultados, cada uno usando mas espacio a cambio
        de mas funcionalidad:

            + *Locate en o(r) de espacio*: Muestran como localizar las occ ocurrencias en tiempo 
               o(occ $dot$ $l o g dot l o g n$) usando solo o(r) palabras. La clave esta en la función φ : si se conoce
                SA[p], se puede puede obtener SA[p-1] y SA[p+1] en o(log log n), usando solo o(r) datos
                almacenados en las fronteras de las runs de la BWT. Entonces, durante el backward
                search siempre mantiene se mantiene al menos un valor de SA[p] conocido dentro del
                rango actual, y se recorre desde ahí para encontrar los demás.

            + *Count optimo en o(r log log n) de espacio*: Subiendo el espacio, se logra contar en tiempo
               optimo o(m) y localizar en tiempo optimo o(m+occ)

            + *Acceso al SA en o(r log(n/r)) de espacio*: Se muestra como acceder a cualquier celda 
                SA[p] en tiempo o(log(n/r)) usando o(rlog(n/r)) de espacio. Aquí es donde aparece
                el DSA y la demostración de que las runs de la BWT inducen repeticiones en él. Se
                construye un Block Tree sobre el DSA que explota estas repeticiones.
            
            + *Árbol de sufijos comprimido completo en o(r log(n/r)) de espacio*: Usando el mismo 
                espacio o(r log(n/r)), se implementa un árbol de sufijos que contiene todas las 
                operaciones necesarias de navegación en tiempo o(log(n/r)). Para esto, se requiere 
                soportar RMQ, PSV y NSV sobre el LCP, y se hace construyendo una gramatica sobre el 
                DLCP con metadata en cada no terminal.

      El paper presenta algunos puntos que son parte escencial de la propuesta de esta memoria:

      + *Repetitividad del DSA* El paper demuestra que si BWT[p-1] = BWT[p] (misma run), 
        entonces DSA[LF(p)] = DSA[p]. Esto significa que el DSA hereda la estructura repetitiva de la BWT. Cualquier
        bloque del DSA dentro de una run tiene una copia en otro lugar, y hay solo O(r) ”puntos
        de frontera”necesarios para cubrir todas las copias.Esta es la justificación teórica de que
        comprimir el DSA con RePair produciría una gramática pequeña. Sin este resultado, no
        se tendría garantía de que la gramática del DSA fuera compacta. 
      + *Gramatica sobre un array diferencial con metadata (sección 6.3) *: Para sopor
        tar RMQ sobre el LCP, el paper construye una gramatica sobre el DLCP y almacena
        en cada no-terminal X los valores l(X), d(X), m(X), p(X): longitud, suma total, mini
        mo de sumas parciales y posición del minimo. Luego muestra como descender por la
        gramatica para responder RMQ en o(log(n/r)). Esto es exactamente lo que se hace en
        esta memoria, pero aplicado al DSA y extendiendo la metadata.

      + *Algoritmo de descenso recursivo*: El paper describe quepara una consulta RMQ(p,q)
        sobre el LCP, se descompone el rango en 3 partes: izquierda, símbolos centrales com
        plejos y derecha. Se resuelve la parte central en o(1) con una estructura RMQ sucinta
        sobre una estructura auxiliar M, y se resuelven las partes laterales descendiendo recur
        sivamente por la gramática.
      + *Estructuras auxiliares*:  Los arrays L (longitudes acumuladas), A (diferencias acumu
        ladas), M (minimos por simbolo) y la estructura RMQ sucinta sobre M.
#pagebreak()
    == Taxonomic classification with maximal exact matches in katka kernels and minimizers digests
      
       Este trabajo (que llamaremos Sea24) [3], aborda como clasificar un read de ADN (de
        terminar de qué organismo proviene) usando una colección de genomas organizados en un
        árbol filogenético. Aquí es donde se propone usar MEMs en vez de k-mers (estructura que
        funciona pero no en todos los casos, por ejemplo, bases de datos de distinto tamaño, arboles
        desbalanceados). Lo mas valioso de este paper en el contexto de esta memoria es lo siguiente:

        *Pipeline MEM para clasificación taxónomica*  

        + Concatenar los genomas en orden de hojas del árbol filogenético, separados por \$

        + Construir un FM-index aumentado sobre la concatenación (con soporte para access, rank y select sobre la BWT; range-minimum y range-maximum sobre el SA; RMQ, PSV y NSV sobre el LCP; y rank sobre un bitvector B de separadores)

        + Para cada MEM  de un read, encontrar su intervalo [sp,ep] para encontrar la primera y última posición en el texto.}

        + Obtener min(SA[sp..ep]) y max(SA[sp..ep]) para encontrar la primera y última posición en el texto

        + Usar B.rank para determinar en qué genomas están esas posiciones

        + Calcular el LCA de esos genomas en el árbol filogénetico

        + Clasificar el read basándose en el MEM más largo. 

    Es decir, Sea24 define exactamente el problema a resolver: dado un intervalo [sp, ep] del SA
    (producido por el backward search para un MEM), calcular min(SA[sp..ep]) y max(SA[sp..ep])
    para determinar el primer y último genoma. Se deja claro también que lo único que se nece
    sita del suffix array son dos valores por MEM: el mínimo y el máximo. No se necesitan todas
    las ocurrencias, no se necesita el SA completo, no se necesita navegar el suffix tree. Solo min
    y max.  

  #pagebreak()  
    == Fast and small subsampled r-indexes.
    
      Este paper (talg25) [2]presenta el baseline con el que se compararía el indice propuesto en
esta memoria. La versión original del r-index requería estructuras adicionales para la recu
peración eficiente de posiciones en el arreglo de sufijos, así como mecanismos complejos para
extender los valores muestreados a posiciones vecinas. Además, aunque su espacio teórico era
O(r), las implementaciones reales arrastraban constantes y sobrecargas que reducían su com
petitividad práctica frente a índices no repetitivos como el FM-index altamente optimizado.
El sr-index es una variante practica del r-index que introduce mejoras concretas tanto en es
pacio como en tiempo. El objetivo principal del sr-index es optimizar el diseño del muestreo
del arreglo de sufijos (SA-sampling), reduciendo la distancia entre muestras y simplificando la
navegación necesaria para recuperar SA[i], todo ello manteniendo un espacio proporcional a
r. El sr-index también introduce mejoras en la representación de las estructuras de búsqueda
de predecesor utilizadas para soportar la variante run-aware del backward search. El diseño
liviano de estas estructuras, junto con el muestreo adicional, genera un índice que, en la prác
tica, es más pequeño que el r-index original y considerablemente más rápido en la operación
de localización. Los experimentos presentados en el paper muestran que el sr-index mantiene
la compactividad del r-index pero supera significativamente su desempeño en términos de
tiempo de construcción, búsqueda y recuperación de posiciones.

Al igual que el r-index, el sr-index puede recuperar el intervalo SA[sp..ep] donde se en
cuentran las ocurrencias de un patrón, pero no permite obtener directamente valores como
min(SA[sp..ep]) o max(SA[sp..ep]), esenciales para la detección de maximal exact matches
(MEMs) y el cálculo de ancestros comunes más bajos (LCA) en colecciones filogenéticas.
Incluso con el submuestreo, sigue siendo necesario extender los valores muestreados del SA
a posiciones vecinas mediante iteraciones repetidas de ϕ, lo que introduce un costo adicional
y carece de soporte nativo para RMQ sobre SA.

El sr-index representa así una evolución importante del r-index, orientada a su uso práctico
en entornos donde se requiere un equilibrio entre compresión extrema y eficiencia operacio
nal. Sin embargo, tanto el r-index como su variante sr-index siguen basándose exclusivamente
en la repetición observada en la BWT y en técnicas de muestreo, sin explotar otras formas
de estructura repetitiva más adecuadas para soportar consultas de rango sobre el arreglo de
sufijos.

]

#capitulo(title: "Compresión del arreglo diferencial de sufijos")[
    Dada la definición de arreglo diferencial de sufijos, se puede hacer la siguiente deducción:

    $ S A [p] = S A [p-1] + D S A [p] $  

    Aplicando una sumatoria a ambos lados de la igualdad para q < p:
    
     $ sum_(j=q+1)^p S A[j] - S A [j-1] = sum_(j=q+1)^p D S A[j]  $

    El lado izquierdo corresponde a una sumatoria telescopica, por lo tanto: 

     $ S A [p] = S A [q]+ sum_(j=q+1)^p D S A[j]  $

     Esta igualdad corresponde a la propiedad 2.6.1 mostrada en el capitulo 2. Ahora, dado un rango [sp..ep], queremos calcular min(SA[sp],SA[sp+1],...,SA[ep]). Definimos la suma parcial k-ésima como:

     #definition(grid(
  columns: (auto, 1fr, auto),
  align: horizon,
  [],
  $ P S(k) = sum_(j=s p)^(s p + k -1) D S A[j] $,
  [para $1 <= k < e p-s p +1$]
))[] 

    #pagebreak()

    Por lo tanto:

    $ S A[s p +k −1] = S A[s p−1]+P S(k) $

    Teniendo en cuenta que SA[sp-1] es una constante (no depende de k), el valor de k que minimiza SA[sp+k-1] es el mismo que minimiza PS(k):

    $ m i n (S A [s p ..e p]) = S A [s p - 1] + m i n _(1<=k<=e p-s p +1) P S(k) $

    $ m a x (S A [s p ..e p]) = S A [s p - 1] + m a x _(1<=k<=e p-s p +1) P S(k) $

    Para calcular el mínimo/máximo de las sumas parciales, no se necesita descomprimir el DSA: Usaremos metadata en la gramática libre de contexto del arreglo, para así obtener lo que se requiere.

    La justificación y la idea de hacer esto nace del trabajo realizado por Travis Gagie, Gonzalo
    Navarro y Nicola Prezza el 2019 llamado ”Fully-Functional Suffix Trees and Optimal Text
    Searching in BWT-runs Bounded Space”. Por un lado, se muestra la repetitividad del DSA
    gracias a los lemas 5.2 y 5.3. El DSA puede representarse con una gramática de tamaño
    O(r log (n/r)), y esto es la justificación teórica de que comprimir el DSA con una gramática
    tiene sentido. Sin esta propiedad, no habría garantía de que la gramática fuera pequeña.
    Gracias a esta, confirmamos que para textos repetitivos (r<< n), la gramática será mucho
    menor que el DSA original. Por otro lado, la idea de almacenar metadata en no-terminales
    de una gramática también se obtiene de este este trabajo. Jacm19 construye una gramática
    libre de contexto sobre una estructura de datos llamada DLCP, y almacena en cada nodo
    terminar X los valores l(X), d(X), m(X), p(X). Luego muestra como resolver RMQ, PSV, y
    NSV sobre el LCP descendiendo por la gramática en tiempo O(log(n/r)). Esto se usará pero
    aplicado en el DSA para responder RangeMin y RangeMax sobre el SA. Es decir, se usará
    metadata y también el mismo tipo de algoritmo de descenso recursivo por la gramática,
    pero las diferencias son: Se usa DSA, RangeMin y RangeMax sobre SA (para encontrar
    primera y última ocurrencia de MEMs) y también se requiere tanto mínimo como máximo.
    También se adapatará el algoritmo de descenso presentado en la sección 6.3, que es un
    procedimiento para responder RMQ(p,q) sobre el LCP usando la gramática del DLCP. Los
    pasos son esencialmente los mismos:

    + Localizar qué símbolos de la secuencia inicial de la gramática cubren el rango [sp..ep].

    + Descomponer en parte izquierda (parcial), parte central(símbolos completos), parte derecha (parcial)

    + Resolver la parte central en O(1) con una estructura RMQ sucinta sobre un array auxiliar M.

    + Resolver las partes laterales descendiendo recursivamente por la gramática, usando la metadata.

    + Combinar los tres resultados.

    == Definición de la metadata

    Teniendo en mente que el objetivo primordial es tener min(SA[ep..sp]) y max(SA[ep...sp]),
    y que se demostró previamente que esto se reduce a encontrar el mínimo y máximo de las
    sumas parciales del DSA en el rango [sp..ep], ahora cada no-terminal X de la gramática
    expande a un bloque contiguo del DSA que diremos DSA[p..q], gracias a la idea propuesta
    en jacm19, podemos definir metadata dentro de ese bloque, precalculando mínimo y máxi
    mo de sumas parciales, combinando así la información de dos bloques adyacentes pudiendo
    responder sobre cualquier rango descendiendo por la gramatica.

    Sea X un no-terminal (o terminal) de la gramatica, y sea D=DSA[p..q] la secuencia de valores a la que X expande, se define:

    #metadata_thm("l(X)-Longitud")[
  $ l(x) = |D| = q - p  +1 $
     Corresponde a cuantos valores del DSA abarca la expansión de X. Sirve para saber donde
    termina la expansión y donde empieza la del siguiente símbolo. Cuando se desciende por la
    gramática buscando una posición especifica, se necesita saber si esa posición cae en el hijo
    izquierdo o derecho de una regla X->$Y_1$$Y_2$, y para eso comparamos la posición con l(Y1)
]

 #metadata_thm("d(X)-Suma total")[
  $ d(x) = D[1] + D[2] + ... + D[l(X)] = D S A[p] + D S A[p+1] + ... + D S A[q] $
     Corresponde a la suma de todos los valores del DSA en la expansión de X.
]
 Como
DSA[j]=SA[j]-SA[j-1], por la suma telescopica, esto implica:
 
$ d(X) = S A[q] − S A[p−1] $

Es decir d(X) es la diferencia entre el último y el primer valor del suffix array cubierto por
X. Esto sirve para cuando estamos procesando la gramática y queremos saltar la expansión de X, por lo que solo basta sumar d(X) al acumulador.

 #metadata_thm($m_"min"-"Mínimo de sumas parciales"$)[
  $ m_(m i n)(X) = m i n _(1<=k<=l(X))P S(k)  $
]

Recordando que SA[p+k-1] = SA[p-1] + PS(k), entonces $m_min$ se puede escribir como:

$ m_(m i n)(X) = m i n _(1<=k<=l(X))S A[j] - S A[p-1] $

Esto quiere decir que $m_min$(X) es el valor mínimo del SA dentro de la expansión de X,
relativo al valor de SA justo antes de la expansión. Cuando se hace el descenso recursivo y
se sabe que el acumulador actual es f, el mínimo absoluto del SA dentro de este bloque es
f+$m_min$(X). Esto permite comparar con mínimos de otros bloques sin descender mas.

#metadata_thm($p_"min"-"Posición del mínimo"$)[
  $ p_(m i n)(X) = a r g m i n _(1<=k<=l(X))P S(k)  $
  Es la posición relativa, dentro de la expansión de X contando desde 1, donde se alcanza
el mínimo de las sumas parciales. Si hay empate se elige la posición mas a la izquierda. Si
$m_min$(X) se alcanza en PS(K$\*$), entonces la posición absoluta en el suffix array donde SA
es mínimo dentro de la expansión de X es p+k$\*$-1 (donde p es la posición del DSA donde
empieza la expansión de X) sirve para reportar donde esta el mínimo, no solo su valor.
]

#metadata_thm($m_"max"-"Máximo de sumas parciales"$)[
  $ m_(m a x)(X) = m a x _(1<=k<=l(X))P S(k)  $
  Análogo a $m_min$, corresponde a valor máximo del SA dentro de la expansión de X, relativo 
al valor de SA justo antes.
]
#pagebreak()
#metadata_thm($p_"max"-"Posición del máximo"$)[
  $ p_(m a x)(X) = a r g m a x _(1<=k<=l(X))P S(k)  $
 Posición relativa donde se alcanza el máximo. En caso de empate se elige la posición mas
a la izquierda
]
Por lo tanto, cada no-terminal almacena 6 valores enteros.
    == Calculo de la metadata 
     Para terminales, el calculo es trivial: dado v=DSA[p] para alguna posición p, las sumas
parciales de una secuencia de un solo elemento corresponde a PS(1)=v . La metadata entonces
es:

- l(v) = 1
- d(v) = v
- $m_min$(v)= v
- $p_min$(v)=1
- $m_max$(v)=v
- $p_max$(v)=1

Para el caso de no terminales, se tiene una regla X->$Y_1$$Y_2$, se requiere calcular la metadata
de X a partir de la metadata de $Y_1$ e $Y_2$. Primero se calcula la metadata de los terminales,luego la de los no terminales que solo tienen terminales como hijos, luego de los no-terminales
cuyos hijos ya tienen metadata, y así sucesivamente.

Sea X->Y1Y2. La expansión de X es la concatenación de la expansión de Y1 seguida de
1la expansión de Y2. Sea D1=la expansión de Y1 de largo l(Y1) y sea D2=la expansión de Y2
de largo l(Y1). La expansion de X es:

$ D= D_1D_2  =D_1[1],D_1[2],...,D_1[l(Y_1)],D_2[1],D_2[2],...,D_2[l(Y_2)] $

*Longitud*: Directo, la concatenación tiene el largo de ambas partes sumadas: 

 $ l (X)= l(Y_1)+l(Y_2) $

 *Suma total*: También directo, la suma de todos los valores es la suma de la primera
parte mas la suma de la segunda parte:

$ d(X)= d(Y_1)+d(Y_2) $

*Mínimo de sumas parciales*: Aquí no es tan directo, pero se puede apreciar que 
las sumas parciales se dividen en dos grupos:

 $ m_(m i n)(X) = m i n _(1<=k<=l(X))P S(k)  $
$ P S(k) = sum_(j=s p)^(s p + k -1) D S A[j], p a r a  quad 1<=k<=e p -s p +1 $

Tomando sp=1 y ep=l(X), entonces la sumatoria queda:

$ P S(k) = sum_(j=1)^(k) D S A[j], p a r a  quad 1<=k<=l(X) $

La longitud ya se calculó previamente, por lo tanto la sumatoria se puede separar:

$ P S(k) = sum_(j=1)^(l(Y_1)) D S A[j] + sum_(j=1)^(l(Y_2)) D S A[j]  $

Por las definiciones hechas, el minimo del primer grupo es $m_min$($Y_1$). Para el segundo
grupo, corresponde a las ultimas l($Y_2$) sumas parciales. Dado que k>l($Y_1$):

$P S(l(Y_1)+j)=d(Y_1)+P S_(Y_2)(j), quad p a r a quad 1<=j<=l(Y_2)$

Donde $P S_(Y_2)(j)$ denota las sumas parciales de la expansión de $Y_2$. Esto se cumple
porque la suma parcial en la posición l($Y_1$)+j incluye toda la expansión de $Y_1$ (cuya suma es d($Y_1$))
mas las primeras j posiciones de la expansión de $Y_2$ (cuya suma parcial es $P S_(Y_2)(j)$
(j)). El mínimo
de este grupo por lo tanto es d($Y_1$)+$m_(min)(Y_2)$. El mínimo global es el menor de los dos:

$ m_(min)(X)=min(m_(min)(Y_1), d(Y_1)+m_(min)(Y_2)) $

*Posición del mínimo*: Si $m_(min)(Y_1)<= d(Y_1)+m_(min)(Y_2)$, entonces el mínimo global
esta en el grupo 1, y su posición relativa dentro de X es la misma que dentro de $Y_1$:
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