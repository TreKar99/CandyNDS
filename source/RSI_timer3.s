@;=                                                          	     	=
@;=== RSI_timer3.s: rutinas para desplazar el fondo 3 (imagen bitmap) ===
@;=                                                           	    	=
@;=== Programador tarea 2H: ivan.garciap@estudiants.urv.cat			  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables globales inicializadas ---
.data
		.align 2
		.global update_bg3
	update_bg3:	.hword	0			@;1 -> actualizar fondo 3
		.global timer3_on
	timer3_on:	.hword	0 			@;1 -> timer3 en marcha, 0 -> apagado
		.global offsetBG3X
	offsetBG3X: .hword	0			@;desplazamiento vertical fondo 3
	sentidBG3X:	.hword	0			@;sentido desplazamiento (0-> inc / 1-> dec)
	divFreq3: .hword	-13091			@;divisor de frecuencia para timer 3
	


@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Hb;
@;activa_timer3(); rutina para activar el timer 3.
	.global activa_timer3
activa_timer3:
		push {r0-r5, lr}
		
		ldr r0, =timer3_on	@; activamos timer3_on, poniendolo a 1
		ldrh r1, [r0]
		mov r1, #1
		strh r1, [r0]
		
		ldr r2, =divFreq3	
		ldsh r3, [r2]		@; cargamos el contenido de la divFreq3 en r3 (para hacer los calculos)
		ldr r2, =0x0400010C
		str r3, [r2]		@; guradamos el valor actualizado
		
		ldr r4, =0x0400010E @; marcamos el valor que necesitamos en el registro E/S de control
		ldrh r5, [r4]
		ldr r5, =0xC2
		strh r5, [r4]
		
		
		pop {r0-r5, pc}


@;TAREA 2Hc;
@;desactiva_timer3(); rutina para desactivar el timer 3.
	.global desactiva_timer3
desactiva_timer3:
		push {r0-r1, r4-r5, lr}
		
		ldr r4, =0x0400010E @; marcamos el valor que necesitamos en el registro E/S de control
		ldrh r5, [r4]
		mov r5, #0
		strh r5, [r4]
		
		
		ldr r0, =timer3_on	@; desactivamos timer3_on, poniendolo a 0
		ldrh r1, [r0]
		mov r1, #0
		strh r1, [r0]
		
		pop {r0-r1, r4-r5, pc}



@;TAREA 2Hd;
@;rsi_timer3(); rutina de Servicio de Interrupciones del timer 3: incrementa o
@;	decrementa el desplazamiento X del fondo 3 (sobre la variable global
@;	'offsetBG3X'), según el sentido de desplazamiento actual; cuando el
@;	desplazamiento llega a su límite, se cambia el sentido; además, se avisa
@;	a la RSI de retroceso vertical para que realice la actualización del
@;	registro de control del fondo correspondiente.
	.global rsi_timer3
rsi_timer3:
		push {r0-r3, lr}
		
		ldr r0, =sentidBG3X
		ldrh r1, [r0]
		cmp r1, #0
		beq .Lincrementar
		cmp r1, #1
		beq .Ldecrementar
		
	.Lincrementar:
		
		ldr r2, =offsetBG3X	@; incrementamos el valor del pixel
		ldrh r3, [r2]
		add r3, #1
		strh r3, [r2]
		
		cmp r3, #320		@; si el valor de offsetBG3X es 320 (valor maximo) cambiamos el sentido de sentidBG3X a 1
		moveq r1, #1
		strh r1, [r0]
		
		b .final
	.Ldecrementar:
		
		ldr r2, =offsetBG3X	@; decrementamos el valor del pixel
		ldrh r3, [r2]
		sub r3, #1
		strh r3, [r2]		
		
		cmp r3, #0		@; si el valor de offsetBG3X es 0 (valor minimo) cambiamos el sentido de sentidBG3X a 0
		moveq r1, #0
		strh r1, [r0]

.final:
		ldr r0, =update_bg3
		mov r1, #1
		strh r1, [r0]
		
		pop {r0-r3, pc}



.end
