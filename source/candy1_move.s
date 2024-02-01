@;=                                                         	      	=
@;=== candy1_move: rutinas para contar repeticiones y bajar elementos ===
@;=                                                          			=
@;=== Programador tarea 1E: germanangel.puerto@estudiants.urv.cat	  ===
@;=== Programador tarea 1F: germanangel.puerto@estudiants.urv.cat	  ===
@;=                                                         	      	=



.include "../include/candy1_incl.i"



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1E;
@; cuenta_repeticiones(*matriz,f,c,ori): rutina para contar el número de
@;	repeticiones del elemento situado en la posición (f,c) de la matriz, 
@;	visitando las siguientes posiciones según indique el parámetro de
@;	orientación 'ori'.
@;	Restricciones:
@;		* sólo se tendrán en cuenta los 3 bits de menor peso de los códigos
@;			almacenados en las posiciones de la matriz, de modo que se ignorarán
@;			las marcas de gelatina (+8, +16)
@;		* la primera posición también se tiene en cuenta, de modo que el número
@;			mínimo de repeticiones será 1, es decir, el propio elemento de la
@;			posición inicial
@;	Parámetros:
@;		R0 = dirección base de la matriz
@;		R1 = fila 'f'
@;		R2 = columna 'c'
@;		R3 = orientación 'ori' (0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte)
@;	Resultado:
@;		R0 = número de repeticiones detectadas (mínimo 1)
	.global cuenta_repeticiones
cuenta_repeticiones:
		push {r1-r12, lr}
		
		mov r5, #COLUMNS
		mov r12, #ROWS 
		
		mov r9, r0				@;R9 = direccion base matriz
		
		mla r6, r1, r5, r2
		add r4, r9, r6			@;R4 apunta al elemento (f,c) de 'mat'
		ldrb r10, [r4]
		and r10, #7				@;R10 es el valor filtrado (sin marcas de gel.)
		
		mov r0, #1				@;R11 = número de repeticiones
		
		cmp r3, #0
		beq .Lconrep_este
		cmp r3, #1
		beq .Lconrep_sur
		cmp r3, #2
		beq .Lconrep_oeste
		cmp r3, #3
		beq .Lconrep_norte
		b .Lconrep_fin
		
	.Lconrep_este:
		sub r5, #1
		sub r12, #1
		
		cmp r2, r5				@;comparamos que columna sea inferior al numero max columnas
		bge .Lconrep_fin
		
		mov r5, #COLUMNS
		mov r12, #ROWS 
		
		add r2, #1				@;R2 añadimos una columna para la derecha
		mla r6, r1, r5, r2
		add r4, r9, r6			@;R4 generamos la nueva posicion a comparar
		ldrb r7, [r4]			
		and r7, #7				
		cmp r10, r7				@;comparamos el valor actual con el de la posicion original
		bne .Lconrep_fin
		add r0	, #1			@;si es igual sumamos una repeticion
		b .Lconrep_este
	
	.Lconrep_sur:
		sub r5, #1
		sub r12, #1
		
		cmp r1, r12				@;comparamos que fila sea inferior al numero max filas
		bge .Lconrep_fin
		
		mov r5, #COLUMNS
		mov r12, #ROWS 
		
		add r1, #1				@;R1 añadimos una fila para abajo
		mla r6, r1, r5, r2
		add r4, r9, r6			@;R4 generamos la nueva posicion a comparar
		ldrb r7, [r4]
		and r7, #7				
		cmp r10, r7				@;comparamos el valor actual con el de la posicion original
		bne .Lconrep_fin
		add r0, #1			
		b .Lconrep_sur
		
	.Lconrep_oeste:
		sub r5, #1
		sub r12, #1
		
		cmp r2, #0				@;comparamos que la columna no sea menor a 0 (límite)
		ble .Lconrep_fin
		
		mov r5, #COLUMNS
		mov r12, #ROWS 
		
		sub r2, #1				@;R2 restamos una columna para la izquierda
		mla r6, r1, r5, r2
		add r4, r9, r6			@;R4 generamos la nueva posicion a comparar
		ldrb r7, [r4]			
		and r7, #7				
		cmp r10, r7				@;comparamos el valor actual con el de la posicion original
		bne .Lconrep_fin
		add r0	, #1			@;si es igual sumamos una repeticion
		b .Lconrep_oeste
		
	.Lconrep_norte:
		sub r5, #1
		sub r12, #1
		
		cmp r1, #0				@;comparamos que fila sea superior a 0
		ble .Lconrep_fin
		
		mov r5, #COLUMNS
		mov r12, #ROWS 
		
		sub r1, #1				@;R1 restamos una fila para arriba
		mla r6, r1, r5, r2
		add r4, r9, r6			@;R4 generamos la nueva posicion a comparargit
		ldrb r7, [r4]
		and r7, #7
		cmp r10, r7				@;comparamos el valor actual con el de la posicion original
		bne .Lconrep_fin
		add r0, #1
		b .Lconrep_norte
		
	.Lconrep_fin:
		
		pop {r1-r12, pc}




