@;=                                                          	     	=
@;=== RSI_timer1.s: rutinas para escalar los elementos (sprites)	  ===
@;=                                                           	    	=
@;=== Programador tarea 2F: germanangel.puerto@estudiants.urv.cat	  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.align 2
		.global timer1_on
	timer1_on:	.hword	0 			@;1 -> timer1 en marcha, 0 -> apagado
	divFreq1: .hword	-5728		@;divisor de frecuencia para timer 1
	
	@; ---------------- CÁLCULO DE DIVISOR DE FRECUENCIA ---------------------
	@; 32 tics en 0,35 secs -> tic cada 0,35/32 = 0,0109375 secs
	@; 0,0109375 secs = 91,42857 Hz -> Frecuencia de salida
	@; divFreq = -(FreqEntr/FreqSal) -> = -32768 < -(FreqEntr/91,42857) < 32767
	@; FreqEntr = 32.513.982 Hz -> DivFreq = -355.621 XXX
	@; FreqEntr = 523.655,96875 Hz -> [DivFreq = -5728] 
	
@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
	escSen: .space	2				@;sentido de escalado (0-> dec, 1-> inc)
	escFac: .space	2				@;factor actual de escalado
	escNum: .space	2				@;número de variaciones del factor


@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Fb;
@;activa_timer1(init); rutina para activar el timer 1, inicializando el sentido
@;	de escalado según el parámetro init.
@;	Parámetros:
@;		R0 = init;  valor a trasladar a la variable 'escSen' (0/1)
	.global activa_timer1
activa_timer1:
		push {r0-r2,lr}
	
		ldr r1, =escSen
		strh r0, [r1]				@; Almacenamos init en escSen
						
		ldr r0, =timer1_on			@; Ponemos timer1_on a 1 (ciclo de escalamiento 0-32)
		mov r1, #1					
		strh r1, [r0]
		
		ldr r0, =escNum				@; escNum = 0 (momento de ciclo de escalamiento 0-32, 0 porque inicia)
		mov r1, #0
		strh r1, [r0]
		
		ldr r0, =divFreq1			@; Cargamos divisor de frecuencia
		ldrh r1, [r0]				
		ldr r0, =0x04000104			@; Lo guardamos junto al registro de control del timer 0x04000106
		orr r1, #0x00C10000			@; Prescaler = 1/64 -> 01 & IRQ Enable & Timer Start -> 11000001 0xC1 && divFreq1
		str r1, [r0]				@; Guardamos los el TIMER1_DATA y el TIMER1_CR 
		
		ldr r0, =escSen				@; Fijar escFac (factor de escalado actual)
		ldrh r1, [r0]
		cmp r1, #0					@; Si es fase de reducción (escSen = 0) fijar escFac a 1.0 (sprite entero)
		bne .LFin
		
		ldr r0, =escFac					@; Guardamos 1.0 en escFac
		mov r1, #0x0100					@; escFac 1,0 0.8.8 0000 0001 0000 0000 -> 0x0100
		mov r2, #0x0100					@; escFac 1,0 0.8.8 0000 0001 0000 0000 -> 0x0100
		strh r1, [r0]
		
		mov r0, #0						@; igrp = 0 (grupo de sprites 0)

		bl SPR_fijarEscalado
		
	.LFin:
		pop {r0-r2,pc}


@;TAREA 2Fc;
@;desactiva_timer1(); rutina para desactivar el timer 1.
	.global desactiva_timer1
desactiva_timer1:
		push {r0-r1,lr}
		
		ldr r0, =timer1_on			@; Ponemos timer1_on a 0 (fin ciclo de escalamiento)
		mov r1, #0					
		strh r1, [r0]
		
		ldr r0, =0x04000106			@; Cargamos el registro de control del timer 1 TIMER1_CR
		strh r1, [r0]				@; Apagado cambiando bits de control a 0
		
		pop {r0-r1,pc}



@;TAREA 2Fd;
@;rsi_timer1(); rutina de Servicio de Interrupciones del timer 1: incrementa el
@;	número de escalados y, si es inferior a 32, actualiza factor de escalado
@;	actual según el código de la variable 'escSen'; cuando se llega al máximo,
@;	se desactiva el timer1.
	.global rsi_timer1
rsi_timer1:
		push {r0-r5,lr}
		
		ldr r0, =escNum
		ldr r1, =escFac
		ldr r2, =escSen
		
		ldrh r3, [r0]				@; R3 = escNum (fase de escalado 0-32) no importa si reducción o aumento
		ldsh r4, [r1]				@; R4 = escFac (factor de escalado actual)
		ldrb r5, [r2]				@; R5 = escSen (sentido de escalado-> 0=reducción | 1=aumento)
		
		add r3, #1					@; escNum++
		cmp r3, #32					@; Si escNum = 32 se acaba ciclo de escalado y desactivamos timer
		beq .LRestart
		strh r3, [r0]				@; Guardamos escNum
		
		cmp r5, #0					@; Comprobamos sentido de escalado (0 = reducción | 1 = aumento)
		addeq r4, #32				@; Valor de escalado variara 32 (coma fija 0.8.8) según sentido de escalado	
		subne r4, #32
		strh r4, [r1]				@; Guardamos escFac
		
		mov r0, #0					@; Cambiamos el escalado del grupo 0 de sprites
		mov r1, r4
		mov r2, r4
		bl SPR_fijarEscalado
		
		ldr r0, =update_spr			@; Activamos update_spr para refrescar gráficos
		mov r1, #1
		strb r1, [r0]
		
		b .LEnd
		
	.LRestart:
		bl desactiva_timer1			@; Si escNum = 32 desactivamos timer
	
	.LEnd:
		pop {r0-r5,pc}



.end
