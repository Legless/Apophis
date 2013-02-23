unit ugui;

interface
uses windows, openGl;


function new_SwapBuffers(DC: HDC): BOOL; stdcall;

const
  GUI_FONT_HASH = 53933763;

var
  guiFont: cardinal = 0;
  drawGui: boolean = false;

procedure gui_start;
procedure gui_finish;

implementation

uses upatch, uinput, uopengl, uwallhack, ustrings, uutils, uconfig;

procedure gui_start;
begin
  glPushMatrix;

  glMatrixMode( GL_PROJECTION );
  glLoadIdentity( );
  glOrtho( 0, 640, 480, 0, 0, 1 );
end;

procedure gui_finish;
begin
  glPopMatrix;
end;

function new_SwapBuffers(DC: HDC): BOOL; stdcall;
begin
  PatchLockJmp( PatchData[ ID_SwapBuffers ].FuncAddr, PatchData[ ID_SwapBuffers ].LockJmp );
  try
    gui_start;

    // Draw wallhack
    glEnable( GL_STENCIL_TEST );      
    glStencilFunc( GL_EQUAL, 1, 255 );

    glColor3f( WH_COLORS[ wh_enemyColor ][ 0 ], WH_COLORS[ wh_enemyColor ][ 1 ], WH_COLORS[ wh_enemyColor ][ 2 ] );

    glBEgin( GL_QUADS );
      glvertex2f( 0, 0 );
      glvertex2f( 640, 0 );
      glvertex2f( 640, 480 );
      glvertex2f( 0, 480 );
    glEnd;

    glDisable( GL_STENCIL_TEST );

    // draw gui
    textOut( 8, 8, 'Apophis is active. ' );
    textOut( 8, 16, 'Press [ Del ] to draw status. ' );

    if drawGui then begin
      cfg.Draw;
    end;

    gui_finish;

    Result := SwapBuffers( DC );
    
    glClearStencil( 0 );
    glClear( GL_STENCIL_BUFFER_BIT );
  finally
    PatchLockJmp( PatchData[ ID_SwapBuffers ].FuncAddr, OPCODE_JMP );
  end;
end;

end.
