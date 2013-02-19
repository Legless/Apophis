program loader;

uses
  Windows,
  Messages,
  CommDlg,
  tlhelp32,
  uwnd in 'uwnd.pas',
  uinject in 'uinject.pas',
  uutils in 'uutils.pas';

begin
  CreateMainWindow;
  wnd_loop;
end.
