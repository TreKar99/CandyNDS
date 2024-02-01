@;=                                                               		=
@;=== candy1_secu.s: rutinas para detectar y elimnar secuencias 	  ===
@;=                                                             	  	=
@;=== Programador tarea 1C: ivan.garciap@estudiants.urv.cat				  ===
@;=== Programador tarea 1D: ivan.garciap@estudiants.urv.cat				  ===
@;=                                                           		   	=



.include "../include/candy1_incl.i"



@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
@; número de secuencia: se utiliza para generar números de secuencia únicos,
@;	(ver rutinas 'marcar_horizontales' y 'marcar_verticales') 
	num_sec:	.space 1



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1C;
@; hay_secuencia(*matriz): rutina para detectar si existe, por lo menos, una
@;	secuencia de tres elementos iguales consecutivos, en horizontal o en
@;	vertical, incluyendo elementos en gelatinas simples y dobles.
@;	Restricciones:
@;		* para detectar secuencias se invocará la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 si hay una secuencia, 0 en otro caso
	.global hay_secuencia
hay_secuencia:
		push {r1-r3, r5-r11, lr}
		
		
		mov r2, #0 @;Columnas inicializadas
		mov r8, #ROWS @;hacemos la resta de los limites de las tablas (filas)
		sub r8, #2
		mov r9, #COLUMNS @; hacemos la resta de los limites de las tablas (columnas)
		sub r9, #2
		mov r10, #0 @; inicializamos el contador para saber despues si hay o no repeticiones
		mov r7, r0
		mov r0, #0
		
		
		.For:
		cmp r2, #COLUMNS @; comparamos i con columnas y  miramos q sea menor
		bhs .FiFor
		
		mov r1, #0 @;Filas inicializadas
		.For2:
		cmp r1, #ROWS @; inicializamos j a 0 para el for de las filas
		bhs .FiFor2
		mov r11, #COLUMNS
		mla r6, r1, r11, r2 @;posicion
		add r6, r7
		ldrb r5, [r6]
		and r5, #7
		cmp r5, #0
		beq .Lif	;@ comprovamos que la posicion no este en un 0, 8 o 16
		cmp r5, #7
		beq .Lif	;@ comprovamos que la posicion no este en un 0, 8 o 16
		cmp r5, #15
		beq .Lif	;@ comprovamos que la posicion no este en un 0, 8 o 16
		
		
		@; contar las dos reps
		cmp r1, r8
		bhi .Fin1 
		cmp r2, r9
		bhi .Fin1
		mov r0, r7
		mov r3, #0
		bl cuenta_repeticiones  @; el cero es a la derecha y el uno hacia abajo
		cmp r0, #3
		bhs .Final
		
		
		mov r0, r7
		mov r3, #1
		bl cuenta_repeticiones
		cmp r0, #3
		bhs .Final
		
		.Fin1:
		@; contar solo las reps de la parte derecha (solo hacia abajo)
		cmp r1, r8
		bls .Fin2
		cmp r2, r9
		bhi .Fin2
		mov r0, r7
		mov r3, #0
		bl cuenta_repeticiones
		cmp r0, #3
		bhs .Final

		
		.Fin2:
		@; contar solo las reps de la parte de abajo (solo hacia la derecha)
		cmp r2, r9
		bls .Fin3
		cmp r1, r8
		bhi .Fin3
		mov r0, r7
		mov r3, #1
		bl cuenta_repeticiones
		cmp r0, #3
		bhs .Final

		
		.Fin3:
		.Lif:	;@ llegamos aqui directamente si la posicion es un 0, 8 o 16
		add r1, #1 @; incrementamos j para las filas
		b .For2
		.FiFor2:
		
		add r2, #1 @; incrementamos i para las columnas
		b .For
		.FiFor:
		
		
		@; se devuelve el valor de r0=0 si el contador es 0 o r0=1 si
		mov r0, #0
		b .Pass
		.Final:
		mov r0, #1
		.Pass:
		
		pop {r1-r3, r5-r11, pc}



@;TAREA 1D;
@; elimina_secuencias(*matriz, *marcas): rutina para eliminar todas las
@;	secuencias de 3 o más elementos repetidos consecutivamente en horizontal,
@;	vertical o combinaciones, así como de reducir el nivel de gelatina en caso
@;	de que alguna casilla se encuentre en dicho modo; 
@;	además, la rutina marca todos los conjuntos de secuencias sobre una matriz
@;	de marcas que se pasa por referencia, utilizando un identificador único para
@;	cada conjunto de secuencias (el resto de las posiciones se inicializan a 0). 
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección de la matriz de marcas

			.global elimina_secuencias
elimina_secuencias:
		push {r0-r12, lr}
		
		mov r10, r0
		mov r11, r1
		mov r6, #0
		mov r8, #0				@;R8 es desplazamiento posiciones matriz
	.Lelisec_for0:
		strb r6, [r1, r8]		@;poner matriz de marcas a cero
		add r8, #1
		cmp r8, #ROWS*COLUMNS
		blo .Lelisec_for0
		
		bl marcar_horizontales
		mov r0, r10
		bl marcar_verticales
		

