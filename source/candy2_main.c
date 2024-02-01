/*------------------------------------------------------------------------------

	$ candy2_main.c $

	Programa principal para la práctica de Computadores: Candy Crash para NDS
	(2º curso del Grado de Ingeniería Informática - ETSE - URV)
	
	Analista-programador principal: santiago.romani@urv.cat
	Analista-programador auxiliar:  pere.millan@urv.cat
	Programador 1: sergi.llobet@estudiants.urv.cat
	Programador 2: germanangel.puerto@estudiants.urv.cat
	Programador 3: jaume.tello@estudiants.urv.cat
	Programador 4: ivan.garciap@estudiants.urv.cat

------------------------------------------------------------------------------*/
#include <nds.h>
#include <stdio.h>
#include <time.h>
#include <candy2_incl.h>
#include "soundbank_bin.h"


/* variables globales */
char matrix[ROWS][COLUMNS];		// matriz global de juego
int seed32;						// semilla de números aleatorios
int level = 0;					// nivel del juego (nivel inicial = 0)
int points;						// contador global de puntos
int movements;					// número de movimientos restantes
int gelees;						// número de gelatinas restantes

/* variables globales de sonido*/
u16 sample_freq = 8500;
u8 vol = 127;
u8 pan = 64;
int channel = 0;
char vol_act = 1;

/* actualizar_contadores(code): actualiza los contadores que se indican con el
	parámetro 'code', que es una combinación binaria de booleanos, con el
	siguiente significado para cada bit:
		bit 0:	nivel
		bit 1:	puntos
		bit 2:	movimientos
		bit 3:	gelatinas  */
void actualizar_contadores(int code)
{
	if (code & 1) printf("\x1b[38m\x1b[1;8H %d", level);
	if (code & 2) printf("\x1b[39m\x1b[2;8H %d  ", points);
	if (code & 4) printf("\x1b[38m\x1b[1;28H %d ", movements);
	if (code & 8) printf("\x1b[37m\x1b[2;28H %d ", gelees);
}


/* inicializa_interrupciones(): configura las direcciones de las RSI y los bits
	de habilitación (enable) del controlador de interrupciones para que se
	puedan generar las interrupciones requeridas.*/
void inicializa_interrupciones()
{
	irqSet(IRQ_VBLANK, rsi_vblank);
	TIMER0_CR = 0x00;  		// inicialmente los timers no generan interrupciones
	irqSet(IRQ_TIMER0, rsi_timer0);		// cargar direcciones de las RSI
	irqEnable(IRQ_TIMER0);				// habilitar la IRQ correspondiente
	TIMER1_CR = 0x00;
	irqSet(IRQ_TIMER1, rsi_timer1);
	irqEnable(IRQ_TIMER1);
	TIMER2_CR = 0x00;
	irqSet(IRQ_TIMER2, rsi_timer2);
	irqEnable(IRQ_TIMER2);
	TIMER3_CR = 0x00;
	irqSet(IRQ_TIMER3, rsi_timer3);
	irqEnable(IRQ_TIMER3);
}


