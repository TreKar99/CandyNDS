@;=                                                          	     	=
@;=== candy1_init.s: rutinas para inicializar la matriz de juego	  ===
@;=                                                           	    	=
@;=== Programador tarea 1A: sergi.llobet@estudiants.urv.cat			  ===
@;=== Programador tarea 1B: germanangel.puerto@estudiants.urv.cat	  ===
@;=                                                       	        	=



.include "../include/candy1_incl.i"



@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
@; matrices de recombinación: matrices de soporte para generar una nueva matriz
@;	de juego recombinando los elementos de la matriz original.
	mat_recomb1:	.space ROWS*COLUMNS
	mat_recomb2:	.space ROWS*COLUMNS



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1A;
@; inicializa_matriz(*matriz, num_mapa): rutina para inicializar la matriz de
@;	juego, primero cargando el mapa de configuración indicado por parámetro (a
@;	obtener de la variable global 'mapas'), y después cargando las posiciones
@;	libres (valor 0) o las posiciones de gelatina (valores 8 o 16) con valores
@;	aleatorios entre 1 y 6 (+8 o +16, para gelatinas)
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocará la rutina
@;			'mod_random'
@;		* para evitar generar secuencias se invocará la rutina
@;			'cuenta_repeticiones' (ver fichero "candy1_move.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = número de mapa de configuración
	.global inicializa_matriz
inicializa_matriz:
		push {r2-r12, lr}			@; guardar registros utilizados
		
		mov r10, #ROWS				@; asignamos a r10 la constante "ROWS"
		mov r5, #COLUMNS			@; asignamos a r5 la constante "COLUMNS"
		mul r4, r10, r5				@; asignamos a r4 el total de elementos de una matriz
		mul r1, r4					@; multiplicamos el numero de mapa por 81 elementos para empezar en el mapa correspondiente
		ldr r3, =mapas				@; le asignamos a r3 la variable "mapas"
		add r3, r1					@; le sumamos a r3 las posiciones que contiene r1
		mov r4, r0					@; movemos la direccion de la matriz del juego 
		mov r9, #0					@; indice de fila
		
	.Lfila:
		mov r2, #0					@; indice de columna
		
	.Lbucle_matriu:	
		mla r6, r9, r5, r2			@; asignamos a r6 el indice de la posicion de la matriz
		add r7, r4, r6				@; apuntamos al valor de nuestra direccion base de la matriz de juego
		add r11, r3, r6				@; apuntamos al valor de la matriz del mapa
		ldrb r12, [r11]				@; en r12 obtenemos el valor de la direccion de r11
		ldrb r8, [r7]				@; en r8 obtenemos el valor de la direccion de r7
		cmp r12, #0					@; comparamos r12 con 0 y si es igual entramos a la mascara
		beq .Lmascara7
		cmp r12, #8					@; comparamos r12 con 8 y si es igual entramos a la mascara
		beq .Lmascara7
		cmp r12, #16				@; comparamos r12 con 16 y si es igual entramos a la mascara
		beq .Lmascara7	
		b .Lnomascara				@; en caso de que r12 no sea ninguno de los valores anteriores no queremos mascara
	
	.Lmascara7:
		mov r6, r12					@; asignamos a r6 el valor 12 para no perder el valor sin filtrar
		and r12, #7					@; aplicamos la mascara para convertir los 0, 8 o 16 a 0
		b .Lfer_random				@; saltamos al bucle para hacer el random
	
	.Lnomascara:
		strb r12, [r7]				@; guardamos el valor r12 en la direccion de r7
		add r2, #1					@; incrementamos el indice de columnas	
		cmp r2, r5					@; comparamos el indice de columnas con "COLUMNS"
		blo .Lbucle_matriu			@; cuando r2 sea igual que r5 no saltara a ".Lbucle_matriu"
		add r9, #1					@; incrementamos el indice de filas
		cmp r9, r10					@; comparamos el indice de filas con "ROWS"
		blo .Lfila					@; cuando r9 sea igual que r10 no saltara a ".Lfila"
		b .Lfinal					@; saltamos al bucle ".Lfinal" para acabar el procedimiento
		
	.Lfer_random:
		mov r0, #7					@; comparamos el registro r0 con 7 (que sera el maximo del rango)
		bl mod_random				@; saltamos a la rutina "mod_random" para obtener un numero aleatorio
		cmp r0, #0					@; comparamos el registro r0 con el valor 0
		beq .Lfer_random			@; ya que no queremos que el numero aleatorio sea otra vez 0
		add r0, r6					@; le sumamos a r0 el valor sin filtrar en r6
		mla r7, r9, r5, r2			@; asignamos a r7 el indice de la posicion de la matriz
		add r7, r4, r7				@; apuntamos al valor de nuestra direccion base de la matriz de juego
		strb r0, [r7]				@; guardamos el valor r0 en la direccion r7
		mov r11, r4					@; guardamos en r11 el valor de r4 para no perder el valor
		mov r0, r4					@; en r0 obtenemos el valor de r4 para poder entrar a la rutina "cuenta_repeticiones"
		mov r8, r1					@; guardamos en r8 el valor de r1 para no perder el valor
		mov r1, r9					@; en r1 obtenemos el valor de r9 que es el indice de filas
		mov r7, r3					@; guardamos en r7 el valor de r3 para no perder el valor
		mov r3, #2					@; asignamos a r3 el valor 2 que "cuenta_repeticiones" usara como orientacion
		bl cuenta_repeticiones		@; saltamos a la rutina "cuenta_repeticiones"
		mov r3, r7					@; devolvemos el valor de r7 a r3
		cmp r0, #3					@; comparamos r0 con el valor 3
		beq .Lfer_random			@; si el numero de repeticiones es 3, saltamos otra vez al bucle ".Lfer_random"
		mov r0, r4					@; devolvemos el valor de r4 a r0
		mov r3, #3					@; asignamos a r3 el valor 3 que "cuenta_repeticiones" usara como orientacion
		bl cuenta_repeticiones		@; saltamos a la rutina "cuenta_repeticiones"
		mov r3, r7					@; devolvemos el valor de r7 a r3
		cmp r0, #3					@; comparamos r0 con el valor 3
		beq .Lfer_random			@; si el numero de repeticiones es 3, saltamos otra vez al bucle ".Lfer_random"
		mov r9, r1					@; devolvemos el valor de r1 a r9
		mov r1, r8					@; devolvemos el valor de r8 a r1
		mov r4, r11					@; devolvemos el valor de r11 a r4
		add r2, #1					@; incrementamos el indice de columnas
		mov r5, #COLUMNS			@; asignamos al registro r5 el valor el maximo de columnas		
		cmp r2, r5					@; comparamos el indice de columnas con "COLUMNS" 
		blo .Lbucle_matriu			@; cuando r2 sea igual que r5 no saltara a ".Lbucle_matriu"
		add r9, #1					@; incrementamos el indice de filas
		mov r10, #ROWS				@; asignamos al registro r10 el valor el maximo de filas
		cmp r9, r10					@; comparamos el indice de filas con "ROWS"
		blo .Lfila					@; cuando r9 sea igual que r10 no saltara a ".Lfila"
		
	.Lfinal:				
	
		pop {r2-r12, pc}			@;recuperar registros y volver



@;:::RUTINAS DE SOPORTE:::



@; mod_random(n): rutina para obtener un número aleatorio entre 0 y n-1,
@;	utilizando la rutina 'random'
@;	Restricciones:
@;		* el parámetro 'n' tiene que ser un valor entre 2 y 255, de otro modo,
@;		  la rutina lo ajustará automáticamente a estos valores mínimo y máximo
@;	Parámetros:
@;		R0 = el rango del número aleatorio (n)
@;	Resultado:
@;		R0 = el número aleatorio dentro del rango especificado (0..n-1)
	.global mod_random
mod_random:
		push {r1-r4, lr}

		cmp r0, #2					@;compara el rango de entrada con el mínimo
		bge .Lmodran_cont
		mov r0, #2					@;si menor, fija el rango mínimo
	.Lmodran_cont:
		and r0, #0xff				@;filtra los 8 bits de menos peso
		sub r2, r0, #1				@;R2 = R0-1 (número más alto permitido)
		mov r3, #1					@;R3 = máscara de bits
	.Lmodran_forbits:
		cmp r3, r2					@;genera una máscara superior al rango requerido
		bhs .Lmodran_loop
		mov r3, r3, lsl #1
		orr r3, #1					@;inyecta otro bit
		b .Lmodran_forbits
		
	.Lmodran_loop:
		bl random					@;R0 = número aleatorio de 32 bits
		and r4, r0, r3				@;filtra los bits de menos peso según máscara
		cmp r4, r2					@;si resultado superior al permitido,
		bhi .Lmodran_loop			@; repite el proceso
		mov r0, r4					@; R0 devuelve número aleatorio restringido a rango
		cmp r0, #0
		beq mod_random
		
		
		pop {r1-r4, pc}



@; random(): rutina para obtener un número aleatorio de 32 bits, a partir de
@;	otro valor aleatorio almacenado en la variable global 'seed32' (declarada
@;	externamente)
@;	Restricciones:
@;		* el valor anterior de 'seed32' no puede ser 0
@;	Resultado:
@;		R0 = el nuevo valor aleatorio (también se almacena en 'seed32')
random:
	push {r1-r5, lr}
		
	ldr r0, =seed32					@;R0 = dirección de la variable 'seed32'
	ldr r1, [r0]					@;R1 = valor actual de 'seed32'
	ldr r2, =0x0019660D 
	ldr r3, =0x3C6EF35F
	umull r4, r5, r1, r2
	add r4, r3						@;R5:R4 = nuevo valor aleatorio (64 bits)
	str r4, [r0]					@;guarda los 32 bits bajos en 'seed32'
	mov r0, r5						@;devuelve los 32 bits altos como resultado
		
	pop {r1-r5, pc}	






@;TAREA 1B;
@; recombina_elementos(*matriz): rutina para generar una nueva matriz de juego
@;	mediante la reubicación de los elementos de la matriz original, para crear
@;	nuevas jugadas.
@;	Inicialmente se copiará la matriz original en 'mat_recomb1', para luego ir
@;	escogiendo elementos de forma aleatoria y colocandolos en 'mat_recomb2',
@;	conservando las marcas de gelatina.
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocará la rutina
@;			'mod_random'
@;		* para evitar generar secuencias se invocará la rutina
@;			'cuenta_repeticiones' (ver fichero "candy1_move.s")
@;		* para determinar si existen combinaciones en la nueva matriz, se
@;			invocará la rutina 'hay_combinacion' (ver fichero "candy1_comb.s")
@;		* se supondrá que siempre existirá una recombinación sin secuencias y
@;			con combinaciones
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
	.global recombina_elementos
recombina_elementos:
		push {r0-r12, lr}
		
		mov r9, r0					@; R9 = direccion base matrix
		ldr r5, =mat_recomb1		@; R5 = direccion mat_recomb1 (0-6)
		ldr r6, =mat_recomb2		@; R6 = direccion mat_recomb2 (7-15/8-16)

	@; Códigos básicos -> mat_recomb1
	.LInicio:
		mov r2, #0					@; R2 = ROWS
		mov r3, #0					@; R3 = COLUMNS
		
	.LForJ1:
		cmp r3, #COLUMNS			@; Recorremos la matriz de juego
		beq .LForI1
		
		mov r4, #COLUMNS
		mla r4, r2, r4, r3			@; R4 = i*NC + j
		ldrb r7, [r9, r4]
		and r7, #7
		cmp r7, #7
		moveq r7, #0
		strb r7, [r5, r4]
		add r3, #1
		
		b .LForJ1
		
	.LForI1:
		add r2, #1
		cmp r2, #ROWS
		beq .LContinue1
		mov r3, #0
		
		b .LForJ1
		
	@; Gelatinas -> mat_recomb2
	.LContinue1:
		mov r2, #0					@; R2 = ROWS
		mov r3, #0					@; R3 = COLUMNS
		
	.LForJ2:
		cmp r3, #COLUMNS			@; Recorremos la matriz de juego
		beq .LForI2
		
		mov r4, #COLUMNS
		mla r4, r2, r4, r3			@; R4 = i*NC + j
		ldrb r7, [r9, r4]
		cmp r7, #7
		beq .LStore
		cmp r7, #15
		beq .LStore
		bic r7, #7
	.LStore:
		strb r7, [r6, r4]
		add r3, #1
		
		b .LForJ2
		
	.LForI2:
		add r2, #1
		cmp r2, #ROWS
		beq .LContinue2
		mov r3, #0
		
		b .LForJ2
	
	@; Recorrido matriz aleatoria
	.LContinue2:
		mov r12, #0				@; R12 = CONTADOR
		
		mov r2, #0				@; R2 = fila destino (matriz)
		mov r3, #0				@; R3 = columna destino (matriz)
		
		@; Recorrer Matriz
	.LForJ3:
		cmp r3, #COLUMNS			@; Recorremos la matriz de juego
		beq .LForI3
		
		mov r4, #COLUMNS
		mla r4, r2, r4, r3			@; R4 = i*NC + j
		ldrb r7, [r9, r4]
		cmp r7, #7
		beq .LFor3Continue
		cmp r7, #15
		beq .LFor3Continue
		and r7, #7
		cmp r7, #0
		beq .LFor3Continue
		
	.LRandom:
		@; Coger 1 random de mat_recomb1
		@; Random de ROWS y random de COLUMNS
		mov r0, #COLUMNS+1
		bl mod_random
		sub r0, #1
		mov r1, r0				@; R1 = columna origen (mat_recomb1)
		mov r0, #ROWS+1
		bl mod_random			@; R0 = fila origen (mat_recomb1)
		sub r0, #1
		
		mov r7, #COLUMNS
		mla r7, r0, r7, r1
		ldrb r7, [r5, r7]
		cmp r7, #0
		beq .LRandom
	
	@; Juntar código r7 (aleatorio de mat_recomb1) con posicion (mat_recomb2)
		ldrb r8, [r6, r4]		@; R8 = gelatina
		orr r7, r7, r8
		strb r7, [r6, r4]
	@; Comprobar secuencias verticales y horizontales
	@; Si hay secuencia restar r7 a posicion -> LRandom
		bl comprobar_secuencias
		cmp r10, #0
		beq .LFijarPosicion
	
	.LRestituir:
		add r12, #1
		cmp r12, #2048
		beq .LInicio
		strb r8, [r6, r4]	
		b .LRandom
	
	.LFijarPosicion:
	@; Poner a 0 posicion aleatoria (mat_recomb1)
		mov r7, #0
		mov r11, #COLUMNS
		mla r11, r0, r11, r1
		strb r7, [r5, r11]
		bl activa_elemento
	@; PONER ACTIVA ELEMENTO
	.LFor3Continue:
	@; PONER ACTIVA ELEMENTO (NO PQ SE HARIA EN TODAS)
		add r3, #1
		
		b .LForJ3
		
	.LForI3:
		add r2, #1
		cmp r2, #ROWS
		beq .LContinue3
		mov r3, #0
		
		b .LForJ3

	.LContinue3:
		mov r2, #0					@; R2 = ROWS
		mov r3, #0					@; R3 = COLUMNS
		
	.LForJ4:
		cmp r3, #COLUMNS			@; Recorremos la matriz de juego
		beq .LForI4
		
		mov r4, #COLUMNS
		mla r4, r2, r4, r3			@; R4 = i*NC + j
		ldrb r7, [r6, r4]
		strb r7, [r9, r4]
		add r3, #1
		
		b .LForJ4
		
	.LForI4:
		add r2, #1
		cmp r2, #ROWS
		beq .LFin
		mov r3, #0
		
		b .LForJ4
		
	.LFin:
		pop {r0-r12, pc}
	
@; comprobar_secuencias(*mat_recomb2, fila, columna): rutina para generar una nueva matriz de juego
@;	mediante la reubicación de los elementos de la matriz original, para crear
@;	nuevas jugadas.
@; Parámetros:
@; 	R6 = direccion base matriz comprovante
@; 	R2 = fila
@; 	R3 = columna
@; Output:
@;	R10 = secuencia/no secuencia

comprobar_secuencias:
		push {r0-r8, lr}
		
		mov r1, r2			@; R1 = fila
		mov r2, r3			@; R2 = columna
		mov r3, #0			@; R3 = ori
		mov r10, #0			@; R4 = secuencia/no secuencia
	.LFor:
		mov r0, r6			@; R0 = direccion mat_recomb2
		cmp r3, #4			@; Si ori = 4 no hay secuencias
		beq .LNoSecuence
		
		bl cuenta_repeticiones
		cmp r0, #3
		bhs .LSecuence		@; Si R0 >= 3 hay secuencia
		
		add r3, #1
		b .LFor
	
	.LSecuence:
		mov r10, #1
	.LNoSecuence:
		
		pop {r0-r8, pc}

.end



