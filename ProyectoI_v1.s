.data
	texto: .asciz "los hobbits son un pueblo sencillo y muy antiguo mas numeroso en tiempos remotos que en la actualidad amaban la paz la tranquilidad y el cultivo de la buena tierra y no habia para ellos paraje mejor que un campo bien aprovechado y bien ordenado no entienden ni entendian ni gustan de maquinarias mas complicadas que una fragua un molino de agua o un telar de mano aunque fueron muy habiles con toda clase de herramientas en otros tiempos desconfiaban en general de la gente grande como nos llaman y ahora nos eluden con terror y es dificil encontrarlos tienen el oido agudo y la mirada penetrante y aunque engordan facilmente y nunca se apresuran si no es necesario se mueven con agilidad y destreza dominaron desde un principio el arte de desaparecer rapido y en silencio cuando la gente grande con la que no querian tropezar se les acercaba casualmente y han desarrollado este arte hasta el punto de que a los hombres puede parecerles verdadera magia pero los hobbits jamas han estudiado magia de ninguna indole y esas rapidas desapariciones se deben unicamente a una habilidad profesional que la herencia la practica y una intima amistad con la tierra han desarrollado tanto que es del todo inimitable para las razas mas grandes y desmayadas hola"


    archivo_salida: .asciz "texto_procesado.txt"    @ Nombre del archivo de salida
    
.text
.global _start

_start:
    LDR R0, =texto          @ Cargar la dirección del texto en R0
    SUB SP, SP, #4000        @ Reservar 4000 bytes en la pila
    MOV R1, SP              @ Usar el espacio reservado como buffer en R1
    MOV R8, #1              @ Inicializar R8 como indicador de control
    BL procesar_texto       @ Llamar a la función que procesa el texto
    BL apariciones_palabra   @ Llamar a la función que cuenta apariciones de palabras
    BL escribir_archivo     @ Llamar a la función que escribe el archivo
    MOV R7, #1              @ Preparar la salida del programa
    MOV R0, #0              @ Código de salida = 0
    SWI 0                   @ Llamada al sistema para salir del programa

procesar_texto:
    PUSH {R4, R5, R6, R7, LR} @ Guardar registros en la pila
    MOV R4, #0               @ Inicializar índice del texto (R4)
    MOV R5, #0               @ Inicializar índice del buffer (R5)
    MOV R8, #0               @ Inicializar flag de nueva palabra (R8)

recorrer_texto:
    LDRB R6, [R0, R4]        @ Cargar el siguiente byte del texto en R6
    CMP R6, #0x23            @ Comparar con '#'
    BEQ continuar            @ Si es '#', saltar a continuar
    CMP R6, #' '             @ Comparar con espacio
    BEQ nueva_palabra         @ Si es un espacio, es una nueva palabra
    CMP R6, #0               @ Comprobar fin de texto (null byte)
    BEQ fin_texto            @ Si fin de texto, ir a fin_texto
    STRB R6, [R1, R5]        @ Guardar el byte en el buffer
    ADD R4, R4, #1           @ Incrementar índice del texto
    ADD R5, R5, #1           @ Incrementar índice del buffer
    MOV R8, #1               @ Marcar que se ha leído una palabra
    B recorrer_texto         @ Volver a recorrer_texto para continuar

continuar:
    ADD R4, R4, #1           @ Continuar leyendo el texto
    B recorrer_texto         @ Volver a recorrer_texto

fin_texto:
    CMP R8, #0               @ Comprobar si se ha procesado una palabra
    BEQ escribir_archivo     @ Si no se ha procesado, ir a escribir_archivo
    B nueva_palabra          @ Si hay palabra, procesar nueva palabra

nueva_palabra:
    SUB R4, R4, #1           @ Retroceder un carácter
    LDRB R6, [R0, R4]        @ Cargar el último carácter leído
    CMP R6, #0x23            @ Comparar con '#'
    ADD R4, R4, #2           @ Avanzar dos posiciones en el texto
    MOV R2, R5               @ Guardar el índice actual del buffer en R2
    MOV R6, #0               @ Escribir un carácter nulo para terminar la palabra
    STRB R6, [R1, R5]        @ Terminar la palabra en el buffer
    BEQ recorrer_texto       @ Volver a recorrer el texto

apariciones_palabra:
    PUSH {R4, R5, R6, R7, LR} @ Guardar registros en la pila
    MOV R3, #0               @ Inicializar contador de apariciones
    MOV R4, #0               @ Inicializar índice del texto
    MOV R5, #0               @ Inicializar índice del buffer

caracter_siguiente:
    LDRB R6, [R0, R4]        @ Cargar el siguiente carácter del texto
    CMP R6, #0               @ Comprobar si es fin de texto
    BEQ completado           @ Si es fin, ir a completado
    LDRB R7, [R1, R5]        @ Cargar el siguiente carácter del buffer
    CMP R6, R7               @ Comparar los caracteres de texto y buffer
    BEQ son_iguales          @ Si son iguales, ir a son_iguales
    MOV R5, #0               @ Reiniciar índice del buffer si no coinciden
    BNE siguiente_palabra     @ Continuar con la siguiente palabra

