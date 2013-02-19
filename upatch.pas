unit upatch;

interface

uses
  Windows, OpenGL;

const
  OPCODE_JMP: Word = $F9EB;  

type
  TJmpRec = packed record
    JmpOpcode: Byte;
    Offset: DWORD;
  end;

  TPatchData = packed record
    FuncAddr: FARPROC;
    JmpRec: TJmpRec;
    LockJmp: Word;
  end;

var
  PatchData: array of TPatchData;
  ID_glDrawElements: integer;
  ID_glTexImage2D: integer;

procedure InitPatches;

procedure PatchSetJmp( FuncAddr: Pointer; NewData: TJmpRec );
procedure PatchLockJmp( FuncAddr: Pointer; NewData: Word );

function InitPatch( aModule: PChar; aFunc: PChar; aHook: pointer ): integer;

implementation

uses uhooks;
                
procedure PatchSetJmp( FuncAddr: Pointer; NewData: TJmpRec );
var
  OldProtect: DWORD;
begin
  VirtualProtect( FuncAddr, SizeOf( TJmpRec ), PAGE_EXECUTE_READWRITE, OldProtect );
  try
    Move( NewData, FuncAddr^, SizeOf( TJmpRec ) );
  finally
    VirtualProtect( FuncAddr, SizeOf( TJmpRec ), OldProtect, OldProtect );
    FlushInstructionCache( GetCurrentProcess, FuncAddr, SizeOf( TJmpRec ) );
  end;
end;

procedure PatchLockJmp( FuncAddr: Pointer; NewData: Word );
var
  OldProtect: DWORD;
begin
  VirtualProtect( FuncAddr, 2, PAGE_EXECUTE_READWRITE, OldProtect );
  try
    asm
      mov  ax, NewData
      mov  ecx, FuncAddr
      lock xchg word ptr [ecx], ax
    end; 
  finally
    VirtualProtect( FuncAddr, 2, OldProtect, OldProtect );
    FlushInstructionCache( GetCurrentProcess, FuncAddr, 2 );
  end;
end;

function InitPatch( aModule: PChar; aFunc: PChar; aHook: pointer ): integer;
var
  i: integer;
begin
  i := Length( PatchData );
  Setlength( PatchData, i + 1 );

  ZeroMemory( @PatchData[ i ], SizeOf( TPatchData ) );

  PatchData[ i ].FuncAddr := GetProcAddress( GetModuleHandle( aModule ), aFunc );
  Move( PatchData[ i ].FuncAddr^, PatchData[ i ].LockJmp, 2 );
  
  PatchData[ i ].JmpRec.JmpOpcode := $E9;
  PatchData[ i ].JmpRec.Offset := PAnsiChar( aHook ) + 5 - PAnsiChar( PatchData[ i ].FuncAddr ) - SizeOf( TJmpRec );

  PatchSetJmp( PAnsiChar( PatchData[ i ].FuncAddr ) - 5, PatchData[ i ].JmpRec );
  patchLockJmp( PatchData[ i ].FuncAddr, OPCODE_JMP );

  Result := i;
end;

procedure InitPatches;
begin          
  ID_glDrawElements := InitPatch( openGL32, 'glDrawElements', @new_glDrawElements );
  ID_glTexImage2D := InitPatch( openGL32, 'glTexImage2D', @new_glTexImage2D );
end;

end.
