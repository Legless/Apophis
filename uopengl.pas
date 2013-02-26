unit uopengl;

interface
uses windows, opengl;

procedure textOut( X, Y: integer; theText: string );

// ---
procedure glGenTextures(n: GLsizei; textures: PGLuint); stdcall; external opengl32;
procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;
procedure glDeleteTextures(N: GLsizei; Textures: PGLuint); stdcall; external opengl32;

const
  GL_CLAMP_TO_EDGE = $812F; 
  GL_RGB8          = $8051;
  GL_BGR           = $80E0;  
  GL_TEXTURE_BASE_LEVEL = $813C;

implementation

uses ugui, uglobal;

procedure textOut( X, Y: integer; theText: string );
var
  i: integer;
  tx, ty: single;
  c: byte;
begin
  glEnable( GL_TEXTURE_2D );
  glBindTexture( GL_TEXTURE_2D, guiFont );
  glColor3f( 1, 1, 1 );
  
  glBegin( GL_QUADS );
  for i:=1 to Length( theText ) do begin
    c := ord( theText[ i ] ); 

    tx := ( ( c mod 16 ) / 16 );
    ty := ( ( c div 16 ) / 16 );

    glTexCoord2f( tx       , ty        ); glVertex2f( X    , Y );
    glTexCoord2f( tx       , ty + 1/16 ); glVertex2f( X    , Y + 8 );
    glTexCoord2f( tx + 1/16, ty + 1/16 ); glVertex2f( X + 8, Y + 8 );
    glTexCoord2f( tx + 1/16, ty        ); glVertex2f( X + 8, Y );

    X := X + 8;
  end;
  glEnd;
end;

end.
