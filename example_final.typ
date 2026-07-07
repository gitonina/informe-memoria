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

#let desarrollo(cuerpo) = block(
  stroke: 0.8pt + luma(80%),
  inset: (left: 0.75em, top: 0.6em, bottom: 0.6em, right: 0.75em),
  width: 100%,
  fill: white,
  radius: 4pt,
  cuerpo
)


#let algorithm(titulo, cuerpo) = {
  block(
    stroke: (left: 1.5pt + black, bottom: none, top: none, right: none),
    inset: (left: 0.75em, top: 0.4em, bottom: 0.4em),
    width: 100%,
    if titulo == [] or titulo == "" {
      cuerpo
    } else {
      [*#titulo* \ #cuerpo]
    }
  )
}

#set list(marker: ([▪], [•]))

#let paso(titulo, cuerpo) = {
  list(
    [#emph(strong(titulo)) #linebreak() #cuerpo]
  )
}

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

#let structure = thmenv(
  "estructura",
  "heading",
  none,
  (name, number, body, color: black) => {
    let title = if name == [] or name == "" {
      [*Estructura #number.*]
    } else {
      [*Estructura #number.* (#name)]
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

En el contexto de la clasificación taxonómica, uno de los problemas centrales es determinar de qué organismo proviene un fragmento de ADN (_read_). Para ello, se cuenta con una colección de genomas organizados en un árbol filogenético, donde las hojas representan genomas y los nodos internos representan ancestros comunes. Los genomas se concatenan en el orden de las hojas del árbol, y cuando un patrón (o MEM, una coincidencia exacta maximal entre el _read_ y la colección) aparece en varios genomas, es necesario identificar el primero y el último genoma donde ocurre, para luego calcular el ancestro común más bajo (LCA) en el árbol y así clasificar el _read_.
Este problema se traduce, a nivel de estructuras de datos, en encontrar el mínimo y el máximo del arreglo de sufijos (SA) dentro de un intervalo: dado un intervalo [sp, ep] que representa todas las ocurrencias de un MEM, min(SA[sp..ep]) indica la posición más a la izquierda en el texto (primer genoma) y max(SA[sp..ep]) indica la posición más a la derecha (último genoma). El enfoque directo, utilizado por índices como el sr-index, consiste en recorrer, una por una, las ep − sp + 1 posiciones para encontrar el mínimo y el máximo, con un costo proporcional al número de ocurrencias. Para MEMs con miles o millones de ocurrencias, este costo se vuelve significativo.
Este trabajo propone un enfoque alternativo: construir un índice basado en la compresión gramatical del arreglo diferencial de sufijos (DSA) mediante el algoritmo RePair, almacenando en cada nodo de la gramática información agregada (metadata) que permite responder las consultas de mínimo y máximo descendiendo por la estructura de la gramática, sin enumerar las ocurrencias. El costo de cada consulta depende de la altura de la gramática y no del número de ocurrencias, lo que representa una ventaja sustancial en colecciones repetitivas.
La viabilidad de este enfoque se sustenta en que el DSA de textos repetitivos, como colecciones de genomas, tiene una estructura altamente repetitiva inducida por las runs de la BWT, lo que permite que RePair lo comprima eficientemente. Las ideas, lemas y algoritmos que fundamentan esta construcción fueron adaptados a partir de los resultados expuestos en el paper _Fully-Functional Suffix Trees and Optimal Text Searching in BWT-runs Bounded Space_, el cual fue escrito por Gonzalo Navarro, Travis Gagie y Nicola Prezza.
El índice propuesto se compara experimentalmente contra el sr-index en términos de tiempo de consulta y espacio ocupado. Los resultados se presentan mediante gráficos y tablas comparativas que evidencian el _trade-off_ entre ambos enfoques.
]
#dedicatoria[
    Para mis padres.
]

#agradecimientos[
  Primero quiero agradecer a mis padres, quienes siempre estuvieron para mí cuando más lo necesité. Nunca me faltaron en toda mi vida, y me apoyaron en cada uno de mis proyectos personales y mis decisiones, siempre aconsejándome.
  También quiero agradecer a mi familia, mis primos, mi abuela, mis tíos, todos. Forman parte de mi vida y siempre desearon lo mejor para mí.

  Quiero también agradecer al profesor Gonzalo por darme la oportunidad de trabajar en esta memoria, por ayudarme cuando tuve dudas y por tener siempre la
  disposición para ayudarme cada vez que lo necesité.

  También quiero agradecer a mis amigos de la universidad, en particular al gran grupo que tuve en el DCC (panas). Cada uno me aportó algo en mi vida. Extrañaré
  por siempre los momentos juntos en la facultad.
]

#show: start-doc

#capitulo(title: "Introducción")[
    == Contexto y problemática

    El estudio de la evolución de las especies es uno de los objetivos principales de la bioinformática, una disciplina que combina ciencias informáticas para almacenar y analizar grandes volúmenes de datos biológicos como secuencias de ADN, aminoácidos y demás moléculas biológicas. Un gen es un segmento de ADN, y un genoma es la suma total de toda la información genética de un organismo. Teniendo en cuenta la gran cantidad de especies que existe y que además se tiene una enorme cantidad de colecciones de genomas, es desafiante y complejo al mismo tiempo contestar preguntas como: ¿Dónde aparece una secuencia particular dentro de un genoma?, ¿Cuántas veces aparece una secuencia en un conjunto de genomas?

    Un árbol filogenético es una estructura que permite representar las relaciones de parentesco entre especies y que muestra los cambios en los genes con el pasar del tiempo. Una colección de genomas se organiza según esta estructura y la problemática principal surge a partir de esto: se busca una secuencia de ADN o un gen en esta colección, y se quiere identificar todas sus ocurrencias, mapearlas a los genomas que las contienen, y calcular el ancestro común más bajo (Lowest Common Ancestor, LCA) de esos nodos, el cual es un candidato para la especie donde comenzó a expresarse este gen. Lo difícil radica en que las secuencias no suelen encontrarse exactamente debido a mutaciones, inserciones o recombinaciones. Por lo tanto, la búsqueda se basa en encontrar las coincidencias máximas, las cuales se representan con una estructura llamada Maximal Exact Matches (MEMs). Calcular MEMs requiere estructuras de datos como los Suffix Array (SA), FM-indexes, entre otros que serán definidos más adelante. 

    #pagebreak()
    Cuando un MEM tiene múltiples ocurrencias en la colección, estas se distribuyen a lo largo de la concatenación de los genomas. Dado que los genomas están concatenados en el orden de las hojas del árbol filogenético (de izquierda a derecha), las posiciones de las ocurrencias en el texto reflejan la posición de los genomas en el árbol. La ocurrencia más a la izquierda en el texto (el mínimo del arreglo de sufijos en el intervalo del MEM) corresponde al primer genoma en el orden del árbol donde aparece el MEM, y la ocurrencia más a la derecha (el máximo) corresponde al último genoma. El ancestro común más bajo (LCA) de estas dos hojas extremas necesariamente contiene a todas las hojas intermedias, porque las hojas de cualquier subárbol forman un rango contiguo en el orden de izquierda a derecha. Por lo tanto, no es necesario examinar todas las ocurrencias para determinar el LCA: basta con encontrar la primera y la última. Formalmente, dado el intervalo [sp, ep] del arreglo de sufijos que contiene las posiciones de todas las ocurrencias de un MEM, el problema se reduce a calcular:

    $ min(S A [s p..e p]): "la posición en el texto de la ocurrencia más a la izquierda" $
    $ max(S A [s p..e p]): "la posición en el texto de la ocurrencia más a la derecha" $
    
    Estas dos consultas corresponden a lo que se conoce como Range Minimum Query (RMQ) y Range Maximum Query (RMaxQ) sobre el arreglo de sufijos. Una RMQ sobre un arreglo A[1..n] consiste en, dado un rango [i, j], encontrar el valor mínimo de A en ese rango: RMQ(i, j) = min(A[i], A[i+1], ..., A[j]). La RMaxQ es análoga pero busca el máximo.

    El sr-index (subsampled r-index), presentado por Dustin Cobas, Travis Gagie y Gonzalo Navarro @cobas2025talg, es un índice comprimido diseñado para colecciones de texto altamente repetitivas. Su espacio es proporcional a r, el número de runs de la Transformada de Burrows-Wheeler (BWT), lo que lo hace muy compacto cuando la colección tiene alta repetitividad. El sr-index soporta la operación de localización (locate): dado un intervalo [sp, ep] producido por el backward search, puede recuperar las posiciones SA[sp], SA[sp+1], ..., SA[ep] en el texto. Sin embargo, para obtener el mínimo y el máximo, el sr-index debe enumerar todas las ep − sp + 1 posiciones una por una (mediante aplicaciones sucesivas de la función Φ) y luego recorrerlas linealmente para encontrar los extremos. El costo de este procedimiento es O(s · occ), donde occ = ep − sp + 1 es el número de ocurrencias y s es un parámetro de submuestreo. Para MEMs con miles o millones de ocurrencias, este costo lineal se vuelve un cuello de botella.
    #pagebreak()
    Una gramática libre de contexto es un conjunto de reglas de reemplazo. Tiene dos tipos de símbolos: los terminales (valores finales) y los no-terminales (nombres que representan patrones). Cada regla indica los símbolos que reemplazan cierto no-terminal. 
    
    Partiendo de un simbolo inicial, se aplican las reglas hasta que no queden no-terminales, y lo que queda es la cadena que la gramática genera. La compresión por gramáticas es un caso particular donde la gramática genera exactamente una cadena (la secuencia original). Dado el siguiente ejemplo: 
$
     S ->A B , 
     quad
     A-> "hola", 
     quad 
     B-> "mundo"
$
    Partiendo de S, se reemplaza A y B: $S->"hola mundo"$

    Esto se logra restringiendo la gramática para que cada no-terminal tenga exactamente una regla, y que no haya ciclos. Cada no-terminal captura un patrón repetido de la secuencia: en vez de almacenar todas sus ocurrencias, se almacena una sola regla que lo define, y se referencia por su nombre. El tamaño de la gramática (la suma de símbolos en los lados derechos de todas las reglas) es la medida de compresión, y para secuencias altamente repetitivas puede ser dramáticamente menor que el largo original. Un ejemplo de esto es el siguiente: 


    El arreglo diferencial de sufijos (DSA) almacena las diferencias entre valores consecutivos del arreglo de sufijos: 
    $ D S A[1]=S A[1] $
    $ D S A[p] = S A[p] - S A[p-1] "para todo" p>=2 $

    Los valores originales del SA se pueden reconstruir a partir del DSA mediante sumas parciales: SA[p] = SA[q] + Σ desde j=q+1 hasta p de DSA[j], para cualquier posición de referencia q < p. Esta propiedad permite expresar las consultas de mínimo y máximo como:

    $ min(S A[s p..e p])= S A[s p -1] + "mín de las sumas parciales de DSA[sp..ep] " $

    $ max(S A[s p..e p])= S A[s p -1] + "máx de las sumas parciales de DSA[sp..ep] " $

    La utilidad del DSA radica en que, para colecciones de texto altamente repetitivas, hereda la estructura repetitiva de la BWT. Travis Gagie et al. @gagie2019jacm demostraron que si dos posiciones consecutivas del arreglo de sufijos están dentro de una misma run de la BWT (es decir, BWT[p−1] = BWT[p]), entonces DSA[LF(p)] = DSA[p]: el mismo valor del DSA aparece copiado en otra posición. Como consecuencia, el DSA admite un esquema de macro bidireccional de tamaño O(r), lo que implica que puede representarse mediante una gramática libre de contexto de tamaño O(r log(n/r)). Para colecciones genómicas donde r es mucho menor que n, esto permite una compresión dramática del DSA, y al almacenar metadata de sumas parciales (mínimo y máximo) en cada no-terminal de la gramática, se pueden responder las consultas de RMQ y RMaxQ sobre el SA sin enumerar las ocurrencias, en tiempo proporcional a la altura de la gramática.

    

    Se ha demostrado que la compresión por gramáticas es una herramienta muy
    efectiva para representar secuencias diferenciales altamente repetitivas, como el arreglo diferencial de LCP (Longest Common Prefix: almacena, para cada par de sufijos consecutivos en el orden lexicográfico del arreglo de sufijos, cuántos caracteres comparten al inicio), permitiendo responder consultas de rango y de prefijos a partir de metadatos
    almacenados en cada no terminal de la gramática. 
    Este enfoque sugiere que, si en lugar de
    comprimir LCP se comprime directamente el DSA, y si a cada regla se le asocia la suma
    de su expansión junto con el mínimo y máximo de sumas parciales es posible reconstruir
    implícitamente la información relevante del SA y responder consultas de tipo RMQ sobre SA
    sin necesidad de mantenerlo explícito. De esta forma, el costo de calcular min(SA[sp..ep]) y
    max(SA[sp..ep]) se traslada a operaciones sobre la gramática (en tiempo sublineal o logarítmico respecto al tamaño del texto) mientras que el espacio ocupado depende del tamaño de
    la gramática y no del número total de sufijos. Esta combinación de compresión y soporte de
    consultas de rango es precisamente lo que hace atractivo el uso de gramáticas sobre el DSA
    como base para el índice propuesto en esta memoria.

    == Baseline

    El baseline con el cual se compara la propuesta es el sr-index. Este índice resuelve el mismo problema pero de manera diferente. La implementación se puede encontrar en https://github.com/duscob/sr-index la cual fue hecha por Dustin Cobas.

    == Contribución de la memoria

    + *Comprimir el DSA con Repair*: Almacenar en cada no-terminal seis campos: longitud l(X), suma total d(X), mínimo de sumas parciales $m_min(X)$, posición del mínimo $p_min(X)$, máximo de sumas parciales $m_max(X)$, y posición del máximo $p_max(X).$
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

   El FM-index es un índice comprimido que permite buscar patrones en T sin alamacenar T explicitamente, y se basa en en la BWT. El Run-Length FM-index es una variante del F-index, diseñada para textos repetitivos. Usa el hecho de que la BWT de un texto repetitivo tiene pocas runs: alcmacena la BWT de forma compacta representando cada run por su carácter y su longitud. 
   #pagebreak()
   == Arreglo diferencial de sufijos DSA

   El Arreglo diferencial de sufijos se define de la siguiente manera: 

    DAS[1] = SA[1]

    DSA[p] = SA[p] - SA[p-1] para todo p$>=$2

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
      
       Este trabajo (que llamaremos Sea24) @draesslerova2024sea, aborda como clasificar un read de ADN (de
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
    
      Este paper (talg25) @cobas2025talg presenta el baseline con el que se compararía el índice propuesto en
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

$ P S(l(Y_1)+j)=d(Y_1)+P S_(Y_2)(j), quad p a r a quad 1<=j<=l(Y_2) $

Donde $P S_(Y_2)(j)$ denota las sumas parciales de la expansión de $Y_2$. Esto se cumple
porque la suma parcial en la posición l($Y_1$)+j incluye toda la expansión de $Y_1$ (cuya suma es d($Y_1$))
mas las primeras j posiciones de la expansión de $Y_2$ (cuya suma parcial es $P S_(Y_2)(j)$
(j)). El mínimo
de este grupo por lo tanto es d($Y_1$)+$m_(min)(Y_2)$. El mínimo global es el menor de los dos:

$ m_(min)(X)=min(m_(min)(Y_1), d(Y_1)+m_(min)(Y_2)) $

*Posición del mínimo*: Si $m_(min)(Y_1)<= d(Y_1)+m_(min)(Y_2)$, entonces el mínimo global
esta en el grupo 1, y su posición relativa dentro de X es la misma que dentro de $Y_1$:
    
    $ p_(min)(X) =  p_(min)(Y_1) $
    En caso contrario, entonces el mínimo global esta en el segundo grupo, y su posición
relativa dentro de X es la posición de Y2 mas el largo de Y1:

$ p_(min)(X)=l(Y_1)+p_(min)(Y_2) $

En caso de igualdad, se elige la posición más a las izquierda que esta en el primer grupo.

*Máximo de sumas parciales*: El razonamiento es totalmente simétrico al mínimo: 

$ m_(max)(X)=max(m_(max)(Y_1), d(Y_1)+m_(max)(Y_2)) $

*Posición del máximo*: Si $m_(min)(Y_1)>=d(Y_1)+m_(min)(Y_2)$, el máximo global 
esta en el primer grupo, y su posición relativa en X es la misma que dentro de 
$Y_1$:

$ p_(max)(X)=p_(max)(Y_1) $

En caso contrario (analogo al mínimo):

$ p_(max)(X)=l(Y_1)+p_(max)(Y_2) $
    == Complejidad del calculo de la metadata 
      Para cada regla X-> $Y_1Y_2$, el calculo de los 6 campos de metadata toma O(1) en tiempo
dado que solo son comparaciones y sumas. Si la gramática tiene g reglas, el tiempo total es
O(G). En cuanto espacio, si la gramática tiene g no-terminales, el espacio total de la metadata
es O(g). Los terminales también tienen metadata, pero es trivial y se pueden calcular en el
camino, así que no requieren almacenamiento adicional.
    == Estructuras auxiliares
    
    Lo siguiente es una adaptación de lo que se hace en jacm19 en la seccion 6.3 para el
    DLCP. La gramatica del DLCP tiene una regla inicial:
    
    $ S->X_1X_2... $
    Se construyen arrays auxiliares sobre esta secuencia para poder localizar rápidamente en
que símbolo $X_x$ cae una posición dada, y para resolver la parte central de una consulta RMQ
en O(1). Especificamente, en jacm19 se define:

     - L[x]: longituds acumuladas (para localizar posiciones)
     - A[x]: diferencias acumuladas (para convertir entre valores relativos y absolutos)
     - M[x]: mínimos por símbolo (para resolver parte central de RMQ)
     - $R M Q_M$: Estructura RMQ sucinta sobre M (para consultas o(1))

     Estas mismas ideas se aplican al DSA en vez del DLCP, y se duplican para manejar tanto
     mínimos como máximos.

     La regla del símbolo inicial de la gramática Repair es de la forma:

     $ S->s_1s_2s_3... $

     Esta secuencia se denotará por $D S A_0$. Cada simbolo $s_x$ es un terminal o un no-terminal y expande a un bloque contiguo del DSA. Cuando llega una consulta RangeMin(SA[ep..sp]), lo primero que se necesita saber es en qué simbolos de $D S A_0$ caen las posiciones sp y ep. Y para la parte central de la consulta (los símbolos completos entre sp y ep), se necesita encontrar rápidamente cual tiene el menor / mayor valor del SA. Las estructuras auxiliares resuelven estos problemas. Las siguientes definiciones son sacadas directamente desde jacm19, adaptadas para el arreglo DSA:

     #structure("Longitudes acumuladas L[x]")[ Dado K=|$D S A_0$|: 
   $ L[0]=0 $
   $ L[x]=L[x-1] + l(s_x), quad  p a r a quad 0<=x<=K  $
]
L[x] es la posición del DSA hasta donde llega la expansión de $s_x$. La expansión de $s_x$ cubre las posiciones DSA[L[x-1]+1..L[x]]. Para encontrar en qué simbolo $s_x$ cae la posición DSA[p], hacemos una búsqueda binaria sobre L para encontrar el x tal que L[x-1]$<$p$<=$L[x], lo cual toma o(log(|$D S A_0$|)).

#structure("Diferencias acumuladas A[x]")[ Dado K=|$D S A_0$|: 
   $ A[0]=0 $
   $ A[x]=A[x-1] + d(s_x), quad  p a r a quad 0<=x<=K  $
]
Recordando que $d(s_x)$ es la suma de los valores del DSA en la expansión de $s_x$, como el
DSA son diferencias del SA, la suma acumulada da las diferencias del SA entre posiciones
mas lejanas:

