.data
	texto: .asciz "los hobbits son un pueblo sencillo y muy antiguo mas numeroso en tiempos remotos que en la actualidad amaban la paz la tranquilidad y el cultivo de la buena tierra y no habia para ellos paraje mejor que un campo bien aprovechado y bien ordenado no entienden ni entendian ni gustan de maquinarias mas complicadas que una fragua un molino de agua o un telar de mano aunque fueron muy habiles con toda clase de herramientas en otros tiempos desconfiaban en general de la gente grande como nos llaman y ahora nos eluden con terror y es dificil encontrarlos tienen el oido agudo y la mirada penetrante y aunque engordan facilmente y nunca se apresuran si no es necesario se mueven con agilidad y destreza dominaron desde un principio el arte de desaparecer rapido y en silencio cuando la gente grande con la que no querian tropezar se les acercaba casualmente y han desarrollado este arte hasta el punto de que a los hombres puede parecerles verdadera magia pero los hobbits jamas han estudiado magia de ninguna indole y esas rapidas desapariciones se deben unicamente a una habilidad profesional que la herencia la practica y una intima amistad con la tierra han desarrollado tanto que es del todo inimitable para las razas mas grandes y desmayadas hola"


    archivo_salida: .asciz "texto_procesado.txt"    @ Nombre del archivo de salida
    
    .text
    .global _start

_start:
    LDR R0, =texto         
    SUB SP, SP, #4000
    MOV R1, SP
    	MOV R8, #1           
    BL procesar_texto         
	BL apariciones_palabra
	BL escribir_archivo
    MOV R7, #1    
	MOV R0, #0              
    SWI 0

procesar_texto:
    PUSH {R4, R5, R6, R7, LR}
    MOV R4, #0                  
    MOV R5, #0                  
	MOV R8, #0
	
recorrer_texto:
    LDRB R6, [R0, R4]    
	CMP R6, #0x23              
    BEQ continuar 
	CMP R6, #' '                
    BEQ nueva_palabra        
    CMP R6, #0                  
    BEQ fin_texto                                       
	STRB R6, [R1, R5]           
    ADD R4, R4, #1              
    ADD R5, R5, #1              
    MOV R8, #1
	B recorrer_texto            

continuar: 
	ADD R4, R4, #1
	B recorrer_texto

fin_texto:
	CMP R8, #0
	BEQ escribir_archivo
	B nueva_palabra
	
nueva_palabra:
    SUB R4, R4, #1                
    LDRB R6, [R0, R4]        
    CMP R6, #0x23
	ADD R4, R4, #2
  	MOV R2, R5
	MOV R6, #0
	STRB R6, [R1, R5]
	BEQ recorrer_texto

apariciones_palabra:
	PUSH {R4, R5, R6, R7, LR}
	MOV R3, #0
	MOV R4, #0
	MOV R5, #0
	
caracter_siguiente:
	LDRB R6, [R0, R4]
	CMP R6, #0
	BEQ completado
	LDRB R7, [R1, R5]
	CMP R6, R7
	BEQ son_iguales
	MOV R5, #0
	BNE siguiente_palabra

son_iguales:
	ADD R4, R4, #1
	ADD R5, R5, #1
	LDRB R6, [R0, R4]
	LDRB R7, [R1, R5]
	CMP R6, #' '
	BEQ encontrar_igual
	CMP R6, #0
	BEQ encontrar_igual
	BNE caracter_siguiente
	
siguiente_palabra:
	ADD R4, R4, #1
	LDRB R6, [R0, R4]
	CMP R6, #' '
	BEQ continuar_caracter
	CMP R6, #0x23
	BEQ continuar_caracter
	CMP R6, #0
	BEQ completado
	BNE siguiente_palabra
	
continuar_caracter:
	ADD R4, R4, #1
	LDRB R6, [R0, R4]
	CMP R6, #' '
	BNE caracter_siguiente
	ADD R4, R4, #1
	B caracter_siguiente
	
encontrar_igual:
	CMP R7, #0
	BEQ encontrar_igual_aux
	CMP R7, #0xaa
	BEQ encontrar_igual_aux
	B caracter_siguiente
	
encontrar_igual_aux:
	ADD R3, R3, #1
	MOV R5, #0
	ADD R9, R0, R4
	SUB R9, R9, R2
	MOV R10, #0x23
	
cambiar_palabra:
	STRB R10, [R9, R5]
	ADD R5, R5, #1
	CMP R5, R2
	BNE cambiar_palabra
	
reinicio:
	ADD R4, R4, #1
	MOV R5, #0
	MOV R9, #0
	B caracter_siguiente

completado:
	POP {R4, R5, R6, R7, LR}
	MOV R11, #0
	STRB R11, [R1, R2]
	ADD R2, R2, #1
	STRB R3, [R1, R2]
	ADD R2, R2, #1
	STRB R11, [R1, R2]
	ADD R2, R2, #1
	ADD R1, R1, R2
	MOV R2, #0
	B procesar_texto
	
escribir_archivo:
    MOV R7, #5                      
    LDR R0, =archivo_salida         
    MOV R1, #0101                    
    MOV R2, #0x1B                   
    ORR R2, R2, #0x6                
    SWI 0                          
    CMP R0, #0              
    BLT error                     
    MOV R4, R0 

    MOV R1, SP              
    MOV R2, #4000                 
    MOV R7, #4                   
    MOV R0, R4                    
    SWI 0                        

cerrar_archivo:
    MOV R7, #6                      
    MOV R0, R4                      
    SWI 0

error:
    MOV R7, #1                      
    MOV R0, #1                      
    SWI 0

salida:
    MOV R7, #1                      
    MOV R0, #0                      
    SWI 0
