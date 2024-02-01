/*------------------------------------------------------------------------------

	$ candy2_graf.c $

	Funciones de inicializaci�n de gr�ficos (ver "candy2_main.c")

	Analista-programador: santiago.romani@urv.cat
	Programador tarea 2A: sergi.llobet@estudiants.urv.cat
	Programador tarea 2B: germanangel.puerto@estudiants.urv.cat
	Programador tarea 2C: jaume.tello@estudiants.urv.cat
	Programador tarea 2D: ivan.garciap@estudiants.urv.cat

------------------------------------------------------------------------------*/
#include <nds.h>
#include <candy2_incl.h>
#include <Graphics_data.h>
#include <Sprites_sopo.h>


/* variables globales */
int n_sprites = 0;					// n�mero total de sprites creados
elemento vect_elem[ROWS*COLUMNS];	// vector de elementos
gelatina mat_gel[ROWS][COLUMNS];	// matriz de gelatinas



// TAREA 2Ab
/* genera_sprites(): inicializar los sprites con prioridad 1, creando la
	estructura de datos y las entradas OAM de los sprites correspondiente a la
	representaci�n de los elementos de las casillas de la matriz que se pasa
	por par�metro (independientemente de los c�digos de gelatinas).*/
void genera_sprites(char mat[][COLUMNS])
{
		int elem = ROWS*COLUMNS;
	char mat_basicos[ROWS][COLUMNS];				// creamos una matriz para conseguir los elementos basicos de "mat"
	int i, j;
	n_sprites = 0;

	for(i = 0; i < elem; i++) {
		SPR_fijarPrioridad(i, 1);
	}
	
	SPR_ocultarSprites(128);
	
	for (int i = 0; i<elem; i++)
	{
		vect_elem[i].ii=-1;					// establecemos (-1) ya que esta inactivo
	}
	
	for(i = 0; i < ROWS; i++) {
		for(j = 0; j < COLUMNS; j++) {
			if((mat[i][j] != 0) && (mat[i][j] != 7) && (mat[i][j] != 15)) {
				mat_basicos[i][j] = (mat[i][j] & 0x07);			//aplicamos la mascara de 7 porque no tenemos en cuenta las gelatinas
			}
		}
	}
	
	for(i = 0; i < ROWS; i++) {
		for(j = 0; j < COLUMNS; j++) {
			if((mat[i][j] != 0) && (mat[i][j] != 7) && (mat[i][j] != 15)) {			// no puede ser ni 0 ni 7 ni 15
				crea_elemento(mat_basicos[i][j], i, j);								
				n_sprites++;
			}
		}
	}
	
	SPR_actualizarSprites(OAM, 128);



}



// TAREA 2Bb
/* genera_mapa2(*mat): generar un mapa de baldosas como un tablero ajedrezado
	de metabaldosas de 32x32 p�xeles (4x4 baldosas), en las posiciones de la
	matriz donde haya que visualizar elementos con o sin gelatina, bloques
	s�lidos o espacios vac�os sin elementos, excluyendo solo los huecos.*/
void genera_mapa2(char mat[][COLUMNS])
{
	for(int i = 0; i < ROWS; i++){
		for(int j = 0; j < COLUMNS; j++){
			if(mat[i][j] != 15){
				if ((i+j)% 2==0) fija_metabaldosa((void *) 0x06000000+1*2*1024, i, j, 19);
				else fija_metabaldosa((void *) 0x06000000+1*2*1024, i, j, 19);
			}
			else fija_metabaldosa((void *) 0x06000000+1*2*1024, i, j, 19);
		}
	}



}



// TAREA 2Cb
/* genera_mapa1(*mat): generar un mapa de baldosas correspondiente a la
	representaci�n de las casillas de la matriz que se pasa por par�metro,
	utilizando metabaldosas de 32x32 p�xeles (4x4 baldosas), visualizando
	las gelatinas simples y dobles y los bloques s�lidos con las metabaldosas
	correspondientes, (para las gelatinas, basta con utilizar la primera
	metabaldosa de la animaci�n); adem�s, hay que inicializar la matriz de
	control de la animaci�n de las gelatinas mat_gel[][COLUMNS]. */
void genera_mapa1(char mat[][COLUMNS])
{
	int i = 0, j = 0;
    for(i = 0; i<ROWS; i++) {    //para todas las filas
        for(j = 0; j<COLUMNS; j++) {    //para todas las columnas
            if(mat[i][j] < 7 || mat[i][j] == 15)     //donde no exista bloque s�lido ni gelatina, 
                fija_metabaldosa((void *)0x06000000, i, j, 19);    //copiar una metabaldosa transparente (�ndice 19)
            else if(mat[i][j] == 7)         //donde exista un bloque s�lido, 
                fija_metabaldosa((void *)0x06000000, i, j, 16);    //copiar la metabaldosa que representa una verja (�ndice 16)
            else if(mat[i][j] >= 8 && mat[i][j] <= 22) {    //donde exista gelatina simple o doble (con o sin elemento)
                int rand = mod_random(8);    //generar un valor aleatorio entre 0 y 7 
				if(mat[i][j] < 16) {
					fija_metabaldosa((void *)0x06000000, i, j, rand);		//y usar ese valor aleatorio para calcular una
				} else {													//metabaldosa de animaci�n de gelatina (simple o doble)
					rand = rand + 8;
					fija_metabaldosa((void *)0x06000000, i, j, rand);
				}
				mat_gel[i][j].im = rand;
				rand = mod_random(10)+1;
				mat_gel[i][j].ii = rand;		//setteamos �ndice de animaci�n random del 1 al 10
			}
			
			if(mat[i][j] < 8 || mat[i][j] == 15) {		//para todos los elementos que no sean gelatinas
				mat_gel[i][j].ii = -1;
			}
        }
    }
	
}