$ A[x]=d(s_1)+d(s_2)+...+d(s_x)=D S A[1]+D S A[2]+...+D S A[L[x]]= S A[L[x]]-S A[0] $
#pagebreak()
Si se define SA[0]=0, entonces A[x]=SA[L[x]]. Esto sirve cuando se requiera saber SA[L[x-1]](el valor del SA justo al final de la expansión del símbolo x-1, que es el punto de referencia para el símbolo x). Mas precisamente, en el algoritmo de consulta que se verá mas adelante, A[x-1] es es el valor base f a partir del cual los valores relativos $m_min$ y $m_max$ del símbolo $s_x$ se convierten en valores absolutos del SA, es decir: 

$ E l quad m í n i m o  quad a b s o l u t o quad d e l quad S A quad d e n t r o quad d e quad l a quad e x p a n s i ó n quad d e quad s_x quad e s: A[x-1]+m_(min)(s_x) $
$ E l quad m á x i m o  quad a b s o l u t o quad d e l quad S A quad d e n t r o quad d e quad l a quad e x p a n s i ó n quad d e quad s_x quad e s: A[x-1]+m_(max)(s_x) $

#structure($M_"min"$)[ Dado K=|$D S A_0$|: 
   $ M_(min)[x]=A[x-1]+m_(min)(s_x),quad p a r a quad 1<=x<=K $
]

