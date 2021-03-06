 library apophis;

uses
  Windows,
  upatch in 'upatch.pas',
  uhooks in 'uhooks.pas',
  uhash in 'uhash.pas',
  ugui in 'ugui.pas',
  uinput in 'uinput.pas',
  uopengl in 'uopengl.pas',
  uutils in 'uutils.pas',
  uconfig in 'uconfig.pas',
  uglobal in 'uglobal.pas';

procedure DLLEntryPoint(dwReason: DWORD);
begin
  case dwReason of
    DLL_PROCESS_ATTACH: begin
      InitPatches;  
    end;
  end;
end;

begin
  DLLProc := @DLLEntryPoint;
  DLLEntryPoint( DLL_PROCESS_ATTACH );
end.
