@;=                                                          	     	=
@;=== RSI_timer0.s: rutinas para mover los elementos (sprites)		  ===
@;=                                                           	    	=
@;=== Programador tarea 2E: sergi.llobet@estudiants.urv.cat			  ===
@;=== Programador tarea 2G: jaume.tello@estudiants.urv.cat	  ===
@;=== Programador tarea 2H: ivan.garciap@estudiants.urv.cat		  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.align 2
		.global update_spr
	update_spr:	.hword	0			@;1 -> actualizar sprites
		.global timer0_on
	timer0_on:	.hword	0 			@;1 -> timer0 en marcha, 0 -> apagado
	divFreq0: .hword	-5728

@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
	divF0: .space	2				@;divisor de frecuencia actual


@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm

@;TAREAS 2Ea,2Ga,2Ha;
@;rsi_vblank(void); Rutina de Servicio de Interrupciones del retrazado vertical;
@;Tareas 2E,2F: actualiza la posición y forma de todos los sprites
@;Tarea 2G: actualiza las metabaldosas de todas las gelatinas
@;Tarea 2H: actualiza el desplazamiento del fondo 3
	.global rsi_vblank
rsi_vblank:
		push {r0-r12,lr}

@;Tareas 2Ea
		ldr r2, =update_spr					@; cargamos en r0 la direccion de 'update_spr'
		ldrh r1, [r2]						@; cargamos en r1 el valor de la direccion de r0
		cmp r1, #1							@; comprovar si el valor es 1 ya que quiere decir que hay que actualizar sprites
		bne .Fi
		mov r0, #0x07000000					@; direccion inicial de OAM en r0
		mov r1, #128						@; numero maximo de sprites en r1
		bl SPR_actualizarSprites
		mov r1, #0							@; ponemos a 0 r1 porque ya hemos actualizado
		strh r1, [r2]						@; guardamos el valor de r1 en la direccion de r0 
	.Fi:
@;Tarea 2Ga
	ldr r0, =update_gel
	ldrh r1, [r0]			@;valor de update_gel
	cmp r1, #0
	beq .LfinG				@;ignoramos todo, si update_gel == 0
	
	ldr r0, =mat_gel
	mov r1, #0				@;R1 = fila actual
.Lline:
	mov r2, #0				@;R2 = columna actual