@;TAREA 1F;
@; baja_elementos(*matriz): rutina para bajar elementos hacia las posiciones
@;	vacías, primero en vertical y después en sentido inclinado; cada llamada a
@;	la función sólo baja elementos una posición y devuelve cierto (1) si se ha
@;	realizado algún movimiento, o falso (0) si está todo quieto.
@;	Restricciones:
@;		* para las casillas vacías de la primera fila se generarán nuevos
@;			elementos, invocando la rutina 'mod_random' (ver fichero
@;			"candy1_init.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica se ha realizado algún movimiento, de modo que puede que
@;				queden movimientos pendientes. 
	.global baja_elementos
baja_elementos:
		push {r1-r12, lr}
		
		mov r4, r0					@; R4 = Base matriz
		mov r0, #0 					@; R0 = Asignamos false por default
		
		bl baja_verticales
		
		cmp r0, #1					@; Si ya ha cambiado valor salimos
		beq .Lcontinue
		
		bl baja_laterales
		
		.Lcontinue:
		
		pop {r1-r12, pc}



@;:::RUTINAS DE SOPORTE:::



@; baja_verticales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en vertical; cada llamada a la función sólo baja elementos una posición y
@;	devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento. 
baja_verticales:
		push {r1-r12, lr}
		
		mov r11, #ROWS
		mov r12, #COLUMNS
		
		sub r1, r11, #1						@; R1 = Fila actual
		sub r2, r12, #1						@; R2 = Columna actual
											
	.LPosicion:
		mla r3, r1, r12, r2 				@; i*NC+j
		add r5, r4, r3						@; dir(i,j) = BASE + (i*NC+j)
		ldrb r6, [r5]						@; R6 = Valor matriz
	
		and r7, r6, #7						@; Miramos que el valor sea 0
		cmp r7, #0
		
		bne .LRecorrerMatriz				@; Salta si no es 0
		
		mov r6, r5							@; R6 = Dirección de casilla abajo
		mov r9, r1							@; R9 = FILAS AUX
		mov r10, r2							@; R10 = COLUMNS AUX
		
	.LCasillaSuperior:
				
		cmp r1, #0							@; Comprobamos el límite superior tablero
		ble .LRandom						@; RANDOOOOOM
		
		sub r1, #1							@; Buscamos el elemento superior
	
		mla r3, r1, r12, r2
		add r5, r4, r3
		ldrb r8, [r5]
		
		cmp r8, #15
		beq .LCasillaSuperior
		
		and r8, #7
		cmp r8, #0							@; Comparamos que el superior no sea un 0, 8 O 16
		beq .LRecupRecorrido
		
		cmp r8, #7							@; Comparamos que el superior no sea bloque
		beq .LRecupRecorrido				
				
	.LIntercambio:
		bl intercambia_valores
		bl baja_sprite_vertical
		mov r6, r5							@; R6 = Dirección de casilla abajo
		b .LCasillaSuperior
			
	.LRecorrerMatriz:
		.LRecorrerFila:
			cmp r0, #0							@; Si ha hecho un cambio se va
			bne .LFin
			
			cmp r2, #0
			ble .LRecorrerCol
			sub r2, #1							@; Recorremos matriz a inversa
			bl .LPosicion						@; Saltamos a calcular siguiente valor
			
		.LRecorrerCol:
			cmp r1, #0							@; Comprobamos que la fila no sea 0							
			ble .LFin
			
			sub r1, #1							@; Baja fila
			sub r2, r12, #1						@; Pone al final de fila
			bl .LPosicion
			
	.LRandom:
			ldrb r10, [r5]						@; Cargamos el valor a analizar si es (0,8,16) randomizamos
						
			cmp r10, #7							@; Comparar si es bloque salir
			beq .LRecorrerMatriz
			
		.LMirarAbajo:
			cmp r10, #15						@; Comparar si es hueco mirar debajo

			beq .LFor
		
			and r9, r10, #0x18					@; Máscara gelatina casilla abajo (0,8,16)
			and r10, #7							@; Comprobar que es un (0,8,16)
			cmp r10, #0
			bne .LRecorrerMatriz
			
			mov r0, #6							@; Rango entre 0 i #6-1
			bl mod_random
			
			add r0, r0, #1						@; Para que sea entre 1-6 i no 0-5
			
			bl crea_sprite						@; CREAMOS SPRITE
			add r0, r9							@; Sumamos gelatina
			strb r0, [r5]						@; Guardamos el valor aleatorio 1-6 
		
			mov r0, #1
			bl .LRecorrerMatriz
			
		.LFor:
			add r1, #1							@; Bucle para bajar filas y buscar (0,8,16)
			mla r3, r1, r12, r2
			add r5, r4, r3
			ldrb r10, [r5]
			bl .LMirarAbajo
			
	.LRecupRecorrido:
			cmp r0, #1							@; Si ya ha hecho algun intercambio salir
			beq .LFin
			
			mov r1, r9							@; Recuperar filas y columnas para seguir recorrido
			sub r2, r10, #1						@; Restamos una columna para obtener la siguiente posición
			bl .LPosicion
	.LFin:
			
		
		pop {r1-r12, pc}



@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en diagonal; cada llamada a la función sólo baja elementos una posición y
@;	devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento. 
baja_laterales:
		push {r1-r12, lr}
		
		mov r11, #ROWS
		mov r12, #COLUMNS
		
		sub r1, r11, #1						@; R1 = Fila actual
		sub r2, r12, #1						@; R2 = Columna actual
		
	.LPosicion2:
		mov r11, #ROWS
		mov r12, #COLUMNS
		
		mla r3, r1, r12, r2 				@; i*NC+j
		add r5, r4, r3						@; dir(i,j) = BASE + (i*NC+j)
		ldrb r6, [r5]						@; R6 = Valor matriz
	
		and r7, r6, #7						@; Miramos que el valor sea 0
		cmp r7, #0
		
		bne .LRecorrerMatriz2				@; Salta si no es 0
		
		mov r6, r5							@; R6 = Dirección de casilla abajo
		mov r9, r1							@; R9 = FILAS AUX
		mov r10, r2							@; R10 = COLUMNS AUX
		
	.LCasillaSuperior2:
		cmp r0, #1
		beq .LFin2
		
		mov r11, #ROWS
		mov r12, #COLUMNS
		
		cmp r1, #0							@; Comprobamos el límite superior tablero
		ble .LRandom2						@; RANDOOOOOM
		
		mov r7, #0							@; R7 = Izquierda
		mov r8, #0							@; R8 = Derecha
		.LSuperiorIzquierdaDisp:
			cmp r2, #0						@; Comprobar si estamos al límite izquierdo
			ble .LSuperiorDerechaDisp
			
			mov r11, #ROWS
			mov r12, #COLUMNS
			
			sub r1, #1						@; Vemos valor Casilla Superior Izquierda
			sub r2, #1
			
			mla r3, r1, r12, r2
			add r5, r4, r3
			ldrb r7, [r5]
						
			cmp r7, #15
			beq .LSuperiorDerechaDisp
			
			and r7, #7
			cmp r7, #7
			beq .LSuperiorDerechaDisp
			
			cmp r7, #0
			beq .LSuperiorDerechaDisp
			
			mov r7, #1							@; Podemos cambiar 1 izquierda
		.LSuperiorDerechaDisp:
			mov r11, #ROWS
			mov r12, #COLUMNS
			
			mov r1, r9							@; Recuperem Casilla Vacia y mirem Casilla Superior Derecha
			mov r2, r10
			
			sub r12, #1
			cmp r2, r12							@; Comprobamos si estamos al límite derecho
			bhs .LEligeIntercambio
			
			sub r1, #1							@; Vemos valor Casilla Superior Derecha
			add r2, #1
			
			mov r11, #ROWS
			mov r12, #COLUMNS
			mla r3, r1, r12, r2
			add r5, r4, r3
			ldrb r8, [r5]
			
			cmp r8, #15
			beq .LEligeIntercambio
			
			and r8, #7
			cmp r8, #7
			beq .LEligeIntercambio
			
			cmp r8, #0
			beq .LEligeIntercambio
			
			mov r8, #1
	.LEligeIntercambio:
		.LComprobarIntercambioDos:
		cmp r7, #1								@; Ver si hay al menos una disponible
			bne .LComprobarIntercambioInd
			
		cmp r7, r8								@; Si R7 = R8 (1=1) elegir cual cambiar aleatorio
			beq .LLeftRightRandom
			
		.LComprobarIntercambioInd:
		cmp r7, #1								@; Si hay para intercambiar ARRIBA IZQUIERDA
			beq .LIntercambioIzquierda
			
		cmp r8, #1								@; Si hay para intercambiar ARRIBA DERECHA
			beq .LIntercambioDerecha
			
			bl .LRecupRecorrido2
	
	.LIntercambio2:
		.LIntercambioIzquierda:
			mov r11, #ROWS
			mov r12, #COLUMNS
			
			mov r1, r9
			mov r2, r10
			
			sub r1, #1						@; Vemos valor Casilla Superior Izquierda
			sub r2, #1
			
			mla r3, r1, r12, r2
			add r5, r4, r3
			bl intercambia_valores
			bl baja_sprite_lateral
			mov r6, r5							@; R6 = Dirección de casilla abajo

			mov r0, #1
			bl .LCasillaSuperior2
			
		.LIntercambioDerecha:
			mov r11, #ROWS
			mov r12, #COLUMNS
			
			mov r1, r9							@; Recuperem Casilla Vacia y mirem Casilla Superior Derecha
			mov r2, r10
			
			sub r1, #1							@; Vemos valor Casilla Superior Derecha
			add r2, #1
			
			mla r3, r1, r12, r2
			add r5, r4, r3
			bl intercambia_valores
			bl baja_sprite_lateral
			mov r6, r5							@; R6 = Dirección de casilla abajo

			mov r0, #1
			bl .LCasillaSuperior2
			
	.LRecorrerMatriz2:
		.LRecorrerFila2:
			cmp r0, #0							@; Si ha hecho un cambio se va
			bne .LFin
			
			cmp r2, #0
			ble .LRecorrerCol2
			sub r2, #1							@; Recorremos matriz a inversa
			bl .LPosicion2						@; Saltamos a calcular siguiente valor
			
		.LRecorrerCol2:
			cmp r1, #0							@; Comprobamos que la fila no sea 0							
			ble .LFin2
			
			sub r1, #1							@; Baja fila
			sub r2, r12, #1						@; Pone al final de fila
			bl .LPosicion2
			
	.LRandom2:
			ldrb r10, [r5]						@; Cargamos el valor a analizar si es (0,8,16) randomizamos
			
			and r10, #7
			cmp r10, #0							@; Comparar si es bloque salir
			bne .LRecorrerMatriz2

	.LRecupRecorrido2:
			cmp r0, #1
			beq .LFin2
			
			mov r1, r9							@; Recuperar filas y columnas para seguir recorrido
			sub r2, r10, #1						@; Restamos una columna para obtener la siguiente posición
			bl .LPosicion2
	
	.LLeftRightRandom:
			mov r0, #2
			bl mod_random
			cmp r0, #0							@; Si r0 = 0, mirem valor esquerra
				beq .LIntercambioIzquierda
			cmp r0, #1							@; Si r0 = 1, mirem valor dreta
				beq .LIntercambioDerecha
			bl .LRecupRecorrido2
	.LFin2:
			
		pop {r1-r12, pc}

@; intercambia_valores(mat): rutina para intercambiar valores de dos direcciones dadas.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;		R5 = dirección de la casilla a intercambiar superior
@;		R6 = dirección de la casilla a intercambiar inferior
@;	Output:
@;		R0 = 1 para indicar que se ha realizado movimiento. 
@;		R6 = pasa a ser la nueva dirección inferior

intercambia_valores:
		push {r1-r5, r7-r12, lr}
		
		ldrb r7, [r6]						@; Valor casilla de abajo
		ldrb r8, [r5]						@; Valor casilla de arriba
		
		and r9, r7, #0x18					@; Máscara gelatina casilla abajo (0,8,16)
		and r10, r8, #0x18					@; Máscara gelatina casilla arriba (0,8,16)
		
		and r8, #7							@; Máscara valor casilla arriba 
		add r8, r9 							@; Valor casilla arriba + máscara abajo

		strb r8, [r6]						@; Guardamos valor casilla abajo
		
		strb r10, [r5]						@; Pasamos el superior a 0 (0,8,16)
		
		mov r0, #1							@; CONDICIÓN HECHA
		@;mov r6, r5							@; R6 = Dirección de casilla abajo
		
		pop {r1-r5, r7-r12, pc}

@; crea_sprite: rutina para generar un sprite nuevo en una bajada vertical.
@;	Parámetros:
@;		R0 :	tipo de elemento (1-6)
@;		R1 :	fila del elemento
@;		R2 :	columna del elemento
@;	Output:
@;		R0 :	índice del elemento encontrado, o ROWS*COLUMNS 

crea_sprite:
		push {r0-r5, lr}
		
		sub r1, #1				@; Restamos una fila para crear el sprite desde arriba y simular bajada
		bl crea_elemento
		
		@; Lo movemos para el tablero de juego
		mov r0, r1				@; R0 = fila actual
		mov r1, r2				@; R1 = columna actual
		add r2, r0, #1			@; R2 = fila destino
		mov r3, r1				@; R3 = columna destino
		bl activa_elemento	
		
		pop {r0-r5, pc}

@;baja_sprite_vertical: Rutina para mover un sprite verticalmente
@;	Parámetros:
@;		R2 : columna actual/destino
@;		R5 : dirección de la casilla a intercambiar superior -> FILA ACTUAL
@;		R6 : dirección de la casilla a intercambiar inferior -> FILA DESTINO

baja_sprite_vertical:
		push {r0-r9, lr}
		
		mov r7, r2
		
		sub r5, r4				@; R5 = fila actual*NC + j - BASE
		sub r6, r4				@; R6 = fila destino*NC + j - BASE
		
		sub r5, r2				@; R5 = fila actual*NC - j
		sub r6, r2				@; R6 = fila destino*NC - j
		
		mov r5, r5, lsr #3		@; R5 = fila actual/NC
		mov r6, r6, lsr #3		@; R6 = fila destino/NC
		
		mov r0, r5				@; R0 = fila actual
		mov r1, r7				@; R1 = columna actual
		mov r2, r6				@; R2 = fila destino
		mov r3, r7				@; R3 = columna destino
		bl activa_elemento
		
		pop {r0-r9, pc}

@;baja_sprite_lateral: Rutina para mover un sprite lateralmente
@;	Parámetros:
@;		R1 : fila actual
@;		R2 : columna actual
@; 		R9 : fila destino
@; 		R10 : columna destino

baja_sprite_lateral:
		push {r0-r9, lr}
				
		mov r0, r1				@; R0 = fila actual
		mov r1, r2				@; R1 = columna actual
		mov r2, r9				@; R2 = fila destino
		mov r3, r10				@; R3 = columna destino
		bl activa_elemento
		
		pop {r0-r9, pc}
		
.end
