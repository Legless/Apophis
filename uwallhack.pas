unit uwallhack;

interface
uses OpenGL, windows;

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

var
  KEEL_IDs: array[ 0..KEEL_TEX-1 ] of integer;
  
  wh_Mode: integer = 0;
  wh_affectProj: boolean = false;
  wh_enemyColor: integer = 0;

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
    isEnemy := false;

    glGetIntegerv( $8069, @id );
    for i:=0 to KEEL_TEX-1 do
      if( id = KEEL_IDs[ i ] ) then
        isEnemy := true;

    // Since wh uses stencil buffer, be sure to have
    // set /r_stencilbits 8 in your ql config
    glEnable( GL_STENCIL_TEST );
    
    // wallhack
    if ( wh_Mode <> WH_OFF ) then
      if ( isEnemy ) then begin
        glDisable( GL_DEPTH_TEST );
        glStencilFunc( GL_NEVER, 1, 255 );
        glStencilOp( GL_REPLACE, GL_KEEP, GL_KEEP );

        glDrawElements( WH_MODES[ wh_Mode ], count, _type, indices );

        glEnable( GL_DEPTH_TEST );
      end;

 		glStencilFunc( GL_ALWAYS, 0, 255 );
    glStencilOp( GL_KEEP, GL_KEEP, GL_REPLACE );
    glDrawElements( mode, count, _type, indices );

    glDisable( GL_STENCIL_TEST );
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

    // do not serch in empty textures and mipmaps
    if( p <> nil )  and ( level = 0 ) then begin
      if( f = GL_RGB  ) then bpp := 3
      else if( f = GL_RGBA ) then bpp := 4
      else bpp := 0;
      
      // is it font?
      if hash( p, w*h*bpp ) = GUI_FONT_HASH then
        guiFont := id;

      // is it keel texture?
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