// TAREA 2Db
/* ajusta_imagen3(int ibg): rotar 90 grados a la derecha la imagen del fondo
	cuyo identificador se pasa por par�metro (fondo 3 del procesador gr�fico
	principal), y desplazarla para que se visualice en vertical a partir del
	primer p�xel de la pantalla. */
void ajusta_imagen3(int ibg)
{
	bgSetCenter(ibg, 256, 128); //128 y 50 provisionales
	bgSetRotate(ibg, degreesToAngle(270));
	bgSetScroll(ibg, 128, -1); //128 y 50 provisionales
	bgUpdate();
}




// TAREAS 2Aa,2Ba,2Ca,2Da
/* init_grafA(): inicializaciones generales del procesador gr�fico principal,
				reserva de bancos de memoria y carga de informaci�n gr�fica,
				generando el fondo 3 y fijando la transparencia entre fondos.*/
void init_grafA()
{
	int bg1A, bg2A, bg3A;
	// Mode 3 Text / 3D Text | Text | Extended
	videoSetMode(MODE_3_2D | DISPLAY_SPR_1D_LAYOUT | DISPLAY_SPR_ACTIVE);
	
// Tarea 2Aa:
	// reservar banco F para sprites, a partir de 0x06400000
	vramSetBankF(VRAM_F_MAIN_SPRITE_0x06400000);

// Tareas 2Ba (patr�n ajetreado) y 2Ca:
	// reservar banco E para fondos 1 y 2, a partir de 0x06000000 
	vramSetBankE(VRAM_E_MAIN_BG); // VRAM_E_MAIN_BG = 0x06000000
	
	// Tarea 2Da:
	// reservar bancos A y B para fondo 3, a partir de 0x06020000

	vramSetBankA(VRAM_A_MAIN_BG_0x06020000);
	vramSetBankB(VRAM_B_MAIN_BG_0x06040000);

// Tarea 2Aa:
	// cargar las baldosas de la variable SpritesTiles[] a partir de la
	// direcci�n virtual de memoria gr�fica para sprites, y cargar los colores
	// de paleta asociados contenidos en la variable SpritesPal[]
	dmaCopy(SpritesTiles, SPRITE_GFX, sizeof(SpritesTiles));		// SPRITE_GFX
	dmaCopy(SpritesPal, SPRITE_PALETTE, sizeof(SpritesPal));		// SPRITE_PALETTE


// Tarea 2Ba:
	// inicializar el fondo 2 con prioridad 2 // MODE_3_2D BG1 -> Text BG2 -> Text
	bg2A = bgInit(2, BgType_Text8bpp, BgSize_T_256x256, 1, 1); // BgSize_T_256x256 = BG_32x32
	bgSetPriority(bg2A, 2); // Prioridad del fondo 2 a nivel 2
	

// Tarea 2Ca:
	//inicializar el fondo 1 con prioridad 0
	bg1A = bgInit(1, BgType_Text8bpp, BgSize_T_256x256, 0, 1); // BgSize_T_256x256 = BG_32x32
	bgSetPriority(bg1A, 0); // Prioridad del fondo 1 a nivel 0

// Tareas 2Ba y 2Ca:
	// descomprimir (y cargar) las baldosas de la variable BaldosasTiles[] a
	// partir de la direcci�n de memoria correspondiente a los gr�ficos de
	// las baldosas para los fondos 1 y 2, cargar los colores de paleta
	// correspondientes contenidos en la variable BaldosasPal[]
	decompress(BaldosasTiles, bgGetGfxPtr(bg1A), LZ77Vram); // Decomprimimos tiles en formato LZ77
	decompress(BaldosasTiles, bgGetGfxPtr(bg2A), LZ77Vram);
	dmaCopy(BaldosasPal, BG_PALETTE, sizeof(BaldosasPal));
	
	
// Tarea 2Da:
	// inicializar el fondo 3 con prioridad 3
	bg3A = bgInit(3, BgType_Bmp16, BgSize_B16_512x256, 8, 0);	// Map = 8*16*1024 = 0x2 0000
	bgSetPriority(bg3A, 3);

	// descomprimir (y cargar) la imagen de la variable FondoBitmap[] a partir
	// de la direcci�n virtual de v�deo reservada para dicha imagen

	decompress(FondoBitmap, bgGetGfxPtr(bg3A), LZ77Vram);
	ajusta_imagen3(3);


	// fijar display A en pantalla inferior (t�ctil)
	lcdMainOnBottom();

	/* transparencia fondos:
		//	bit 1 = 1 		-> 	BG1 1st target pixel
		//	bit 2 = 1 		-> 	BG2 1st target pixel
		//	bits 7..6 = 01	->	Alpha Blending
		//	bit 11 = 1		->	BG3 2nd target pixel
		//	bit 12 = 1		->	OBJ 2nd target pixel
	*/
	*((u16 *) 0x04000050) = 0x1846;	// 0001100001000110
	/* factor de "blending" (mezcla):
		//	bits  4..0 = 01001	-> EVA coefficient (1st target)
		//	bits 12..8 = 00111	-> EVB coefficient (2nd target)
	*/
	*((u16 *) 0x04000052) = 0x0709;
}