En jacm19 se define un solo array M para los mínimos, en este caso se necesitan dos, uno para los mínimos y otro para los máximos. $M_min$ es el valor mínimo absoluto del SA dentro de la expansión de $s_x$.

#structure($M_"max"$)[ Dado K=|$D S A_0$|: 
   $ M_(max)[x]=A[x-1]+m_(max)(s_x),quad p a r a quad 1<=x<=K $
]
$M_max$ es el valor máximo absoluto del SA dentro de la expansión de $s_x$

Estas estructuras son necesarias pues queremos comparar mínimos y máximos entre distintos valores del $D S A_0$. Cada símbolo tiene un punto de referencia distinto (A[x-1]), y la metadata $m_min$ y $m_max$ es relativa a ese punto de referencia. Para poder comparar es necesario convertir a valores absolutos.

#structure($"R M Q"_M_min$)[ Dado un rango [x..y], devuelve en o(1) la posición z $in$ [x..y] tal que $M_min$[z] es mínimo.
  ]
  
#structure($"R M Q"_M_max$)[ Dado un rango [x..y], devuelve en o(1) la posición z $in$ [x..y] tal que $M_max$[z] es máximo.
  ]

  En jacm19, la estructura realizada por Ficher y Heun resuelve RMQ en o(1) usando solo o(r) bits, sin almacenar el array M explícitamente. Aquí se toma esta idea pero almacenando $M_min$ y $M_max$ (que son solo o(|$D S A_0$|)). Estas estructuras sirven para cuando la consulta RangeMin(SA[sp..ep]) tiene una parte central que abarca los simbolos $D S A_0$[x+1..y-1], se necesita encontrar cual de estos símbolos tiene el menor $M_min$. El espacio total de las estructuras auxiliares es O(|$D S A _0$|), que es proporcional al número