/* Programa principal: control general del juego */
int main(void)
{
	int lapse = 0;				// contador de tiempo sin actividad del usuario
	int change = 0;				// =1 indica que ha habido cambios en la matriz
	int falling = 0;			// =1 indica que los elementos estan bajando
	int fall_init = 1;			// =1 inicializa la frecuencia de movimiento
	int initializing = 1;		// =1 indica que hay que inicializar un juego
	int mX, mY, dX, dY;			// variables de detección de pulsaciones

	seed32 = time(NULL);		// fijar semilla de números aleatorios
	init_grafA();
	inicializa_interrupciones();

	consoleDemoInit();			// inicialización de pantalla de texto
	printf("\x1b[39m\x1b[0;11H CandyNDS");
	printf("\x1b[38m\x1b[1;0H  nivel:");
	printf("\x1b[39m\x1b[2;0H puntos:");
	printf("\x1b[38m\x1b[1;15H movimientos:");
	printf("\x1b[37m\x1b[2;15H   gelatinas:");
	printf("\x1b[38m\x1b[3;0H despl.fondo (tecla Y): no");
	printf("\x1b[39m\x1b[4;0H musica activada (tecla X): si");

	actualizar_contadores(15);

	soundEnable();
	channel = soundPlaySample(soundbank_bin, SoundFormat_8Bit, soundbank_bin_size, sample_freq, vol, pan, true, 0);

	do							// bucle principal del juego
	{
		if (initializing)		//////	SECCIÓN DE INICIALIZACIÓN	//////
		{
			inicializa_matriz(matrix, level);
			genera_sprites(matrix);
			genera_mapa1(matrix);
			genera_mapa2(matrix);
			retardo(5);
			initializing = 0;
			falling = 0;
			change = 0;
			lapse = 0;
			points = pun_obj[level];
			if (hay_secuencia(matrix))			// si hay secuencias
			{
				elimina_secuencias(matrix, mat_mar);	// eliminarlas
				points += calcula_puntuaciones(mat_mar);
				falling = 1;							// iniciar bajada
				fall_init = 1;
			}
			else change = 1;					//sino, revisar estado matriz
			movements = max_mov[level];
			gelees = contar_gelatinas(matrix);
			actualizar_contadores(15);
		}
		else if (falling)		//////	SECCIÓN BAJADA DE ELEMENTOS	//////
		{
			falling = baja_elementos(matrix);	// realiza la siguiente bajada
			if (falling)
			{									// si hay bajadas
				activa_timer0(fall_init);		// activar timer de movimientos
				while (timer0_on) swiWaitForVBlank();	// espera final
				fall_init = 0;					// continuar acelerando
			}
			else								// si no está bajando
			{
				if (hay_secuencia(matrix))		// si hay secuencias
				{
					elimina_secuencias(matrix, mat_mar);	// eliminarlas
					points += calcula_puntuaciones(mat_mar);
					falling = 1;				// volver a bajar
					fall_init = 1;				// con velocidad inicial
					gelees = contar_gelatinas(matrix);
					actualizar_contadores(10);
				}
				else change = 1;				// sino, revisar estado matriz
			}
		}
		else					//////	SECCIÓN DE JUGADAS	//////
		{
			if (procesar_touchscreen(matrix, &mX, &mY, &dX, &dY))
			{
				intercambia_posiciones(matrix, mX, mY, dX, dY);
				if (hay_secuencia(matrix))	// si el movimiento genera secuencia
				{
					elimina_secuencias(matrix, mat_mar);
					borra_puntuaciones();
					points += calcula_puntuaciones(mat_mar);
					falling = 1;
					fall_init = 1;
					movements--;
					gelees = contar_gelatinas(matrix);
					actualizar_contadores(14);
					lapse = 0;
				}
				else						// si no genera secuencia,
				{							// deshacer el cambio
					intercambia_posiciones(matrix, mX, mY, dX, dY);
				}
			}
			while (keysHeld() & KEY_TOUCH)		// esperar la liberación de la
			{	swiWaitForVBlank();				// pantalla táctil
				scanKeys();
			}
		}
		if (!falling)			//////	SECCIÓN DE DEPURACIÓN	//////
		{
			swiWaitForVBlank();
			scanKeys();
			if (keysHeld() & KEY_X) {
				vol = (vol_act ? 0:127);		// Si vol activado, vol->127, sino vol->0
				soundSetVolume(channel, vol);	// Seteamos el encendido o apagado
				printf("\x1b[39m\x1b[4;28H%s",(vol ? "si" : "no"));				
				vol_act = (vol == 127 ? 1:0); 	// Cambiamos futuro estado a encendido/apagado
				
				while (keysHeld() & KEY_X)		// esperar liberación tecla X
					{	swiWaitForVBlank();	
						scanKeys();
					}
			}			
			else if (keysHeld() & KEY_Y)	// activar o desactivar desplazam.
			{	if (timer3_on) desactiva_timer3();	// imagen del fondo 3
				else activa_timer3();
				printf("\x1b[38m\x1b[3;24H%s",(timer3_on ? "si" : "no"));
				while (keysHeld() & KEY_Y)		// esperar liberación tecla Y
				{	swiWaitForVBlank();	
					scanKeys();
				}
			}
			/*else if (keysHeld() & KEY_B)		// forzar cambio de nivel
			{	points = 0;
				gelees = 0;					// superado
				change = 1;
			}
			else if (keysHeld() & KEY_A)
			{
					recombina_elementos(matrix);
					activa_timer0(1);		// activar timer de movimientos
					while (timer0_on) swiWaitForVBlank();	// espera final
					change = 1;					// forzar nueva verificación
			}*/
			lapse++;					// incrementar paso del tiempo
		}
		if (change)				//////	SECCIÓN CAMBIO DE NIVEL	//////
		{
			change = 0;
			if (((points >= 0) && (gelees == 0))
					|| (movements == 0) || !hay_combinacion(matrix))
			{
				if ((points >= 0) && (gelees == 0))
					printf("\x1b[39m\x1b[6;20H _SUPERADO_");
				else if (movements == 0)
					printf("\x1b[39m\x1b[6;20H _REPETIR_");
				else
					printf("\x1b[39m\x1b[6;20H _BARAJAR_");
				
				printf("\x1b[39m\x1b[8;20H (pulse A)");
				do
				{	swiWaitForVBlank();
					scanKeys();					// esperar pulsación botón A
				} while (!(keysHeld() & KEY_A));
				printf("\x1b[6;20H           ");
				printf("\x1b[8;20H           ");	// borra mensajes
				
				if (((points >= 0) && (gelees == 0)) || (movements == 0))
				{
					if ((points >= 0) && (gelees == 0))
						level = (level + 1) % MAXLEVEL;	// incrementa nivel
					printf("\x1b[2;8H      ");	// borra puntos anteriores
					initializing = 1;			// pasa a inicializar nivel
				}
				else
				{
					recombina_elementos(matrix);
					activa_timer0(1);		// activar timer de movimientos
					while (timer0_on) swiWaitForVBlank();	// espera final
					change = 1;					// forzar nueva verificación
				}								// de combinaciones
				borra_puntuaciones();
			}
			lapse = 0;
		}
		else if (lapse >= 192)	//////	SECCIÓN DE SUGERENCIAS	//////
		{
			if (lapse == 192) 		// a los 8 segundos sin actividad (aprox.)
			{
				sugiere_combinacion(matrix, pos_sug);
				borra_puntuaciones();
			}
			if ((lapse % 64) == 0)		// cada segundo (aprox.)
			{
				reduce_elementos(matrix);
				aumenta_elementos(matrix);
			}
		}
	} while (1);				// bucle infinito
	
	return(0);					// nunca retornará del main
}