son_iguales:
    ADD R4, R4, #1           @ Avanzar en el texto
    ADD R5, R5, #1           @ Avanzar en el buffer
    LDRB R6, [R0, R4]        @ Cargar el siguiente carácter del texto
    LDRB R7, [R1, R5]        @ Cargar el siguiente carácter del buffer
    CMP R6, #' '             @ Comparar con espacio
    BEQ encontrar_igual       @ Si hay un espacio, ir a encontrar_igual
    CMP R6, #0               @ Comprobar fin de texto
    BEQ encontrar_igual       @ Si fin de texto, ir a encontrar_igual
    BNE caracter_siguiente    @ Continuar con la siguiente comparación

siguiente_palabra:
    ADD R4, R4, #1           @ Avanzar en el texto
    LDRB R6, [R0, R4]        @ Cargar el siguiente carácter
    CMP R6, #' '             @ Comparar con espacio
    BEQ continuar_caracter    @ Si es espacio, ir a continuar_caracter
    CMP R6, #0x23            @ Comparar con '#'
    BEQ continuar_caracter    @ Si es '#', ir a continuar_caracter
    CMP R6, #0               @ Comprobar fin de texto
    BEQ completado            @ Si fin de texto, ir a completado
    BNE siguiente_palabra     @ Continuar con la siguiente palabra

continuar_caracter:
    ADD R4, R4, #1           @ Avanzar en el texto
    LDRB R6, [R0, R4]        @ Cargar el siguiente carácter
    CMP R6, #' '             @ Comparar con espacio
    BNE caracter_siguiente    @ Si no es espacio, volver a comparar caracteres
    ADD R4, R4, #1           @ Avanzar en el texto
    B caracter_siguiente      @ Volver a la comparación de caracteres

encontrar_igual:
    CMP R7, #0               @ Comprobar si es fin de palabra
    BEQ encontrar_igual_aux   @ Si fin de palabra, ir a encontrar_igual_aux
    CMP R7, #0xaa            @ Comparar con valor especial
    BEQ encontrar_igual_aux   @ Si coincide, ir a encontrar_igual_aux
    B caracter_siguiente      @ Continuar la comparación de caracteres

encontrar_igual_aux:
    ADD R3, R3, #1           @ Incrementar el contador de palabras encontradas
    MOV R5, #0               @ Reiniciar el índice del buffer
    ADD R9, R0, R4           @ Calcular la posición actual del texto
    SUB R9, R9, R2           @ Calcular la longitud de la palabra
    MOV R10, #0x23           @ Asignar el carácter '#' como reemplazo

cambiar_palabra:
    STRB R10, [R9, R5]       @ Reemplazar la palabra por '#'
    ADD R5, R5, #1           @ Avanzar en la palabra
    CMP R5, R2               @ Comparar con la longitud de la palabra
    BNE cambiar_palabra       @ Continuar cambiando la palabra

reinicio:
    ADD R4, R4, #1           @ Avanzar en el texto
    MOV R5, #0               @ Reiniciar el índice del buffer
    MOV R9, #0               @ Reiniciar R9
    B caracter_siguiente      @ Volver a comparar caracteres

completado:
    POP {R4, R5, R6, R7, LR} @ Restaurar registros desde la pila
    MOV R11, #0              @ Finalizar la palabra en el buffer
    STRB R11, [R1, R2]       @ Escribir byte nulo en el buffer
    ADD R2, R2, #1           @ Avanzar el índice del buffer
    STRB R3, [R1, R2]        @ Escribir el contador de apariciones
    ADD R2, R2, #1           @ Avanzar el índice del buffer
    STRB R11, [R1, R2]       @ Escribir byte nulo en el buffer
    ADD R2, R2, #1           @ Avanzar el índice del buffer
    ADD R1, R1, R2           @ Avanzar el puntero del buffer
    MOV PC, LR               @ Retornar

escribir_archivo:
    MOV R7, #5               @ Llamada al sistema para abrir archivo
    LDR R0, =archivo_salida  @ Dirección del archivo de salida
    MOV R1, #0101            @ Flags: abrir archivo en modo escritura
    MOV R2, #0x1B            @ Permisos de lectura y escritura
    ORR R2, R2, #0x6         @ Permitir permisos adicionales
    SWI 0                    @ Llamada al sistema para abrir el archivo
    CMP R0, #0               @ Comprobar si hubo error al abrir
    BLT error                @ Si error, saltar a la etiqueta 'error'
    MOV R4, R0               @ Guardar el descriptor de archivo en R4 y escribir en el archivo

error:
    MOV R7, #1               @ Llamada al sistema para salir
    MOV R0, #0               @ Código de salida
    SWI 0                    @ Salir del programa