de símbolos en la secuencia comprimida. Como |$D S A_0$|$<=$g (el tamaño de la gramática) $<=$
n, y para textos repetitivos g$<<$ n.
    == Algoritmo de consulta
    El algoritmo siguiente es una adaptación del procedimiento de RMQ sobre la gramática del DLCP descrito en Jacm19. Jacm19 describe como resolver RMQ(p,q) sobre el LCP descomponiendo el rango en tres partes, y descendiendo por la gramática para las partes parciales. Se hará exactamente lo mismo pero sobre el DSA para obtener RangeMin y RangeMax sobre el SA. La estructura general es: 

    + Descomponer el rango [sp,ep] en 3 partes respecto a la secuencia $D S A_0$.
    + Resolver la parte central en o(1) con $R M Q_(M_min)$ y $R M Q_(M_max)$.
    + Resolver las partes laterales descendiendo por la gramática.
    + Combinar los 3 resultados.
    
    El input del algoritmo es un intervalo [sp..ep] del SA, donde 1$<=$sp$<=$ep$<=$n. Ese intervalo viene de backward search de la BWT: cuando se busca un MEM en el FM-index, se obtiene el rango de posiciones del SA donde aparecen las ocurrencias de ese MEM. El output sería finalmente min(SA[sp],SA[sp+1],...,SA[ep]) y max(SA[sp],SA[sp+1],...,SA[ep]) junto con sus posiciones. Con estos dos valores y el bitvector B, se obtiene:

    $ f i r s t-g e n o m e= B.r a n k(min(S A[s p],S A[s p+1],...,S A[e p])) $ 
    $ l a s t-g e n o m e= B.r a n k(max(S A[s p],S A[s p+1],...,S A[e p])) $ 

    Luego, LCA(firt-genome,last-genome) entrega la clasificación.
    #pagebreak()
    #algorithm[Algoritmo de consulta][
  #paso[Paso 1: Localizar los símbolos extremos][
  Hacemos dos búsquedas binarias sobre el array L para encontrar: 

    - x: el índice del símbolo de $D S A_0$ que contiene la posición sp. Es decir, el x tal que L[x-1]$<$sp$<=$L[x].

    - y: el índice del simbolo de $D S A_0$ que contiene la posición sp. Es decir, el y tal que L[y-1]$<$ep$<=$L[y].
  ]

  #paso[Paso 2: Descomponer en 3 partes][
    + Parte derecha del símbolo $s_x$: DSA[sp...L[x]]

    + Parte central: DSA[L[x]+1...L[y-1]]

    + Parte izquierda del símbolo $s_y$: DSA[L[y-1]+1...ep]

    *Casos especiales*
    - x=y: Las posiciones sp y ep caen dentro del mismo símbolo. No hay parte central, y las partes 1 y 3 se fusionan en una sola consulta parcial dentro de $s_x$
    - x+1=y: No hay símbolos completos entres $s_x$ y $s_y$. La parte 2 está vacía. Solo hay partes 1 y 3
    - sp= L[x-1]+1: sp empieza justo al inicio de $s_x$, entonces la parte 1 cubre toda la expansión de $s_x$ y no se necesita descender, se puede usar $M_min$ y $M_max$ directamente. 
    - ep= L[y]: ep llega justo al final de $s_y$, entonces la parte 3 cubre toda la expansión de $s_y$ y se puede usar $M_min$
     y $M_max$

  ]
  #paso[Paso 3: Resolver la parte central][
    Dado un no-terminal X con expansión D=DSA[p..q] de largo l(X), y un subrango [a..b] con 1$<=$a$<=$b$<=$l(X), se debe encontrar mínimo y máximo de las sumas parciales de D[a..b]

    *Caso base(X es terminal)*: Si X es un terminal con valor v, entonces l(X)=1 y por lo tanto, a=b=1: min=v, max=v, posición=1.

    *Caso recursivo: $X->Y_1Y_2$*: Hay 3 subcasos donde caen a y b con respecto a l($Y_1$):

                                - *Subcaso A ($b<=l(Y_1))$*: Todo el rango esta dentro de $Y_1$. Descendemos recursivamente en $Y_1$ con el mismo rango [a..b]
  ]
]
#pagebreak()
 #algorithm[][
  - *Subcaso B  ($a>l(Y_1))$*: Todo el rango esta dentro de $Y_2$. Descendemos recursivamente en $Y_2$ con rango [a-l($Y_1$),b-l($Y_1$)]
  - *Subcaso C ($a<=l(Y_1)<b)$*: Este es el caso mas interesante, se requiere:
       + El min/max de sumas parciales de $Y_1$[a..l($Y_1$)] (cola derecha de $Y_1$)
       + El min/max de sumas parciales de $Y_2[1..b-l(Y_1)]$ (cola izquierda de $Y_2$)
       + Combinar ambos resultados
  Para el punto 1, se desciende recursivamente en $Y_1$ con rango [a,l($Y_1$)].Para el punto 2, se desciende recursivamente en $Y_2$ con rango [1,b-l($Y_1$)] con acumulador $f_2$=f+(suma de D[a..l($Y_1$)]).