@; ATENCIÓN: FALTA CÓDIGO PARA ELIMINAR SECUENCIAS MARCADAS Y GELATINAS
		
		
		
		mov r10, #0 @;filas inicializadas
		mov r7, r0 @;en r7 se guarda la direccion de la matriz del juego
		mov r8, r1 @;en r8 se guarda la matriz que las copias
		mov r0, #0
		
		.Repeticion1:
		cmp r10, #ROWS @; comparamos i con filas y  miramos q sea menor
		bhs .FiRepeticion
		mov r9, #0 @;columnas inicializadas
		.Repeticion2:
		cmp r9, #COLUMNS @; inicializamos j a 0 para el for de las filas
		bhs .FiRepeticion2
		mov r11, #COLUMNS
		mla r6, r10, r11, r9 @;posicion
		add r6, r8
		ldrb r5, [r6]
		cmp r5, #0
		beq .Lsec		
		@;FOR PARA EL CODIGO
		
		mla r6, r10, r11, r9 @;posicion
		add r6, r7
		ldrb r5, [r6]	@; saltamos si es 8 o 16
		cmp r5, #16
		bne .Sust0
	.Sust1:
		mov r4, #8
		strb r4, [r6]	@;metemos un valor que queremos en la matriz de 0
		
		b .Lsec
		.Sust0:
		
		cmp r5, #8
		beq .Sust1
		
		@; -------------FASE Ib-------------
		
		ldrb r5, [r6]	@; volvemos a sacar el valor para mirar si hay gelatina
		cmp r5, #7
		bls .Pasar
		cmp r5, #15
		bls .Pasar1
		
		mov r5, #8
		strb r5, [r6]
		
		mov r0, #0x06000000
		mov r1, r10		@; pasamos la fila del elemento a r1
		mov r2, r9		@; pasamos la columna del elemento a r2
		bl elimina_gelatina	@; si se cumple llamames al elimina gelatina
		
		mov r0, r10		@; pasamos la fila del elemento a r0
		mov r1, r9		@; pasamos la columna del elemento a r2
		bl elimina_elemento
		
		b .Lsec
	.Pasar1:
		mov r0, #0x06000000
		mov r1, r10		@; pasamos la fila del elemento a r1
		mov r2, r9		@; pasamos la columna del elemento a r2
		bl elimina_gelatina	@; si se cumple llamames al elimina gelatina
		
	.Pasar:
		mov r0, r10		@; pasamos la fila del elemento a r0
		mov r1, r9		@; pasamos la columna del elemento a r2
		bl elimina_elemento
		
		@; ---------------------------------
		
		mov r4, #0
		strb r4, [r6]	@;metemos un valor que queremos en la matriz de 0
		
		@;FOR PARA EL CODIGO
		
		.Lsec:	;@ llegamos aqui directamente si la posicion es un 0, 8 o 16
		add r9, #1 @; incrementamos j para las COLUMNAS
		b .Repeticion2
		.FiRepeticion2:
		
		add r10, #1 @; incrementamos i para las FILAS
		b .Repeticion1
		.FiRepeticion:
		
		mov r0, r7
		pop {r0-r12, pc}
		


	
@;:::RUTINAS DE SOPORTE:::



@; marcar_horizontales(mat): rutina para marcar todas las secuencias de 3 o más
@;	elementos repetidos consecutivamente en horizontal, con un número identifi-
@;	cativo diferente para cada secuencia, que empezará siempre por 1 y se irá
@;	incrementando para cada nueva secuencia, y cuyo último valor se guardará en
@;	la variable global 'num_sec'; las marcas se guardarán en la matriz que se
@;	pasa por parámetro 'mat' (por referencia).
@;	Restricciones:
@;		* se supone que la matriz 'mat' está toda a ceros
@;		* para detectar secuencias se invocará la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección de la matriz de marcas
marcar_horizontales:
		push {r0-r12, lr}
		
		mov r10, #0 @;filas inicializadas
		mov r7, r0 @;en r7 se guarda la direccion de la matriz del juego
		mov r8, r1 @;en r8 se guarda la matriz que las copias
		mov r0, #0
		mov r12, #0
		
		.Rep1:
		cmp r10, #ROWS @; comparamos i con filas y  miramos q sea menor
		bhs .FiRep
		mov r9, #0 @;columnas inicializadas
		.Rep2:
		cmp r9, #COLUMNS @; inicializamos j a 0 para el for de las filas
		bhs .FiRep2
		mov r11, #COLUMNS
		mla r6, r10, r11, r9 @;posicion
		add r6, r7
		ldrb r5, [r6]
		and r5, #7
		cmp r5, #0
		beq .Lsi	;@ comprovamos que la posicion no este en un 0, 8 o 16
		cmp r5, #7
		beq .Lsi	;@ comprovamos que la posicion no este en un 0, 8 o 16		
		@;FOR PARA EL CODIGO
		
		
				@;hacemos el contar reps para copiarlas en r1
		mov r0, r7 @;direccion de la matriz
		mov r1, r10 @;cantidad de filas
		mov r2, r9 @;cantidad de columnas
		mov r3, #0 @;posicion este mirar a la derecha
		bl cuenta_repeticiones
		cmp r0, #3
		blo .Lsi
		
		add r12, #1	@; contador de cada una codificada
		mov r1, #0 @; contador de secuencia
		.while:
		cmp r1, r0
		beq .fiwhile
		
		
		mla r6, r10, r11, r9 @;posicion
		add r6, r8 @; pasamos de posicion a la matriz de ceros
		mov r4, r12
		strb r4, [r6]	@;metemos un valor que queremos en la matriz de 0
		
	
		add r1, #1
		add r9, #1
		b .while
		.fiwhile:		
		sub r9, #1
		
		@;FOR PARA EL CODIGO
		
		.Lsi:	;@ llegamos aqui directamente si la posicion es un 0, 8 o 16
		add r9, #1 @; incrementamos j para las COLUMNAS
		b .Rep2
		.FiRep2:
		
		add r10, #1 @; incrementamos i para las FILAS
		b .Rep1
		.FiRep:
		
		pop {r0-r12, pc}



