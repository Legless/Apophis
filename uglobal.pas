unit uglobal;

interface
uses openGL;

const
  KEEL_TEX = 2;
  KEEL_HASH: array[ 0..KEEL_TEX-1 ] of integer = ( 22558390, 113339075 );

  WH_MODE_COUNT = 3;
  WH_OFF = -1;
  WH_MODES: array[ 0..WH_MODE_COUNT ] of integer = ( WH_OFF, GL_POINTS, GL_LINE_LOOP, GL_TRIANGLES );

  WH_COLORS_COUNT = 4;
  WH_COLORS: array[ 0..WH_COLORS_COUNT-1 ] of array [ 0..2 ] of single = (
    ( 1, 1, 1 ), ( 1, 0, 0 ), ( 0, 1, 0 ), ( 0, 0, 1 )
  );

  GUI_FONT_HASH = 53933763;

  BLUR_TEX_COUNT = 11;
  BLUR_TEX_HASH: array[ 0..BLUR_TEX_COUNT-1 ] of integer = (
    1151379, 1237920, 1300936, 1595431, 1512662, 1798808, 1820256, 1871981, 1875423, 1648951, 1978346 
  );
  
var
  WH_MODE_NAMES: array[ 0..WH_MODE_COUNT ] of string = ( 'OFF', 'POINTS', 'LINES', 'MODEL' );
  WH_COLOR_NAMES: array[ 0..WH_COLORS_COUNT-1 ] of string = ( 'White', 'Red', 'Green', 'Blue' );

  KEEL_IDs: array[ 0..KEEL_TEX-1 ] of integer;
  
  wh_Mode: integer = 0;
  wh_affectProj: boolean = false;
  wh_enemyColor: integer = 0;

  ch_blurExpl: boolean = true;

  guiFont: cardinal = 0;
  drawGui: boolean = false;

implementation

end.
