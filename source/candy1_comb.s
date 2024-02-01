@;=                                                               		=
@;=== candy1_combi.s: rutinas para detectar y sugerir combinaciones   ===
@;=                                                               		=
@;=== Programador tarea 1G: jaume.tello@estudiants.urv.cat				  ===
@;=== Programador tarea 1H: jaume.tello@estudiants.urv.cat				  ===
@;=                                                             	 	=



.include "../include/candy1_incl.i"



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1G;
@; hay_combinacion(*matriz): rutina para detectar si existe, por lo menos, una
@;	combinación entre dos elementos (diferentes) consecutivos que provoquen
@;	una secuencia válida, incluyendo elementos en gelatinas simples y dobles.
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 si hay una secuencia, 0 en otro caso
	.global hay_combinacion
hay_combinacion:
		push {r1-r12, lr}
		
		mov r11, #COLUMNS
		mov r12, #ROWS			
		mov r1, #0				@;Fila 'f'			
	.Lcanviar_fila:
		mov r2, #0				@;Ens situem a la 1a columna 'c'
	.Lrecorrer_mat:
		mla r3, r1, r11, r2
		add r4, r0, r3			@;R4 apunta a l'element (f,c) de 'mat'
		ldrb r5, [r4]			@;Obtenim l'element a comprobar
		cmp r5, #7
		beq .Lsiguiente_lmn		@;Ignorem la posició actual si es tracta d'un bloc sòlid
		cmp r5, #15
		beq .Lsiguiente_lmn		@;Ignorem la posició actual si es tracta d'un forat
		and r5, #7				@;Filtrem el valor amb una màscara per a que en el cas de ser un 8 o un 16, ens doni 0
		cmp r5, #0
		beq .Lsiguiente_lmn		@;Ignorem la posició actual si el valor filtrat és un 0
		
	.Lvertical:
		sub r12, #1				@;Reduim en 1 el maxim de files per tal de poder fer una comparació precisa després
		cmp r1, r12
		add r12, #1				@;Tornem el maxim de files al seu valor inicial
		beq .Lhoritzontal		@;Si estem a l'última fila, només canviarem en horitzontal
		add r9, r2, r11			@;Incrementem en 1 la fila actual (o en 9 la columna actual) per a posicionar-nos a l`element inferior de la posició actual
		mla r3, r1, r11, r9
		add r6, r0, r3			@;R6 apunta a l'element (f+1,c) de 'mat'
		ldrb r10, [r6]			@;Obtenim l'element a comprobar
		mov r11, r2				@;R11 = columna de (f+1, c)
		add r12, r1, #1			@;R12 = fila de (f+1, c)
		cmp r10, #7
		beq .Lhoritzontal		@;Si l'element d'abaix és un bloc sòlid, no els podem canviar i mirem de canviar amb l'element en horitzontal
		cmp r10, #15
		beq .Lhoritzontal		@;Si l'element d'abaix és un forat, no els podem canviar i mirem de canviar amb l'element en horitzontal
		and r10, #7				@;Filtrem el valor amb una màscara per a que en el cas de ser un 8 o un 16, ens doni 0
		cmp r10, #0
		beq .Lhoritzontal		@;Ignorem l'element si el valor filtrat és un 0
		cmp r5, r10
		beq .Lhoritzontal		@;Passem al següent element en cas de que l'element actual i el de sota seu siguin iguals
		b .Lcanvi				@;Si els dos elements no coincideixen, fem el canvi
	.Lfi_vertical:
	
	.Lhoritzontal:
		mov r11, #COLUMNS
		mov r12, #ROWS
		sub r11, #1				@;Reduim en 1 el maxim de files per tal de poder fer una comparació precisa després
		cmp r2, r11             
		add r11, #1             @;Tornem el maxim de files al seu valor inicial
		beq .Lsiguiente_lmn		@;Si estem a l'última columna, passarem al següent element
		add r9, r2, #1			@;Incrementem en 1 la columna actual per a posicionar-nos al següent element de la matriu
		mla r3, r1, r11, r9
		add r6, r0, r3			@;R6 apunta a l'element (f,c+1) de 'mat'
		ldrb r10, [r6]			@;Obtenim l'element a comprobar
		mov r11, r9				@;R11 = columna de (f, c+1)
		mov r12, r1             @;R12 = fila de (f, c+1)
		cmp r10, #7
		beq .Lsiguiente_lmn		@;Si l'element d'abaix és un bloc sòlid, no els podem canviar i mirem de canviar amb l'element en horitzontal
		cmp r10, #15
		beq .Lsiguiente_lmn		@;Si l'element d'abaix és un forat, no els podem canviar i mirem de canviar amb l'element en horitzontal
		and r10, #7				@;Filtrem el valor amb una màscara per a que en el cas de ser un 8 o un 16, ens doni 0
		cmp r10, #0
		beq .Lsiguiente_lmn		@;Ignorem l'element si el valor filtrat és un 0
		cmp r5, r10
		beq .Lsiguiente_lmn		@;Passem al següent element en cas de que l'element actual i el de sota seu siguin iguals
		mov r3, #-1				@;Posar R3 a -1 ens permetrà comprobar posteriorment si s'ha intentat fer el canvi en horitzontal o no
	.Lfi_horitzontal:
	
	.Lcanvi:
		ldrb r7, [r4]			@;aux1 = element1
		ldrb r8, [r6]			@;aux2 = element2
		strb r8, [r4]			@;element1 = aux2		Intercanviem els valors de les direccions r4<->r6
		strb r7, [r6]			@;element2 = aux1
		mov r10, r4				@;Guardem R4 en un registre temporal
		mov r4, r0				@;R4 passa a ser la direcció base de la matriu
		bl detectar_orientacion	@;R1 i R2 ja son fila i columna respectivament
		mov r9, r0				@;Guardem el resultat de detectar_orientacion()
		mov r5, r1				@;Guardem la fila actual (R1) en un registre temporal
		mov r1, r12				@;Guardem la fila de l'altre element a R1
		mov r12, r2				@;Guardem la columna actual (R2) en un registre temporal
		mov r2, r11				@;Guardem la columna de l'altre element a R1
		cmp r9, #6
		bleq detectar_orientacion@;Si no hem detectat orientació anteriorment, tornem a cridar detectar_orientacion per a l'altre element, sinó no fa falta
		cmp r0, #6
		movlo r9, r0			@;Si s'ha trobat una combinació, en guardem l'orientació a R9
		mov r2, r12				@;Retornem la columna actual al seu registre original
		mov r1, r5				@;Retornem la fila actual al seu registre original
		mov r0, r4				@;Retornem la direcció base de la matriu a R0
		mov r4, r10				@;Tornem el valor anterior d'R4
		
		ldrb r7, [r6]			@;aux1 = element2
		ldrb r8, [r4]			@;aux2 = element1
		strb r8, [r6]			@;element2 = aux2		Intercanviem els valors de les direccions r6<->r4 novament per a deixar la matriu tal i com estava
		strb r7, [r4]			@;element1 = aux1
		cmp r9, #6
		blo .Lsi_comb			@;Si detectar_orientacion() ens retorna algo diferent a un 6, hi ha combinació
		cmp r3, #-1				@;Mirem si ja hem fet el canvi horitzontal
		bne .Lhoritzontal		@;Si l'hem fet, passem al següent element, sinó, anem a fer-lo
	.Lfi_canvi:
	
	.Lsiguiente_lmn:
		mov r11, #COLUMNS
		mov r12, #ROWS
		add r2, #1				@;Incrementem en 1 les columnas
		cmp r2, r11
		blo .Lrecorrer_mat		@;Recorre todas las columnas
		add r1, #1				@;Incrementem en 1 les files
		cmp r1, r12
		blo .Lcanviar_fila		@;Recorre todas las filas
		b .Lno_comb				@;Quan estiguem a l'últim element, no hi haurà combinació
	.Lfi_recorrer_mat:
	
	.Lsi_comb:
		mov r0, #1
		b .Lfi
	.Lfi_si_comb:
	
	.Lno_comb:
		mov r0, #0
	.Lfi_no_comb:
	
	.Lfi:	
		pop {r1-r12, pc}



@;TAREA 1H;
@; sugiere_combinacion(*matriz, *sug): rutina para detectar una combinación
@;	entre dos elementos (diferentes) consecutivos que provoquen una secuencia
@;	válida, incluyendo elementos en gelatinas simples y dobles, y devolver
@;	las coordenadas de las tres posiciones de la combinación (por referencia).
@;	Restricciones:
@;		* se supone que existe por lo menos una combinación en la matriz
@;			 (se debe verificar antes con la rutina 'hay_combinacion')
@;		* la combinación sugerida tiene que ser escogida aleatoriamente de
@;			 entre todas las posibles, es decir, no tiene que ser siempre
@;			 la primera empezando por el principio de la matriz (o por el final)
@;		* para obtener posiciones aleatorias, se invocará la rutina 'mod_random'
@;			 (ver fichero "candy1_init.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección del vector de posiciones (char *), donde la rutina
@;				guardará las coordenadas (x1,y1,x2,y2,x3,y3), consecutivamente.
	.global sugiere_combinacion
sugiere_combinacion:
		push {r2-r12, lr}
		mov r11, #COLUMNS
		mov r12, #ROWS	
		mov r10, r0				@;Guardem la direcció base de la matriu a un registre temporal
		mov r0, r12				
		bl mod_random			@;Cridem mod_random per a que ens retorni un numero entre 0 i 8 (serà la nostre fila actual)
		mov r2, r0				@;R2 conté la fila actual
		mov r0, r11
		bl mod_random			@;Cridem mod_random per a que ens retorni un numero entre 0 i 8 (serà la nostre columna actual)
		mov r3, r0				@;R3 conté la columna actual
		mov r0, r10				@;Retornem la direcció base de la matriu a R0 (per comoditat)
		b .Lrecorre_mat
		
	.Lcanviar_row:
		mov r3, #0				@;Ens situem a la 1a columna 'c' (f, 0)
	.Lrecorre_mat:
		mla r5, r2, r11, r3
		add r4, r0, r5			@;Obtenim una posició (f, c) aleatoria de la matriu
		ldrb r5, [r4]			@;Obtenim el valor de la posició aleatoria anterior
		cmp r5, #7
		beq .Lnext_lmn			@;Ignorem la posició actual si es tracta d'un bloc sòlid
		cmp r5, #15
		beq .Lnext_lmn			@;Ignorem la posició actual si es tracta d'un forat
		and r5, #7				@;Filtrem el valor amb una màscara per a que en el cas de ser un 8 o un 16, ens doni 0
		cmp r5, #0
		beq .Lnext_lmn			@;Ignorem la posició actual si el valor filtrat és un 0
		
	.Lvert:
		sub r12, #1
		cmp r2, r12
		add r12, #1
		beq .Lhorit				@;Si estem a l'última fila, només canviarem en horitzontal
		add r9, r3, r11			@;Per posicionar-nos a l'element de sota, hem d'incrementar el número de columnes amb el màxim de columnes, una altre manera és simplement incrementar en 1 les files
		mla r7, r2, r11, r9		
		add r6, r0, r7			@;R6 apunta a l'element (f+1,c) de 'mat'
		ldrb r10, [r6]			@;Obtenim l'element a comprobar
		mov r11, r3				@;R11 = columna de (f+1, c)
		add r12, r2, #1			@;R12 = fila de (f+1, c)
		cmp r10, #7
		beq .Lhorit				@;Si l'element d'abaix és un bloc sòlid, no els podem canviar i mirem de canviar amb l'element en horitzontal
		cmp r10, #15
		beq .Lhorit				@;Si l'element d'abaix és un forat, no els podem canviar i mirem de canviar amb l'element en horitzontal
		and r10, #7				@;Filtrem el valor amb una màscara per a que en el cas de ser un 8 o un 16, ens doni 0
		cmp r10, #0
		beq .Lhorit				@;Ignorem l'element si el valor filtrat és un 0
		cmp r5, r10
		beq .Lhorit				@;Passem al següent element en cas de que l'element actual i el de sota seu siguin iguals
		mov r5, #0			
		b .Lswitch
	.Lfi_vert:
	
	.Lhorit:
		mov r11, #COLUMNS
		mov r12, #ROWS
		sub r11, #1
		cmp r3, r11
		add r11, #1
		beq .Lnext_lmn			@;Si estem a l'última columna, passarem al següent element
		add r9, r3, #1			@;Per posicionar-nos al següent element de la matriu, incrementem en 1 la columna actual
		mla r7, r2, r11, r9
		add r6, r0, r7			@;R6 apunta a l'element (f,c+1) de 'mat'
		ldrb r10, [r6]			@;Obtenim l'element a comprobar
		mov r11, r9				@;R11 = columna de (f, c+1)
		mov r12, r2             @;R12 = fila de (f, c+1)
		cmp r10, #7
		beq .Lnext_lmn			@;Si l'element d'abaix és un bloc sòlid, no els podem canviar i mirem de canviar amb l'element en horitzontal
		cmp r10, #15
		beq .Lnext_lmn			@;Si l'element d'abaix és un forat, no els podem canviar i mirem de canviar amb l'element en horitzontal
		and r10, #7				@;Filtrem el valor amb una màscara per a que en el cas de ser un 8 o un 16, ens doni 0
		cmp r10, #0
		beq .Lnext_lmn			@;Ignorem l'element si el valor filtrat és un 0
		cmp r5, r10
		beq .Lnext_lmn			@;Passem al següent element en cas de que l'element actual i el de sota seu siguin iguals
		mov r5, #-1				@;Posar R5 a -1 ens permetrà comprobar posteriorment si s'ha intentat fer el canvi en horitzontal o no
	.Lfi_horit:
	
	.Lswitch:
		ldrb r7, [r4]			@;aux1 = element1
		ldrb r8, [r6]			@;aux2 = element2
		strb r8, [r4]			@;element1 = aux2		Intercanviem els valors de les direccions r4<->r6
		strb r7, [r6]			@;element2 = aux1
		mov r4, r0				@;R4 es la direcció base de la matriu
		mov r7, r1				@;Guardem la direccio base del vector en un registre temporal	
		mov r1, r2				@;R1 es la fila actual
		mov r2, r3				@;R2 es la columna actual
		bl detectar_orientacion	
		mov r9, r0				@;Guardem el resultat en un registre temporal per a la seva posterior comparació
		mov r8, r1				@;Guardem la columna actual (R1) en un registre temporal
		mov r1, r12				@;Guardem la fila de l'altre element a R1
		mov r12, r2				@;Guardem la columna actual (R2) en un registre temporal
		mov r2, r11				@;Guardem la columna de l'altre element a R2
		cmp r9, #6
		bleq detectar_orientacion@;Si no hem detectat orientació anteriorment, tornem a cridar detectar_orientacion per a l'altre element, sinó no fa falta
		mov r10, #6				@;Inicialitzem R10 per no agafar valors erronis posteriorment
		cmp r9, #6
		moveq r10, r0			@;Només actualitzem el valor d'R10 si no s'ha trobat cap combinació a l'última crida
		mov r0, r4				@;Tornem la direcció base de la matriu a R0
		mov r12, r1				@;Tornem la fila de l'altre element al seu registre original
		mov r1, r7				@;Retornem la direccio base del vector a R1	
		mov r2, r8				@;Retornem la columna de l'element actual a R2
		
		mov r8, #COLUMNS
		mla r7, r2, r8, r3
		add r4, r0, r7			@;Tornem a obtenir la posició de la matriu on està l'element actual ja que anteriorment hem matxacat el valor d'R4
		
		ldrb r7, [r6]			@;aux1 = element2
		ldrb r8, [r4]			@;aux2 = element1
		strb r8, [r6]			@;element2 = aux2		Intercanviem els valors r6<->r4 novament per a deixar la matriu tal i com estava
		strb r7, [r4]			@;element1 = aux1
		
		
		cmp r9, #6
		cmpeq r10, #6
		beq .Lx					@;Si no es detecta orientació ni a la 1a ni a la 2a posició, mirem si hem fet el canvi horitzontal
		b .Ly					@;Si es detecta alguna orientació, anem a buscar les posicions dels elements que la formen
		
	.Lx:
		cmp r5, #-1
		ldrb r5, [r4] 
		bne .Lhorit				@;Si no s'ha fet el canvi horitzontal, procedim a fer-lo
		beq .Lnext_lmn			@;Si ja s'ha fet el canvi horitzontal i tot i així no s'ha trobat cap orientació, passem al següent element
		
	.Ly:
		cmp r9, #6
		blo .Lcpiy				@;Si a la 1a posició comprobada hi ha una orientació, saltem a .Lcpiy
		b .Lcpix				@;Si no s'ha trobat orientació a la 1a posició, vol dir que la 2a sí que en té
	.Lcpiy:
		mov r8, r0				@;
		mov r0, r1				@;
		mov r1, r2				@;Passem els paràmetres corresponents a... 
		mov r2, r3				@;...la funció generar_posiciones()
		mov r3, r9				@;
		cmp r9, #0
		moveq r4, #2			@;Si c.ori indica est, el cpi solament pot ser 2 (vertical amunt)
		beq .Lready				@;Un cop hem passat tots els parametres, anem a fer la crida a al funció
		cmp r9, #1
		moveq r4, #0			@;Si c.ori indica sud, el cpi solament pot ser 0 (horitzontal esquerra)
		beq .Lready				@;Un cop hem passat tots els parametres, anem a fer la crida a al funció
		cmp r9, #2
		cmpeq r1, r12
		moveq r4, #0			@;Si c.ori indica oest i els elements x i y estan a la mateixa fila, el cpi ha de ser 0 (horitzontal esquerra)
		movlo r4, #2			@;Si c.ori indica oest i l'element x està una fila per sobre de l'element y, el cpi ha de ser 2 (vertical amunt)
		bls .Lready				@;Un cop hem passat tots els parametres, anem a fer la crida a al funció
		cmp r9, #4
		moveq r4, #2			@;Si c.ori indica horitzontal, el cpi solament pot ser 2 (vertical amunt)
		beq .Lready				@;Un cop hem passat tots els parametres, anem a fer la crida a al funció
		cmp r9, #5
		moveq r4, #0			@;Si c.ori indica vertical, el cpi solament pot ser 0 (horitzontal esquerra)
		beq .Lready				@;Un cop hem passat tots els parametres, anem a fer la crida a al funció
		cmp r9, #3
		cmpeq r2, r11
		moveq r4, #2			@;Si c.ori indica nord i els elements x i y estan a la mateixa columna, el cpi ha de ser 2 (vertical amunt)
		movhi r4, #0			@;Si c.ori indica nord i l'element x està a la columna anterior de l'element y, el cpi ha de ser 0 (horitzontal esquerra)
		b .Lready				@;Un cop hem passat tots els parametres, anem a fer la crida a al funció
	.Lcpix:
		mov r8, r0				@;
		mov r0, r1				@;
		mov r1, r12				@;Passem els paràmetres corresponents a... 
		mov r6, r2				@;...la funció generar_posiciones()
		mov r2, r11				@;
		mov r7, r3				@;
		mov r3, r10				@;
		
		cmp r10, #2	
		moveq r4, #3			@;Si c.ori indica oest, el cpi solament pot ser 3 (vertical abaix)
		beq .Lready				@;Un cop hem passat tots els parametres, anem a fer la crida a al funció
		cmp r10, #3
		moveq r4, #1			@;Si c.ori indica nord, el cpi solament pot ser 1 (horitzontal dreta)
		beq .Lready				@;Un cop hem passat tots els parametres, anem a fer la crida a al funció
		cmp r10, #4
		moveq r4, #3			@;Si c.ori indica horitzontal, el cpi solament pot ser 3 (vertical abaix)
		beq .Lready				@;Un cop hem passat tots els parametres, anem a fer la crida a al funció
		cmp r10, #5
		moveq r4, #1			@;Si c.ori indica vertical, el cpi solament pot ser 1 (horitzontal dreta)
		beq .Lready				@;Un cop hem passat tots els parametres, anem a fer la crida a al funció
		cmp r10, #1
		cmpeq r2, r7
		moveq r4, #3			@;Si c.ori indica sud i els elements x i y estan a la mateixa columna, el cpi ha de ser 3 (vertical abaix)
		movhi r4, #1			@;Si c.ori indica sud i l'element y està una columna per davant de l'element x, el cpi ha de ser 1 (horitzontal dreta)
		bhs .Lready				@;Un cop hem passat tots els parametres, anem a fer la crida a al funció
		cmp r10, #0
		cmpeq r1, r6
		moveq r4, #1			@;Si c.ori indica est i els elements x i y estan a la mateixa fila, el cpi ha de ser 1 (horitzontal dreta)
		movhi r4, #3			@;Si c.ori indica est i l'element y està una fila per sobre de l'element x, el cpi ha de ser 3 (vertical abaix)
	.Lready:
		bl generar_posiciones	@;Un cop hem passat tots els paràmetres correctament, ens disposem a buscar les posicions de suggerència
		b .Lfi_recorre_mat		@;Quan tinguem el vector de posicions fet, ja hem acabat el procediment
	.Lfi_switch:
	
	.Lnext_lmn:
		mov r11, #COLUMNS
		mov r12, #ROWS
		add r3, #1				@;Incrementem en 1 les columnes
		cmp r3, r11
		blo .Lrecorre_mat		@;Recorrem totes les columnes
		add r2, #1				@;Incrementem en 1 les files
		cmp r2, r12
		blo .Lcanviar_row		@;Recorrem totes les files
		mov r2, #0				@;Si hem arribat al final de la matriu, ens tornem a posicionar...
		mov r3, #0				@;...al principi d'aquesa posant les files i columnes actuals a 0
		b .Lrecorre_mat			@;Tornem al principi de la matriu i seguim buscant una combinació
	.Lfi_recorre_mat:
		
		pop {r2-r12, pc}




@;:::RUTINAS DE SOPORTE:::



@; generar_posiciones(vect_pos,f,c,ori,cpi): genera las posiciones de sugerencia
@;	de combinación, a partir de la posición inicial (f,c), el código de
@;	orientación 'ori' y el código de posición inicial 'cpi', dejando las
@;	coordenadas en el vector 'vect_pos'.
@;	Restricciones:
@;		* se supone que la posición y orientación pasadas por parámetro se
@;			corresponden con una disposición de posiciones dentro de los límites
@;			de la matriz de juego
@;	Parámetros:
@;		R0 = dirección del vector de posiciones 'vect_pos'
@;		R1 = fila inicial 'f'
@;		R2 = columna inicial 'c'
@;		R3 = código de orientación;
@;				inicio de secuencia: 0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte
@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
@;		R4 = código de posición inicial:
@;				0 -> izquierda, 1 -> derecha, 2 -> arriba, 3 -> abajo
@;	Resultado:
@;		vector de posiciones (x1,y1,x2,y2,x3,y3), devuelto por referencia
generar_posiciones:
		push {r5, lr}
		
		cmp r3, #0				@;
		beq .Lest				@;
		cmp r3, #1				@;
		beq .Lsud				@;
		cmp r3, #2				@;
		beq .Loest				@;Saltem a un lloc o altre depenent...
		cmp r3, #3				@;...de en quin sentit estigui la...
		beq .Lnord				@;...orientació de la combinació
		cmp r3, #4				@;
		beq .Lhoritzon			@;
		cmp r3, #5				@;
		b .Lvertic				@;
		
		
	.Lest:	
		add r5, r2, #1			@;Obtenim c+1
		strb r5, [r0]			@;Ho guardem a la 1a posició de vect_pos
		strb r1, [r0, #1]		@;Guardem la fila actual a la 2a posició de vect_pos
		add r5, r2, #2			@;Obtenim c+2
		strb r5, [r0, #2]		@;Ho guardem a la 3a posició de vect_pos
		strb r1, [r0, #3]		@;Guardem la fila actual a la 4a posició de vect_pos
		b .Lmira_pos_ini
	.Lsud:
		strb r2, [r0]			@;Guardem la columna actual a la 1a posició de vect_pos
		add r5, r1, #1			@;Obtenim f+1
		strb r5, [r0, #1]		@;Ho guardem a la 2a posició de vect_pos
		strb r2, [r0, #2]		@;Guardem la columna actual a la 3a posició de vect_pos
		add r5, r1, #2			@;Obtenim f+2
		strb r5, [r0, #3]		@;Ho guardem a la 4a posició de vect_pos
		b .Lmira_pos_ini
	.Loest:
		sub r5, r2, #1			@;Obtenim c-1
		strb r5, [r0]			@;Ho guardem a la 1a posició de vect_pos
		strb r1, [r0, #1]		@;Guardem la fila actual a la 2a posició de vect_pos
		sub r5, r2, #2			@;Obtenim c-2
		strb r5, [r0, #2]		@;Ho guardem a la 3a posició de vect_pos
		strb r1, [r0, #3]		@;Guardem la fila actual a la 4a posició de vect_pos
		b .Lmira_pos_ini
	.Lnord:
		strb r2, [r0]			@;Guardem la columna actual a la 1a posició de vect_pos
		sub r5, r1, #1			@;Obtenim f-1
		strb r5, [r0, #1]		@;Ho guardem a la 2a posició de vect_pos
		strb r2, [r0, #2]		@;Guardem la columna actual a la 3a posició de vect_pos
		sub r5, r1, #2			@;Obtenim f-2
		strb r5, [r0, #3]		@;Ho guardem a la 4a posició de vect_pos
		b .Lmira_pos_ini
	.Lhoritzon:
		sub r5, r2, #1			@;Obtenim c-1
		strb r5, [r0]			@;Ho guardem a la 1a posició de vect_pos
		strb r1, [r0, #1]		@;Guardem la fila actual a la 2a posició de vect_pos
		add r5, r2, #1			@;Obtenim c+1
		strb r5, [r0, #2]		@;Ho guardem a la 3a posició de vect_pos
		strb r1, [r0, #3]		@;Guardem la fila actual a la 4a posició de vect_pos
		b .Lmira_pos_ini
	.Lvertic:
		strb r2, [r0]			@;Guardem la columna actual a la 1a posició de vect_pos
		sub r5, r1, #1			@;Obtenim f-1
		strb r5, [r0, #1]		@;Ho guardem a la 2a posició de vect_pos
		strb r2, [r0, #2]		@;Guardem la columna actual a la 3a posició de vect_pos
		add r5, r1, #1			@;Obtenim f+1
		strb r5, [r0, #3]		@;Ho guardem a la 4a posició de vect_pos
		b .Lmira_pos_ini
		
	.Lmira_pos_ini:
		cmp r4, #0				@;
		beq .Lleft              @;
		cmp r4, #1              @;
		beq .Lright             @;Saltem a un lloc o altre depenent de...
		cmp r4, #2              @;...quina és la nostre posició inicial...
		beq .Ldown              @;
		cmp r4, #3              @;
		beq .Lup				@;
		
	.Lleft:	
		add r5, r2, #1			@;Obtenim c+1
		strb r5, [r0, #4]		@;Ho guardem a la 5a posició de vect_pos
		strb r1, [r0, #5]		@;Guardem la fila actual a la 6a posició de vect_pos
		b .Lfinal
	.Lright:
		sub r5, r2, #1			@;Obtenim c-1
		strb r5, [r0, #4]		@;Ho guardem a la 5a posició de vect_pos
		strb r1, [r0, #5]		@;Guardem la fila actual a la 6a posició de vect_pos
		b .Lfinal
	.Lup:
		strb r2, [r0, #4]		@;Guardem la columna actual a la 5a posició de vect_pos
		sub r5, r1, #1			@;Obtenim f-1
		strb r5, [r0, #5]		@;Ho guardem a la 6a posició de vect_pos
		b .Lfinal
	.Ldown:
		strb r2, [r0, #4]		@;Guardem la columna actual a la 5a posició de vect_pos
		add r5, r1, #1			@;Obtenim f+1
		strb r5, [r0, #5]		@;Ho guardem a la 6a posició de vect_pos
	.Lfinal:
		
		pop {r5, pc}



@; detectar_orientacion(f,c,mat): devuelve el código de la primera orientación
@;	en la que detecta una secuencia de 3 o más repeticiones del elemento de la
@;	matriz situado en la posición (f,c).
@;	Restricciones:
@;		* para proporcionar aleatoriedad a la detección de orientaciones en las
@;			que se detectan secuencias, se invocará la rutina 'mod_random'
@;			(ver fichero "candy1_init.s")
@;		* para detectar secuencias se invocará la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;		* sólo se tendrán en cuenta los 3 bits de menor peso de los códigos
@;			almacenados en las posiciones de la matriz, de modo que se ignorarán
@;			las marcas de gelatina (+8, +16)
@;	Parámetros:
@;		R1 = fila 'f'
@;		R2 = columna 'c'
@;		R4 = dirección base de la matriz
@;	Resultado:
@;		R0 = código de orientación;
@;				inicio de secuencia: 0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte
@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
@;				sin secuencia: 6 
detectar_orientacion:
		push {r3, r5, lr}
		
		mov r5, #0				@;R5 = índice bucle de orientaciones
		mov r0, #4
		bl mod_random
		mov r3, r0				@;R3 = orientación aleatoria (0..3)
	.Ldetori_for:
		mov r0, r4
		bl cuenta_repeticiones
		cmp r0, #1
		beq .Ldetori_cont		@;no hay inicio de secuencia
		cmp r0, #3
		bhs .Ldetori_fin		@;hay inicio de secuencia
		add r3, #2
		and r3, #3				@;R3 = salta dos orientaciones (módulo 4)
		mov r0, r4
		bl cuenta_repeticiones
		add r3, #2
		and r3, #3				@;restituye orientación (módulo 4)
		cmp r0, #1
		beq .Ldetori_cont		@;no hay continuación de secuencia
		tst r3, #1
		bne .Ldetori_vert
		mov r3, #4				@;detección secuencia horizontal
		b .Ldetori_fin
	.Ldetori_vert:
		mov r3, #5				@;detección secuencia vertical
		b .Ldetori_fin
	.Ldetori_cont:
		add r3, #1
		and r3, #3				@;R3 = siguiente orientación (módulo 4)
		add r5, #1
		cmp r5, #4
		blo .Ldetori_for		@;repetir 4 veces
		
		mov r3, #6				@;marca de no encontrada
		
	.Ldetori_fin:
		mov r0, r3				@;devuelve orientación o marca de no encontrada
		
		pop {r3, r5, pc}





.end
