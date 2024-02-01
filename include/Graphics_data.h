/*------------------------------------------------------------------------------

	$Id: candy2_graf.h $

	Definiciones externas en C para los gráficos del juego (modo gráfico)

------------------------------------------------------------------------------*/



//{{BLOCK(Fondo)

//======================================================================
//
//	Fondo, 512x256@16, 
//	Alphabit on.
//	+ bitmap lz77 compressed
//	Total size: 142536 = 142536
//
//	Time-stamp: 2023-01-18, 22:14:59
//	Exported by Cearn's GBA Image Transmogrifier, v0.8.14
//	( http://www.coranac.com/projects/#grit )
//
//======================================================================

#ifndef GRIT_FONDO_H
#define GRIT_FONDO_H

#define FondoBitmapLen 142536
extern const unsigned short FondoBitmap[71268];

#endif // GRIT_FONDO_H

//}}BLOCK(Fondo)




//{{BLOCK(Baldosas)

//======================================================================
//
//	Baldosas, 256x96@8, 
//	Transparent palette entry: 52.
//	+ palette 82 entries, not compressed
//	+ 384 tiles Metatiled by 4x4 lz77 compressed
//	Total size: 164 + 8964 = 9128
//
//	Time-stamp: 2014-09-26, 15:14:57
//	Exported by Cearn's GBA Image Transmogrifier, v0.8.6
//	( http://www.coranac.com/projects/#grit )
//
//======================================================================

#ifndef GRIT_BALDOSAS_H
#define GRIT_BALDOSAS_H

#define BaldosasTilesLen 8964
extern const unsigned int BaldosasTiles[2241];

#define BaldosasPalLen 164
extern const unsigned int BaldosasPal[41];

#endif // GRIT_BALDOSAS_H

//}}BLOCK(Baldosas)



//{{BLOCK(Sprites)

//======================================================================
//
//	Sprites, 192x32@8, 
//	Transparent palette entry: 31.
//	+ palette 32 entries, not compressed
//	+ 96 tiles Metatiled by 4x4 not compressed
//	Total size: 64 + 6144 = 6208
//
//	Time-stamp: 2023-01-18, 21:09:08
//	Exported by Cearn's GBA Image Transmogrifier, v0.8.14
//	( http://www.coranac.com/projects/#grit )
//
//======================================================================

#ifndef GRIT_SPRITES_H
#define GRIT_SPRITES_H

#define SpritesTilesLen 6144
extern const unsigned int SpritesTiles[1536];

#define SpritesPalLen 64
extern const unsigned short SpritesPal[32];

#endif // GRIT_SPRITES_H

//}}BLOCK(Sprites)