Esa suma es el resultado del descenso en $Y_1$, especificamente, es d de la sub-consulta en $Y_1$ (la suma total de las sumas parciales en $Y_1[a..l(Y_1)]$). Cuando se desciende en $Y_1$, además de de obtener el min y max, también se obtiene la suma total del sub-rango, que es el valor de la última suma parcial. 

Formalizando:

$ ( m i n_L,m a x_L, s u m_L, p o s_min_L,p o s_max_L )= d e s c e n s o(Y_1,a,l(Y_1),f) $
Donde $s u m_L$ es la suma DSA[p+a-1] +...+DSA[p+l($Y_1$)-1], que equivale a
la suma parcial final del sub-rango en $Y_1$, luego:

$ f_2= f+s u m_L $
$ ( m i n_R,m a x_R, s u m_R, p o s_(m i n)_R,p o s_(m a x)_R )= d e s c e n s o(Y_2,1,b-l(Y_1),f_2) $
Combinando:
$ r e s u l t_(m i n)=m i n(m i n_L,m i n_R) $
$ r e s u l t_(m a x)= m a x(m a x_L,m a x_R) $
La suma del subrango $Y_1$[a..l($Y_1$)] se puede calcular durante el descenso.
Cuando se llega a un nodo completo que esta dentro del rango, su suma es d(X). Cuando
se parte un nodo, se acumulan las sumas de las partes que se cubren completamente. Si el subrango
cubre toda la cola derecha de $Y_1$ desde la posición a hasta l($Y_1$), la suma es:
$s u m_L=d(Y_1)-P S^(a-1)_(Y_1)$, donde $P S^(a-1)_(Y_1)$ es la suma parcial de $Y_1$
hasta la posición a-1. En la practica , se va acumulando las sumas de los nodos que se saltan,
y al final, $s u m_L$ se obtiene como d($Y_1$) menos esa acumulación. 
 ]

    == Ejemplo completo  
    A continuación se presentará un ejemplo de como funciona este índice aplicado al DSA:

    Dado el siguiente texto: T= A T G C A $\$$ A T G C G $\$$ C T G C A $\$$
    
    Se tienen los siguientes genomas:

    - Genoma 0: A T G C A
    - Genoma 1: A T G C G 
    - Genoma 2: C T G C A

    === Suffix Array SA
    Teniendo en cuenta que ordenados de forma lexicográfica se cumple que $\$$$<$A$<$C$<$G$<$T, dada la tabla @tab:sufijos, el Suffix Array es SA = [18,6,12,17,5,1,7,16,4,10,13,11,15,3,9,14,2,8].

    #figure(
  table(
    columns: 4,
    align: center,
    table.hline(),
    table.cell(colspan: 4)[*Sufijos del texto T*],
    table.hline(),
    [*i*], [*SA[i]*], [*Sufijo*], [*Grupo*],
    table.hline(),
    [1],  [18], [$dollar$],                              [$dollar$],
    [2],  [6],  [$dollar$ATGCG$dollar$CTGCA$dollar$],   [$dollar$],
    [3],  [12], [$dollar$CTGCA$dollar$],                 [$dollar$],
    [4],  [17], [A$dollar$],                             [A],
    [5],  [5],  [A$dollar$ATGCG$dollar$CTGCA$dollar$],  [A],
    [6],  [1],  [ATGCA$dollar$ATGCG$dollar$...],         [A],
    [7],  [7],  [ATGCG$dollar$CTGCA$dollar$],            [A],
    [8],  [16], [CA$dollar$],                            [C],
    [9],  [4],  [CA$dollar$ATGCG$dollar$...],            [C],
    [10], [10], [CG$dollar$CTGCA$dollar$],               [C],
    [11], [13], [CTGCA$dollar$],                         [C],
    [12], [11], [G$dollar$CTGCA$dollar$],                [G],
    [13], [15], [GCA$dollar$],                           [G],
    [14], [3],  [GCA$dollar$ATGCG$dollar$...],           [G],
    [15], [9],  [GCG$dollar$CTGCA$dollar$],              [G],
    [16], [14], [TGCA$dollar$],                          [T],
    [17], [2],  [TGCA$dollar$ATGCG$dollar$...],          [T],
    [18], [8],  [TGCG$dollar$CTGCA$dollar$],             [T],
    table.hline(),
  ),
  caption: [Sufijos del texto T],
) <tab:sufijos>
=== Differential Suffix Array

#figure(
  table(
    columns: 4,
    align: center,
    table.hline(),
    table.cell(colspan: 4)[*Differential Suffix Array DSA*],
    table.hline(),
    [*p*], [*SA[p]*], [*SA[p-1]*], [*DSA[p]*],
    table.hline(),
    [1],  [18], [-],  [18],
    [2],  [6],  [18], [-12],
    [3],  [12], [6],  [6],
    [4],  [17], [12], [5],
    [5],  [5],  [17],  [-12],
    [6],  [1],  [5],  [-4],
    [7],  [7],  [1],  [6],
    [8],  [16], [7], [9],
    [9],  [4], [16],  [-12],
    [10], [10], [4], [6],
    [11], [13], [10], [3],
    [12], [11], [13], [-2],
    [13], [15],  [11], [4],
    [14], [3],  [15],  [-12],
    [15], [9], [3],  [6],
    [16], [14],  [9], [5],
    [17], [2],  [14],  [-12],
    [18], [8],  [2],  [6],
    table.hline(),
  ),
  caption: [Differential Suffix Array DSA ],
) <tab:diferential>
Dado el SA, se calcula el DSA. De acuerdo a @tab:diferential se tiene que DSA= [18, -12, 6, 5, -12, -4, 6, 9, -12, 6, 3, -2, 4, -12, 6, 5, -12, 6]. Se pueden apreciar los siguientes pares repetidos:

