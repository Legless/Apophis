// Injection Routines
unit uinject;

interface

uses
  Windows, tlhelp32;

const
  DLL_NAME = 'apophis.dll';

function InjectLib( PID: Integer ): boolean;

implementation

uses uutils;

function InjectLib( PID: integer ): boolean;
var
  phandle: HWND;
  pthread: FARPROC;
  dllpath: AnsiString;
  remotedll: Pointer;
  bw: DWORD;
  t, tid: dword;
begin
  result := False;

  phandle := OpenProcess( PROCESS_CREATE_THREAD or PROCESS_VM_OPERATION or PROCESS_VM_WRITE, true, PID );
  dllpath := AnsiString( GetCurrentDir + '\' + DLL_NAME ) + #0;
  remotedll := VirtualAllocEx( phandle, nil, Length( dllpath ), MEM_COMMIT or MEM_TOP_DOWN, PAGE_READWRITE );
  WriteProcessMemory( phandle, remotedll, @DllPath[ 1 ], Length( dllpath ), bw );

  pthread := GetProcAddress( GetModuleHandle( kernel32 ), 'LoadLibraryA' );
  t := CreateRemoteThread( phandle, nil, 0, pthread, remotedll, 0, tid );

  Result := WaitForSingleObject( t, INFINITE ) = WAIT_OBJECT_0;
  
  CloseHandle( t );
  VirtualFreeEx( phandle, remotedll, 0, MEM_RELEASE );
  CloseHandle( phandle );
end;

end.
