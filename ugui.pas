unit ugui;

interface
uses windows, openGl;


function new_SwapBuffers(DC: HDC): BOOL; stdcall;

const
  GUI_FONT_HASH = 53933763;

var
  guiFont: cardinal = 0;
  drawGui: boolean = false;

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
    textOut( 8, 8, 'Apophis is active. ' );
    textOut( 8, 16, 'Press [ Del ] to draw status. ' );

    if drawGui then begin
      cfg.Draw;
    end;
       
    gui_finish;

    Result := SwapBuffers( DC );
  finally
    PatchLockJmp( PatchData[ ID_SwapBuffers ].FuncAddr, OPCODE_JMP );
  end;
end;

end.
