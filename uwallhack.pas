unit uwallhack;

interface
uses OpenGL, windows, classes;

const
  KEEL_TEX = 2;
  KEEL_HASH: array[ 0..KEEL_TEX-1 ] of integer = ( 22558390, 113339075 );

  PROJ_COUNT = 2;                                   // nade, plasma
  PROJ_HASH: array[ 0..PROJ_COUNT-1 ] of integer = ( 362265, 1497631 );

  WH_MODE_COUNT = 3;
  WH_OFF = -1;
  WH_MODES: array[ 0..WH_MODE_COUNT ] of integer = ( WH_OFF, GL_POINTS, GL_LINES, GL_TRIANGLES );

var
  KEEL_IDs: array[ 0..KEEL_TEX-1 ] of integer;
  PROJ_IDs: array[ 0..PROJ_COUNT-1 ] of integer;
  
  wh_Mode: integer = 0;
  wh_affectProj: boolean = true;  

procedure glDrawElements( mode: DWORD; count: integer; _type: DWORD; const indices: pointer ); stdcall; external opengl32;   
procedure new_glDrawElements( mode: DWORD; count: integer; _type: DWORD; const indices: pointer ); stdcall;      
procedure new_glTexImage2D(target: GLenum; level, c: GLint; w, h: GLsizei; b: GLint; f, t: GLenum; p: Pointer); stdcall;

implementation

uses uhooks, upatch, uhash, ugui, uopengl, uutils;


procedure new_glDrawElements( mode: DWORD; count: integer; _type: DWORD; const indices: pointer ); stdcall;
var
  i, id: integer;
  isEnemy, isProj: boolean;
begin
  PatchLockJmp( PatchData[ ID_glDrawElements ].FuncAddr, PatchData[ ID_glDrawElements ].LockJmp );
  try
    glDrawElements( mode, count, _type, indices );

    isEnemy := false;
    isProj := false;

    glGetIntegerv( $8069, @id );
    for i:=0 to KEEL_TEX-1 do
      if( id = KEEL_IDs[ i ] ) then
        isEnemy := true;

    for i:=0 to PROJ_COUNT-1 do
      if( id = PROJ_IDs[ i ] ) then
        isProj := true;

    // wallhack
    if ( wh_Mode <> WH_OFF ) then
      if ( ( isEnemy ) or ( isProj and wh_affectProj ) ) then begin
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
  fs: TFileStream;
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

      fs := TFileStream.Create( 'i:/tmp/'+IntToStr(Level)+'__'+IntToStr( w ) + 'x' + IntToStr( h )+'='+IntToStr(hash(p, bpp*w*h))+'.raw', fmCreate );
      fs.Write( p^, bpp * w * h );
      fs.Free;

      // is it font?
      if hash( p, w*h*bpp ) = GUI_FONT_HASH then
        guiFont := id;

      // is it keel texture?
      for i:=0 to KEEL_TEX-1 do
        if hash( p, w * h * bpp ) = KEEL_HASH[ i ] then begin
          KEEL_IDs[ i ] := id;
          break;
        end;

      // is it projectile?
      for i:=0 to PROJ_COUNT-1 do
        if hash( p, w * h * bpp ) = PROJ_HASH[ i ] then begin
          PROJ_IDs[ i ] := id;
          break;
        end;
    end;
  finally
    PatchLockJmp( PatchData[ ID_glTexImage2D ].FuncAddr, OPCODE_JMP );
  end;
end;

end.
