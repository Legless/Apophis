unit uhooks;

interface
uses OpenGL, Windows;
             
procedure glDrawElements( mode: DWORD; count: integer; _type: DWORD; const indices: pointer ); stdcall; external opengl32;   
procedure new_glDrawElements( mode: DWORD; count: integer; _type: DWORD; const indices: pointer ); stdcall;      
procedure new_glTexImage2D(target: GLenum; level, c: GLint; w, h: GLsizei; b: GLint; f, t: GLenum; p: Pointer); stdcall;

function new_SwapBuffers(DC: HDC): BOOL; stdcall;

implementation

uses upatch, uhash, ugui, uopengl, uutils, uwallhack, ustrings, uconfig,
  uglobal;

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
  thash: integer;
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

      // lol optimization
      thash := hash( p, w * h * bpp );

      // is it font?
      if thash = GUI_FONT_HASH then
        guiFont := id;

      // is it keel texture?
      for i:=0 to KEEL_TEX-1 do
        if thash = KEEL_HASH[ i ] then begin
          KEEL_IDs[ i ] := id;
          break;
        end;

      // need to be blured?
      if ch_blurExpl then
        for i:=0 to BLUR_TEX_COUNT-1 do
          if thash = BLUR_TEX_HASH[ i ] then begin
            glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_BASE_LEVEL, 6 );
            break;
          end;
    end;
  finally
    PatchLockJmp( PatchData[ ID_glTexImage2D ].FuncAddr, OPCODE_JMP );
  end;
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