- [-12,6] aparece cuatro vececes
- [6,5] aparece dos veces
- [5,12] aparece dos veces 

=== Compresión Repair 
- Iteración 1: El par mas frecuente es [-12,6] con frecuencia 4:

$ A-> (-12)quad 6 $

Reemplazando las 4 ocurrencias:

$ D S A_0 =[18, A, 5, -12, -4, 6, 9, A, 3, -2, 4, A, 5,A] $

- Iteración 2: El par mas frecuente es [A,5] con frecuencia 2:

$ B-> A quad 5 $
Reenplazando: 

$ D S A_0=[18, B, -12, -4, 6, 9, A, 3, -2, 4, B , A] $

- iteración 3: Repair termina dado que no hay par con frecuencia mayor a 1. 

La gramatica final entonces: 

$ A ->(-12) quad 6 $
$ B -> A quad 5 $
$ S-> [18, B, -12, -4, 6, 9, A, 3, -2, 4, B , A] $

=== Metadata

- Para cualquier terminal v: l=1, d=v, $m_min$=v, $p_min$=1, $m_max$=v, $p_max$=1. 

- *No-terminal A: A$->$(-12) 6*:
    l(A)= 1 + 1= 2

    d(A)= -12 + 6 = -6

    Sumas parciales= PS(1)= -12, PS(2)= -12 +6 = -6 

    $m_min$(A)= min(-12,-6) = -12 

    $p_min$(A)= 1

    $m_max$(A)= max(-12,-6) = -6

    $p_max$(A)= 1 + 1 = 2

#pagebreak()
- *No-terminal B: B$->A quad 5$*

    l(B) = 2 + 1 = 3
    d(B) = -6 + 5 = -1

    Sumas parciales= PS(1)= -12, PS(2)= -6, PS(3) = -6 + 5= -1

    $m_min$(B)= -12

    $p_min$(B)= 1

    $m_max$(B)= max(-12,-6) = -1

    $p_max$(B)= 3
     
     #figure(
  table(
    columns: 8,
    align: center,
    table.hline(),
    table.cell(colspan: 8)[*Tabla de metadatos*],
    table.hline(),
    [], [*Regla*], [*l*], [*d*], [$m_"min"$], [$p_"min"$], [$m_"max"$], [$p_"max"$],
    table.hline(),
    [A], [(-12)6], [2], [-6], [-12], [1], [-6],  [2],
    [B], [A 5],   [3], [-1], [-12], [1], [-1],  [3],
    table.hline(),
  ),
  caption: [Tabla de metadatos],
) <tab:metadatos>
=== Estructuras auxiliares 

La secuencia $D S A_0$ tiene 12 simbolos: $s_1$=18, $s_2$=B, $s_3$=-12, $s_4$=-4, $s_5$=6, $s_6$=9, $s_7$=A, $s_8$=3, $s_9$=-2, $s_10$=4, $s_11$=B, $s_12$=A.

    + Array L: 
      #figure(
  table(
    columns: 4,
    align: center,
    table.hline(),
    table.cell(colspan: 4)[*Array L*],
    table.hline(),
    [*x*], [$s_x$], [$l(s_x)$], [*L[x]*],
    table.hline(),
    [0],  [-],   [-], [0],
    [1],  [18],  [1], [1],
    [2],  [B],   [3], [4],
    [3],  [-12], [1], [5],
    [4],  [-4],  [1], [6],
    [5],  [6],   [1], [7],
    [6],  [9],   [1], [8],
    [7],  [A],   [2], [10],
    [8],  [3],   [1], [11],
    [9],  [-2],  [1], [12],
    [10], [4],   [1], [13],
    [11], [B],   [3], [16],
    [12], [A],   [2], [18],
    table.hline(),
  ),
  caption: [Tabla de cálculo de array L],
) <tab:arrayl>

    + Array A 
      #figure(
        table(
          columns: 3,
          align: center,
          table.hline(),
          table.cell(colspan: 3)[*Array A*],
          table.hline(),
          [*x*], [$d(s_x)$], [*A[x]*],
          table.hline(),
          [0],  [-],   [0],
          [1],  [18],  [18],
          [2],  [-1],  [17],
          [3],  [-12], [5],
          [4],  [-4],  [1],
          [5],  [6],   [7],
          [6],  [9],   [16],
          [7],  [-6],  [10],
          [8],  [3],   [13],
          [9],  [-2],  [11],
          [10], [4],   [15],
          [11], [-1],  [14],
          [12], [-6],  [8],
          table.hline(),
        ),
        caption: [Tabla de cálculo de array A],
      ) <tab:arraya>
      
    + Arrays $M_min$ y $M_max$
    #figure(
  table(
    columns: 7,
    align: center,
    table.hline(),
    table.cell(colspan: 7)[*Arrays $M_"min"$ y $M_"max"$*],
    table.hline(),
    [*x*], [$s_x$], [$A[x-1]$], [$m_"min"$], [$m_("max")$], [$M_("min")[x]$], [$M_("max")[x]$],
    table.hline(),
    [1],  [18], [0],  [18],  [18], [18], [18],
    [2],  [B],  [18], [-12], [-1], [6],  [17],
    [3],  [-12],[17], [-12], [-12],[5],  [5],
    [4],  [-4], [5],  [-4],  [-4], [1],  [1],
    [5],  [6],  [1],  [6],   [6],  [7],  [7],
    [6],  [9],  [7],  [9],   [9],  [16], [16],
    [7],  [A],  [16], [-12], [-6], [4],  [10],
    [8],  [3],  [10], [3],   [3],  [13], [13],
    [9],  [-2], [13], [-2],  [-2], [11], [11],
    [10], [4],  [11], [4],   [4],  [15], [15],
    [11], [B],  [15], [-12], [-1], [3],  [14],
    [12], [A],  [14], [-12], [-6], [2],  [8],
    table.hline(),
  ),
  caption: [Tabla de cálculo de arrays $M_"min"$ y $M_"max"$],
) <tab:arrayammaxmin>
=== Read y MEMs 

Sea el read ATGCG, que es exactamente el genoma 1, el FM-index encuentra dos MEMs:                                                                                                                
- MEM 1: El read completo se encuentra en el intervalo [sp=7,ep=7]. Solo una ocurrencia SA[7]=7. min=max=7
- MEM 2: TGC. Intevalo= [sp=16,ep=18]. Esto arroja tres ocurrencias. SA[16]=14, SA[17]=2, SA[18]=8. Se requiere min y max. Es decir, RangeMin(SA[16..18]) y RangeMax(SA[16..18])