.Lbucle:
	ldsb r4, [r0]			@;obtenemos ii de mat_gel
	cmp r4, #0	
	bne .Lsiguiente			@;si ii es diferente de 0, pasamos al siguiente elemento
	ldrb r3, [r0, #GEL_IM]	@;pasamos im como parámetro a fija_metabaldosa
	mov r4, r0
	ldr r0, =0x06000000 	@;R0 = mapaddr
	bl fija_metabaldosa
	mov r0, r4
	mov r4, #10
	strb r4, [r0]			@;actualizamos ii a 10
	
.Lsiguiente:
	add r0, #GEL_TAM		@;pasamos al siguiente elemento
	add r2, #1				@;incrementamos en 1 la columna actual
	cmp r2, #COLUMNS
	blo .Lbucle				@;si no hemos llegado al final de la fila, seguimos
	add r1, #1				@;incrementamos en 1 la fila actual (si hemos llegado al final de la fila anterior)
	cmp r1, #ROWS
	blo .Lline				@;si empezamos fila nueva, tenemos que poner la columna actual a 0
	b .LfinG
	
.LfinG:
		ldr r0, =update_gel
		mov r1, #0
		strh r1, [r0]		@;desactivamos update_gel
@;Tarea 2Ha
		ldr r4, =update_bg3	@; cargamos la variable update_bg3 en r5 y la direccion en r5
		ldrh r5, [r4]
		cmp r5, #0	@; si la variable update_bg3 es 0(desactivada) saltamos al final
		beq .Lfin
			
		ldr r6, =offsetBG3X @; cargamos el valor de la variable global offsetBG3x
		ldrh r7, [r6]
		mov r7, r7, lsl #8 @; ponemos en 0:20:8 la variable
		
		ldr r8, =0x4000038	@; cargamos la direccion del registro BG3X
		str r7, [r8]	@; metemos el valor de offsetBG3X en el registro BG3X
			
		mov r5, #0		@; desactivamos la variable update_bg3 es decir la cambiamos a 0
		strh r5, [r4]
	.Lfin:
	
		pop {r0-r12, pc}




@;TAREA 2Eb;
@;activa_timer0(init); rutina para activar el timer 0, inicializando o no el
@;	divisor de frecuencia según el parámetro init.
@;	Parámetros:
@;		R0 = init; si 1, restablecer divisor de frecuencia original divFreq0
	.global activa_timer0
activa_timer0:
		push {r0-r1, lr}
		
		cmp r0, #1						@; si init no es 1, salta al final
		bne .Final
		ldr r0, =divFreq0				@; en r0 tenemos la direccion de el divisor de frecuencia original
		ldrh r1, [r0]					@; en r1 tenemos el valor del divisor de frecuencia original
		ldr r0, =divF0					@; en r0 tenemos el divisor de frecuencia actual
		strh r1, [r0]					@; restablecemos a divisor de frecuencia original
		ldr r0, =0x04000100				@; cargamos el 'TIMER0_DATA' para cargar el divisor de frecuencia
		strh r1, [r0]					@; guardamos el valor de r1 en la direccion de r0
	  .Final:
		ldr r0, =timer0_on				@; cargamos la direccion de 'timer0_on'
		mov r1, #1						@; ponemos a 1 el registro r1 para guardarlo en la direccion r0
		strh r1, [r0]					@; guardamos el valor de r1 en la direccion de r0
	    ldr r0, =0x04000102				@; cargamos el 'TIMER0_CR' (registro de control del timer 0)
		mov r1, #0xC1					@; 0b1100 0001 -> el prescaler es 01 -> F/64 con bits 1..0, interrupciones activadas con bit 6 y timer en marcha con bit 7
		strh r1, [r0]					@; guardamos el valor r1 en la direccion r0
		
		pop { r0-r1, pc}


@;TAREA 2Ec;
@;desactiva_timer0(); rutina para desactivar el timer 0.
	.global desactiva_timer0
desactiva_timer0:
		push { r0-r1, lr}
		
		ldr r0, =0x04000100				@; cargamos el 'TIMER0_CR' (registro de control del timer 0)
		ldrh r1, [r0]					@; cargamos el valor en r1 de la direccion de r0
		bic r1, #0x80					@; ponemos a 0 el bit 7
		strh r1, [r0]					@; guardamos el valor de r1 en la direccion de r0
		ldr r0, =timer0_on				@; cargamos la direccion de 'timer0_on'
		mov r1, #0						@; asignamos a r1 el valor de 0
		strh r1, [r0]					@; ponemos a 0 la variable global 'timer0_on'
		
		pop {r0-r1, pc}



@;TAREA 2Ed;
@;rsi_timer0(); rutina de Servicio de Interrupciones del timer 0: recorre todas
@;	las posiciones del vector vect_elem y, en el caso que el código de
@;	activación (ii) sea mayor o igual a 0, decrementa dicho código y actualiza
@;	la posición del elemento (px, py) de acuerdo con su velocidad (vx,vy),
@;	además de mover el sprite correspondiente a las nuevas coordenadas.
@;	Si no se ha movido ningún elemento, se desactivará el timer 0. En caso
@;	contrario, el valor del divisor de frecuencia se reducirá para simular
@;  el efecto de aceleración (con un límite).
@;	Cal recordar que vect_elem és un vector de elements, una estructura formada per 5 hwords:
@;	ii, px, py, vx, vy
	.global rsi_timer0
rsi_timer0:
		push {r0-r11, lr}
		
		mov r0, #0						@; inicializamos el indice que le pasaremos a 'SPR_moverSprite'
		mov r11, #0						@; incialitzamos la variable de estado de si hay movimiento
		ldr r4, =vect_elem				@; cargamos a r4 la direccion de 'vect_elem'
	  .Linici:
		ldr r3, =n_sprites				@; r3 es la direccion de 'n_sprites'
		ldr r3, [r3]					@; obtenemos el valor en r3 de 'n_sprites'
		ldrh r5, [r4]					@; cargamos el valor de r4 en r5 (ii)
		cmp r5, #0						@; comparamos 'ii' para ver si es 0 o -1
		bne .Linactiu
		add r4, #10						@; si es 0 sumamos 10 para avanzar el vector
		b .Lignorar						@; si es 0 ignoramos ese elemento
	  .Linactiu:
		tst r5, #0x8000					@; comparamos el bit de signo
		beq .Lno_sumar					@; si es positivo no sumamos
		add r4, #10						@; si es negativo sumamos 10 para avanzar el vector
		b .Lignorar
	  .Lno_sumar:
		sub r5, #1						@; decrementamos el valor de ii
		strh r5, [r4]					@; guardamos el nuevo valor de ii en la direccion r4
		mov r8, #0						@; inicialitzem r8
		add r8, r4, #2					@; r8 = direccio de px
		ldrh r6, [r8]					@; r6 = px
		ldrh r7, [r4, #6]				@; r7 = vx
		mov r11, #1						@; actualizamos la variable de estado a 1, ya que hay movimiento
		cmp r7, #0						@; comparamos si la velocidad es 0
		beq .Lno_fer_resx				@; si la velocidad es 0 no hacer nada
		add r6, r7						@; sumamos la velocidad (vx) a px
		strh r6, [r8]					@; guardamos el nuevo valor de px en la direccion de r8
	.Lno_fer_resx:
		mov r9, #0						@; inicialitzem r9
		add r9, r4, #4					@; r9 = direccio de py
		ldrh r10, [r9]					@; r10 = py
		ldrh r7, [r4, #8]				@; r7 = vy
		cmp r7, #0						@; comparamos si la velocidad es 0
		beq .Lno_fer_resy				@; si la velocidad es 0 no hacer nada
		add r10, r7						@; sumamos la velocidad (vy) a py
		strh r10, [r9]
	.Lno_fer_resy:
		mov r1, r6						@; r6 = px
		mov r2, r10						@; r10 = py
		bl SPR_moverSprite				@; saltamos a la rutina pasandole -> r0 = indice // r1 = px // r2 = py
		add r4, #10						@; pasamos al siguiente elemento
	.Lignorar:
		add r0, #1						@; incrementamos el indice
		cmp r0, r3						@; comparamos el indice con el numero de sprites
		bne .Linici						@; si no ha acabado volver a repetir
		cmp r11, #0						@; comparamos si el estado es 0 (no movimiento)
		bleq desactiva_timer0			@; si no hay movimiento desactivamos el timer
		beq .Lfinal						@; saltamos al final ya que no hay movimiento
		ldr r0, =update_spr				@; cargamos en r0 la direccion de 'update_spr'
		mov r1, #1						@; ponemos r1 a 1 ya que los sprites han cambiado de posicion
		strh r1, [r0]					@; guardamos el valor de r1 en la direccion de r0
		ldr r0, =divF0					@; cargamos en r0 la direccion del divisor de frecuencia actual
		ldrh r1, [r0]					@; cargamos en r1 el valor de la direccion de r0
		cmp r1, #50						@; establecemos la velocidad maxima
		blo .Lfinal						@; si es menor a 50 salta al final
		sub r1, #200					@; restamos 200 al divisor de frecuencia para hacer el efecto de aceleracion
		strh r1, [r0]					@; guardamos el valor de r1 en la direccion de r0
	  .Lfinal:
	  
		pop {r0-r11, pc}



.end
