unit uhooks;

interface
uses OpenGL, Windows;


procedure glDrawElements( mode: DWORD; count: integer; _type: DWORD; const indices: pointer ); stdcall; external opengl32;

procedure new_glDrawElements( mode: DWORD; count: integer; _type: DWORD; const indices: pointer ); stdcall;

implementation

uses upatch;

procedure new_glDrawElements( mode: DWORD; count: integer; _type: DWORD; const indices: pointer ); stdcall;
begin
  PatchLockJmp( PatchData[ ID_glDrawElements ].FuncAddr, PatchData[ ID_glDrawElements ].LockJmp );
  try
    glDrawElements( mode, count, _type, indices );

    // The wallhack starts here
    glDisable( GL_DEPTH_TEST );
    glDrawElements( GL_POINTS, count, _type, indices );
    glEnable( GL_DEPTH_TEST );
    // ... lol
  finally
    PatchLockJmp( PatchData[ ID_glDrawElements ].FuncAddr, OPCODE_JMP );
  end;
end;

end.
