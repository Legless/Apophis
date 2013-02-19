unit uhooks;

interface
uses OpenGL, Windows, classes, sysUtils;


procedure glDrawElements( mode: DWORD; count: integer; _type: DWORD; const indices: pointer ); stdcall; external opengl32;

procedure new_glDrawElements( mode: DWORD; count: integer; _type: DWORD; const indices: pointer ); stdcall;
procedure new_glTexImage2D (target: GLenum; level, c: GLint; w, h: GLsizei; b: GLint; f, t: GLenum; p: Pointer); stdcall;

implementation

uses upatch, uhash, uwallhack;

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
    if( isEnemy ) then begin
      glDisable( GL_DEPTH_TEST );
      glDrawElements( GL_LINES, count, _type, indices );
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

    if p <> nil then begin
      if( f = GL_RGB  ) then bpp := 3
      else if( f = GL_RGBA ) then bpp := 4
      else bpp := 0;

      glGetIntegerv( $8069, @id );

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
