library apophis;

uses
  Windows,
  upatch in 'upatch.pas',
  uhooks in 'uhooks.pas',
  uhash in 'uhash.pas',
  uwallhack in 'uwallhack.pas';

procedure DLLEntryPoint(dwReason: DWORD);
begin
  case dwReason of
    DLL_PROCESS_ATTACH: InitPatches;
  end;
end;

begin
  DLLProc := @DLLEntryPoint;
  DLLEntryPoint( DLL_PROCESS_ATTACH );
end.
