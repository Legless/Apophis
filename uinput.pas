unit uinput;

interface
uses windows, messages;

function new_DefWindowProc(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

implementation

uses uwallhack, upatch, ugui, uconfig;
                 
function new_DefWindowProc(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  PatchLockJmp( PatchData[ ID_DefWindowProc ].FuncAddr, PatchData[ ID_DefWindowProc ].LockJmp );
  try
    if( Msg = WM_KEYDOWN ) then
      case wParam of
        VK_DELETE: drawGui := not drawGui;
        VK_NEXT:   if drawGui then cfg.Next;
        VK_PRIOR:  if drawGui then cfg.Prev;
        VK_INSERT: if drawGui then cfg.Toggle;
      end;

    Result := DefWindowProc( hWnd, Msg, wParam, lParam );
  finally                                                            
    PatchLockJmp( PatchData[ ID_DefWindowProc ].FuncAddr, OPCODE_JMP );
  end;  
end;

end.
