unit uinput;

interface
uses windows, messages;

function new_DefWindowProc(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

implementation

uses uwallhack, upatch, ugui;


function new_DefWindowProc(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  PatchLockJmp( PatchData[ ID_DefWindowProc ].FuncAddr, PatchData[ ID_DefWindowProc ].LockJmp );
  try
    if( Msg = WM_KEYDOWN ) then
      case wParam of
        VK_INSERT: begin // cycle through wallhack modes
          inc( wh_Mode );
          if( wh_Mode > WH_MODE_COUNT ) then wh_Mode := 0;
        end;

        VK_DELETE: drawGui := not drawGui;
      end;

    Result := DefWindowProc( hWnd, Msg, wParam, lParam );
  finally                                                            
    PatchLockJmp( PatchData[ ID_DefWindowProc ].FuncAddr, OPCODE_JMP );
  end;  
end;

end.