=== Consulta RangeMin(SA[16..18]) y RangeMax(SA[16..18])

#desarrollo[

 *Paso 1: Localizar los símbolos extremos* 
$ s p = 16: L[10]=13 < 16 <= L[11]=16 -> x=11 (S_11=B quad c u b r e quad D S A [14..16]) $
$ e p = 18: L[11]=16 < 18 <= L[12]=18 -> y=12 (S_12=A quad c u b r e quad D S A  [17..18]) $

  *Paso 2: Descomponer en partes*
  - Parte (i): DSA[16..16] -Cola derecha de $s_11$=B (parcial: solo la última posición de B)
  - Parte (ii): vacía - No hay simbolos completos entre x=11 e y=12

  - Parte (iii): DSA[17..18] - $s_12$ = A completo (ep=18=L[12])
]
  #pagebreak()

  #desarrollo[
*Paso 3: Resolver parte (iii)* 
Como A es un simbolo completo, se usa $M_min$ y $M_max$ directamente: 

$ m i n_(d e r) = M_(min)[12]=2 ,quad  p o s i c i ó n:L[11] + p_(min)(A)=16+1=17 $
$ m a x_(d e r)= M_(max)[12]=8, quad p o s i c i ó n:L[11]+p_(min)(A)=18 $

Esto quiere decir que A cubre SA[17..18]=[2,8]. min=2 en SA[17] y max=8 en SA[18] es consistente.

*Paso 4: Resolver la parte (i)-Descenso en B*: B cubre DSA[14..16], pero solo se necesita DSA[16..16]: la posición 3 de B.

$ o f f s e t quad l o c a l: a=3, b=3 quad (u n a quad s o l a quad  p o s i c i ó n ) $
$ v a l o r quad b a s e: f= A[10]=15quad(p o r q u e quad S A[L[10]]=S A[13]=15) $

Se desciende en B $->$A 5, donde l(A)=2 y l(5)=1. El offset cumple con a=3 $>$l(A)=2, asi que la posición 3 esta completamente en el hijo derecho. Este es el sub-caso B (en el procedimiento general expuesto en el algoritmo): todo el rango esta en $Y_2$. Antes de entrar en $Y_2$, se debe saltar $Y_1$=A. Actualizando el acumulador:
$ f -> f+d(A)=15+(-6)=9 $

Esto es así pues d(A)=-6 significa que SA avanza -6 a lo largo de la expansión de A. SA[L[10]] era el punto de referencia. Despues de pasar por los 2 valores de A, el nuevo punto de referencia es SA[L[10]+2]=SA[15]=15+(-6)=9, lo cual es consistente. 
Estando en el terminal 5: 
$ m i n_(i z q) = f+5 = 9+5=14,quad p o s i c i ó n: L[10]+3=13+3=16 $
$ m a x_(i z q) = f+5 = 9+5=14,quad p o s i c i ó n: 16 $
Lo cual es consistente: SA[16]=14

  ]

#pagebreak()
#desarrollo[
*Paso 5: Combinar*

#figure(
  table(
    columns: 5,
    align: center,
    table.hline(),
    table.cell(colspan: 5)[*Arrays $M_"min"$ y $M_"max"$*],
    table.hline(),
    [*Parte*], [*Min*], [*Pos min*], [*Max*], [*Pos Max*],
    table.hline(),
    [Descenso en B], [14], [16], [14], [16],
    [A completa],    [2],  [17], [8],  [18],
    table.hline(),
  ),
   caption: [Tabla resumen descenso en grámatica],
)

$ r e s u l t_(m i n)= min(14,2)=2 ,e n quad p o s i c i ó n quad 17 $
$ r e s u l t_(m a x)= max(14,8)=14, e n quad p o s i c i ó n quad 16 $
Verificando, se cumple justamente que: SA[16..18]=[14,2,8]. min=2 en SA[17] y max=14 en SA[16]
]
  
    == Integración con el pipeline
     Lo que se ha hecho hasta ahora ha sido construir una forma eficiente de resolver el paso central del pipeline: dado un intervalo [sp..ep] del suffix array, encontrar min(SA[sp..ep]) y max(SA[sp..ep]) sin enumerar todas las ocurrencias. A continuación se presentará como unir todo desde un read del ADN hasta una clasificación taxonómica.
     Dado un arbol filogenetico T con genomas $G_1$ a $G_D$:

     *Fase de construcción*

      + Construir el Suffix Array $S A[1..n]$ de $T$
      + Calcular el $D S A$
      + Comprimir el $D S A$ con Repair: gramática $g$ con reglas $X -> Y_1 Y_2$ y secuencia $D S A_0$
      + Calcular metadata para cada no-terminal $X$: $l(X)$, $d(X)$, $m_"min"(X)$, $p_"min"(X)$, $m_"max"(X)$, $p_"max"(X)$
      + Construir estructuras auxiliares $L, A, M_"min", M_"max"$ y estructuras RMQ sucintas sobre $M_"min"$, $M_"max"$
      + Construir bitvector $B[1..n]$
      + LCA
      + Construir el índice con ropebwt3 para encontrar MEMs
  #pagebreak()
      *Fase de consulta*

      Dado un read $R$:

      + Encontrar MEMs de $R$ respecto a la colección usando ropebwt3. Resultado: lista de MEMs, cada uno con intervalo $[s p_i, e p_i]$
      + Para cada $M E M_i$ con intervalo $[s p_i, e p_i]$:
        - $f i r s t_("pos"_i)$ = $"RangeMin"(S A[s p_i .. e p_i])$ usando el algoritmo de descenso por la gramática del DSA
        - $l a s t_("pos"_i)$ = $"RangeMax"(S A[s p_i .. e p_i])$ usando el mismo algoritmo con metadata de máximo
        - $f i r s t_("genome"_i)$ = $B . "rank"_1 (f i r s t_("pos"_i))$
        - $l a s t_("genome"_i)$ = $B . "rank"_1 (l a s t_("pos"_i))$
        - $l c a_i$ = $"LCA"("hoja"[f i r s t_("genome"_i)], "hoja"[l a s t_("genome"_i)])$
      + Clasificar el read basándose en el MEM más largo
]

#capitulo(title: "Experimentación")[
   
  == Setup experimental
  Los experimentos fueron ejecutados en el servidor Knuth del departamento de Ciencias de la Computación de la Universidad de Chile, el cual tiene las siguientes especificaciones:

  - CPU: Procesador Intel Xeon de 8 cores, corriendo a 2.4 GHz, apoyado por 10MB de memoria caché. 
  - RAM: 125 GB
  - Disco: 2TB 
  - Sistema Operativo: Linux 