@; marcar_verticales(mat): rutina para marcar todas las secuencias de 3 o más
@;	elementos repetidos consecutivamente en vertical, con un número identifi-
@;	cativo diferente para cada secuencia, que seguirá al último valor almacenado
@;	en la variable global 'num_sec'; las marcas se guardarán en la matriz que se
@;	pasa por parámetro 'mat' (por referencia);
@;	sin embargo, habrá que preservar los identificadores de las secuencias
@;	horizontales que intersecten con las secuencias verticales, que se habrán
@;	almacenado en en la matriz de referencia con la rutina anterior.
@;	Restricciones:
@;		* se supone que la matriz 'mat' está marcada con los identificadores
@;			de las secuencias horizontales
@;		* la variable 'num_sec' contendrá el siguiente indentificador (>=1)
@;		* para detectar secuencias se invocará la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección de la matriz de marcas
marcar_verticales:
		push {r0-r12, lr}
		
		mov r9, #0 @;columnas inicializadas
		mov r10, #0 @;filas inicializadas
		mov r7, r0 @;en r7 se guarda la direccion de la matriz del juego
		mov r8, r1 @;en r8 se guarda la matriz que las copias
		mov r0, #0
		mov r12, #30
		
		.Repe:
		cmp r9, #COLUMNS @; comparamos i con filas y  miramos q sea menor
		bhs .FiRepe		
		mov r10, #0 @;columnas inicializadas
		.Repe2:
		cmp r10, #ROWS
		bhs .FiRepe2
		mov r11, #COLUMNS
		mla r6, r10, r11, r9 @;posicion
		add r6, r7
		ldrb r5, [r6]
		and r5, #7
		cmp r5, #0
		beq .LFin	;@ comprovamos que la posicion no este en un 0, 8 o 16
		cmp r5, #7
		beq .LFin	;@ comprovamos que la posicion no este en un 0, 8 o 16		
		
		@;FOR PARA EL CODIGO
		
		
		@;hacemos el contar reps para copiarlas en r1
		mov r0, r7 @;direccion de la matriz
		mov r1, r10 @;cantidad de filas
		mov r2, r9 @;cantidad de columnas
		mov r3, #1 @;posicion este mirar a la derecha
		bl cuenta_repeticiones
		cmp r0, #3
		blo .LFin
		@;----------------------------------
		
		mov r3, r12 @;guardamos el valor de r12
		mov r2, r9
		mov r1, #0
		.revisar:
		cmp r1, r0
		bhi .Finrevisar
		mla r6, r2, r11, r9 @;posicion
		add r6, r8
		ldrb r5, [r6]
		cmp r5, #0
		beq .Nocomp
		mov r12, r5
		sub r12, #1
		sub r3, #1
		.Nocomp:
		add r1, #1
		add r2, #1
		b .revisar
		.Finrevisar:
		
		
		
		@;----------------------------------
		
		add r12, #1	@; contador de cada una codificada
		mov r1, #0 @; contador de secuencia
		.mientras:
		cmp r1, r0
		beq .fimientras
		
		
		mla r6, r10, r11, r9 @;posicion
		add r6, r8 @; pasamos de posicion a la matriz de ceros
		mov r4, r12
		strb r4, [r6]	@;metemos un valor que queremos en la matriz de 0
		
	
		add r1, #1
		add r10, #1
		b .mientras
		.fimientras:		
		sub r10, #1

		
		@;FOR PARA EL CODIGO
		mov r12, r3
		add r12, #1
		.LFin:	;@ llegamos aqui directamente si la posicion es un 0, 8 o 16
		add r10, #1 @; incrementamos j para las filas
		b .Repe2
		.FiRepe2:
		
		add r9, #1 @; incrementamos i para las columnas
		b .Repe
		.FiRepe:
		mov r0, r7
		mov r1, r8		
		
		pop {r0-r12, pc}



.end
