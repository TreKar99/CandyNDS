@;=                                                          	     	=
@;=== RSI_timer2.s: rutinas para animar las gelatinas (metabaldosas)  ===
@;=                                                           	    	=
@;=== Programador tarea 2G: jaume.tello@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables globales inicializadas ---
.data
		.align 2
		.global update_gel
	update_gel:	.hword	0			@;1 -> actualizar gelatinas
		.global timer2_on
	timer2_on:	.hword	0 			@;1 -> timer2 en marcha, 0 -> apagado
	divFreq2: .hword	-5236		@;divisor de frecuencia para timer 2



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Gb;
@;activa_timer2(); rutina para activar el timer 2.
	.global activa_timer2
activa_timer2:
		push {r0-r1, lr}
		
		ldr r0, =timer2_on
		mov r1, #1
		strh r1, [r0]			@;activamos timer2_on
		ldr r0, =divFreq2
		ldsh r1, [r0]			@;obtenemos el valor del divisor de frecuencia
		ldr r0, =0x04000108
		strh r1, [r0]			@;indicamos el divisor de frecuencia para el timer 2
		ldr r0, =0x0400010A
		mov r1, #0xC1			
		strh r1, [r0]			@;TIMER2_CR --> Start | IRQ Enabled | Prescaler 1 (F/256)
		
		pop {r0-r1, pc}


@;TAREA 2Gc;
@;desactiva_timer2(); rutina para desactivar el timer 2.
	.global desactiva_timer2
desactiva_timer2:
		push {r0-r1, lr}
		
		ldr r0, =timer2_on
		mov r1, #0
		strh r1, [r0]			@;desactivamos timer2_on
		ldr r0, =0x0400010A
		mov r1, #0				@;al poner este 0 en el registo TIMER_CR, haremos que se pare el timer
		strh r1, [r0]			@;TIMER2_CR --> Stop
		
		pop {r0-r1, pc}



@;TAREA 2Gd;
@;rsi_timer2(); rutina de Servicio de Interrupciones del timer 2: recorre todas
@;	las posiciones de la matriz 'mat_gel' y, en el caso que el código de
@;	activación (ii) sea mayor que 0, decrementa dicho código en una unidad y
@;	pasa a analizar la siguiente posición de la matriz 'mat_gel';
@;	en el caso que ii sea igual a 0, incrementa su código de metabaldosa y
@;	activa una variable global 'update_gel' para que la RSI de VBlank actualize
@;	la visualización de dicha metabaldosa.
	.global rsi_timer2
rsi_timer2:
		push {r0-r4, lr}
		
		ldr r0, =mat_gel
		mov r1, #0			@;R1 = fila actual
	.Lline:
		mov r2, #0			@;R2 = columna actual
	.Lbucle:
		ldsb r3, [r0]		@;obtenemos ii de mat_gel
		cmp r3, #0
		beq .Lnext_meta		@;si ii = 0, es momento de cambiar la metabaldosa que se muestra en pantalla
		blt .Lsiguiente		@;si ii < 0, pasamos al siguinete elemento
		sub r3, #1			@;si ii > 0, entonces decrementamos ii en 1...
		strb r3, [r0]		@;...lo guardamos y pasamos al siguiente elemento
		
	.Lsiguiente:
		add r0, #GEL_TAM	@;pasamos al siguiente elemento
		add r2, #1
		cmp r2, #COLUMNS
		blo .Lbucle			@;si no hemos llegado al final de la fila, seguimos
		add r1, #1			@;incrementamos en 1 la fila actual (si hemos llegado al final de la fila anterior)
		cmp r1, #ROWS
		blo .Lline			@;si empezamos fila nueva, tenemos que poner la columna actual a 0
		b .Lfin
		
	.Lnext_meta:
		ldrb r3, [r0, #GEL_IM]
		cmp r3, #7
		beq .Lsimple
		cmp r3, #15
		beq .Ldoble
		add r3, #1
		strb r3, [r0, #GEL_IM]	@;incrementamos en 1 el índice de metabaldosa y lo guardamos
		b .Lupdate
		
	.Lsimple:
		mov r3, #0
		strb r3, [r0, #GEL_IM]	@;al llegar al final de la animación, volvemos a repetirla desde el principio
		b .Lupdate
		
	.Ldoble:
		mov r3, #8
		strb r3, [r0, #GEL_IM]	@;al llegar al final de la animación, volvemos a repetirla desde el principio
		b .Lupdate
		
	.Lupdate:
		ldr r3, =update_gel
		mov r4, #1
		strh r4, [r3]		@;activamos update_gel para informar que hay gelatinas a actualizar
		b .Lsiguiente
		
	.Lfin:
		pop {r0-r4, pc}



.end