El codigo se puede encontrar en * https://github.com/gitonina/DSA-Grammar *. El lenguaje ocupado fue C++, y la unica librería externa usada fue SDSL para la estructura RMQ sucinta. Los datasets fueron descargados de la pagina Pizza&Chili Corpus, con excepción del dataset llamado synth de la @tab:datasets que fue construido de un arhivo makeData. 

*Datasets*

#figure(
  table(
    columns: 5,
    align: center,
    table.hline(),
    [*Dataset*], [*n (MB)*], [$sigma$], [*r*], [*n/r*],
    table.hline(),
    [synth],        [100],    [5], [908.820], [110,03],
    [influenza],    [154.8],  [16], [3.022.822], [51,21],
    [ecoli],        [112.69], [16], [15.044.487], [7,49],
    [einstein],     [467.62], [139], [288.909], [1.610,36],
    [worldleaders], [46.96],  [89], [569.732], [82,26],
    table.hline(),
  ),
  caption: [Caracteristicas de los datasets utilizados],
)<tab:datasets>
#pagebreak()
+ *Synth*: Es un dataset generado con un archivo makeData.c, son 1000 genomas sintéticos de alrededor de 100.000 pb cada uno. Aplica mutaciones controladas para crear las 1000 variantes, por esto su repetitividad es intermedia y predecible. 

+ *Escherichia_Coli*: Colecciones de múltiples genomas completos de la bacteria E.coli, concatenados. Aunque son genomas de la misma especie, cada cepa acumula mutaciones puntuales propias, por esto, es el dataset con r mas alto de todos (menos compresible por BWT). 

+ *Influenza*: Colección de genomas completos del virus de la influenza, concatenados. Al ser un virus de ARN con tasa de mutación muy alta, también divergen bastante entre sí punto a punto, aunque un poco menos que ecoli.

+ *Einstein*: Corresponde a todas las versiones/revisiones sucesivas del arituclo de wikipedia en inglés sobre Albert Einstein, concatenadas una tras otra (historial de ediciones). Es el dataset mas repetitivo de todos. 

+ *World Leaders*: Colección de todos los archivos pdf de los lideres mundiales de la CIA desde 2003 a 2009. Son cientos de biografías breves con estructura repetitiva, aunque menos que Einstein porque el contenido entre sí varía. 
 == Metodología

 + Tiempo : Se midió en microsegundos ($mu$s) por consulta RMQ (min y max juntos)
   - *Baseline (sr-index)*: se mide solo Locate()- que enumera todas las ocurrencias del intervalo [sp,ep] y posteriormente se calcula min/max. El Count() previo (que obtiene el intervalo) no se cronometra.
   - *DSA-Index*: Se mide $r a n g e_min$(sp,ep) y  $r a n g e_max$(sp,ep) juntos (el descenso sobre la gramática aumentada con metadatos, sin enumerar ocurrencias).
   - El número reportado por dataset es el promedio de todas las queries de ese dataset. 
 + Patrones 
   - Para los datasets de synth, influenza y ecoli, fueron 1000 patrones iniciales, 100 pb cada uno, extraidos aleatoriamente del texto (random.seed(42)). Las queries efectivas fueron 2890/ 1000/ 1000 MEMs respectivamente. El intervalo [sp,ep] se generó a partir de ropebwt3 mem -l40, el cual busca MEMs del patrón contra toda la colección. Un patrón puede generar 0,1 o varios MEMs. Para los datasets einstein y worldleaders, los patrones iniciales consistieron en 1000 substrings de 100 caracteres, con posiciones random sobre el texto linealizado (sin \\n). No se usó ropebwt3 para generar el intervalo, se usó Count() del sr-index sobre el substring completo para obtener el [sp,ep] real. Todos los patrones/MEMs se comparten entre baseline y DSA-index, mismos intervalos y mismo hardware. 

 + Espacio: Como unidad de medida principal es bps (bits per symbol). Es la métrica estandar para comparar índices de distinto tamaño de texto en la misma escala. La unidad secundaria es MB absolutos, es util para dimensionar el costo real en memoria. Se mide y se comparan DSA-index y sr-index, variando en este último su parametro para el trade-off espacio-tiempo s (s=8 y s=16). Este parametro es la tasa de sampling del Suffix Array del sr-index: cada cuántas posiciones se guarda un valor explícito de SA: 
   - s=8: un valor explícito cada 8 posiciones, lo que quiere decir que hay mas samples guardados, y mas espacio, pero Locate() es más rápido.

   - s=16: la mitad de samples, por lo que ocupa menos espacio pero Locate() es más lento.  

#pagebreak()
  == Resultados
  === Tradeoff espacio-tiempo global
   #figure(
  image("imagenes/grafico1a_tradeoff_espacio_tiempo.png", width: 100%),
  caption: [Tradeoff espacio tiempo: synth, influenza y ecoli],
) <fig:etiqueta>


 #figure(
  image("imagenes/grafico1b_tradeoff_espacio_tiempo.png", width: 100%),
  caption: [Tradeoff espacio tiempo: einstein y worldleaders],
) <fig:etiqueta>

#pagebreak()
  === Tiempo vs número de ocurrencias 
   #figure(
  image("imagenes/grafico2_tiempo_vs_ocurrencias.png", width: 100%),
  caption: [Tiempo vs numero de ocurrencias para todos los datasets],
) <fig:etiqueta>

#pagebreak()
  === Desglose de espacio
     #figure(
  image("imagenes/grafico3_desglose_espacio.png", width: 100%),
  caption: [Desglose de espacio por dataset],
) <fig:etiqueta>
]

#capitulo(title: "Uso de inteligencia artificial")[
El desarrollo de esta memoria tuvó uso de IA generativa. La asistencia con IA fue precisamente eso: asistencia para arreglar problemas de sintaxis con typst (editor de texto que se usó para la confección de este informe), equivalencias entre typst y latex (en un principio este informe fue hecho con latex, pero se decidió moverse a typst por conveniencia y por problemas con el compilador de latex), entendimiento de conceptos complejos en papers de la biliografia, arreglo de bugs en C++, bosquejos y borradores de codigos para estructuras, y finalmente ayuda para gramatica, ortografía y coherencia en la redacción de este informe. Las sugerencias de parte de la IA no fueron aceptadas inmediatamente, antes pasó por un proceso de testing y comprobación de que realmente servían y contribuían para esta memoria. 

== Modelos usados 
]
#capitulo(title: "Conclusión")[
    == Conclusiones generales
    === Objetivo general
    == Objetivos especificos
    == Trabajo futuro
]

#show: end-doc

#apendice(title: "Anexo")[
   
]