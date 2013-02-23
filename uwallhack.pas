unit uwallhack;

interface
uses OpenGL, windows;

const
  KEEL_TEX = 2;
  KEEL_HASH: array[ 0..KEEL_TEX-1 ] of integer = ( 22558390, 113339075 );

  WH_MODE_COUNT = 3;
  WH_OFF = -1;
  WH_MODES: array[ 0..WH_MODE_COUNT ] of integer = ( WH_OFF, GL_POINTS, GL_LINES, GL_TRIANGLES );

var
  KEEL_IDs: array[ 0..KEEL_TEX-1 ] of integer;
  wh_Mode: integer;
  

procedure glDrawElements( mode: DWORD; count: integer; _type: DWORD; const indices: pointer ); stdcall; external opengl32;   
procedure new_glDrawElements( mode: DWORD; count: integer; _type: DWORD; const indices: pointer ); stdcall;      
procedure new_glTexImage2D(target: GLenum; level, c: GLint; w, h: GLsizei; b: GLint; f, t: GLenum; p: Pointer); stdcall;

implementation

uses uhooks, upatch, uhash, ugui, uopengl, uutils;


procedure new_glDrawElements( mode: DWORD; count: integer; _type: DWORD; const indices: pointer ); stdcall;
var
  i, id: integer;
  isEnemy: boolean;
begin
  PatchLockJmp( PatchData[ ID_glDrawElements ].FuncAddr, PatchData[ ID_glDrawElements ].LockJmp );
  try
    glDrawElements( mode, count, _type, indices );

    isEnemy := false;

    glGetIntegerv( $8069, @id );
    for i:=0 to KEEL_TEX-1 do
      if( id = KEEL_IDs[ i ] ) then
        isEnemy := true;

    // wallhack
    if ( isEnemy ) and ( wh_Mode <> WH_OFF ) then begin
      glDisable( GL_DEPTH_TEST );
      glDrawElements( WH_MODES[ wh_Mode ], count, _type, indices );
      glEnable( GL_DEPTH_TEST );
    end;
  finally                                                            
    PatchLockJmp( PatchData[ ID_glDrawElements ].FuncAddr, OPCODE_JMP );
  end;
end;

procedure new_glTexImage2D(target: GLenum; level, c: GLint; w, h: GLsizei; b: GLint; f, t: GLenum; p: Pointer); stdcall;
var
  bpp, i, id: integer;
begin
  PatchLockJmp( PatchData[ ID_glTexImage2D ].FuncAddr, PatchData[ ID_glTexImage2D ].LockJmp );
  try
    glTexImage2D( target, level, c, w, h, b, f, t, p );  
    glGetIntegerv( $8069, @id );

    if p <> nil then begin
      if( f = GL_RGB  ) then bpp := 3
      else if( f = GL_RGBA ) then bpp := 4
      else bpp := 0;
      
      if hash( p, w*h*bpp ) = GUI_FONT_HASH then
        guiFont := id;

      for i:=0 to KEEL_TEX-1 do
        if hash( p, w * h * bpp ) = KEEL_HASH[ i ] then begin
          KEEL_IDs[ i ] := id;
          break;
        end;
    end;
  finally
    PatchLockJmp( PatchData[ ID_glTexImage2D ].FuncAddr, OPCODE_JMP );
  end;
end;

end.
