unit ugui;

interface
uses windows, openGl;

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

end.
