unit uwnd;

interface

uses
  Windows,
  Messages,
  CommDlg,
  tlhelp32;

type
  TFileName = type string;
  
  TSearchRec = record
    Time: Integer;
    Size: Integer;
    Attr: Integer;
    Name: TFileName;
    ExcludeAttr: Integer;
    FindHandle: THandle;
    FindData: TWin32FindData;
  end;

const
  WND_CLASS = 'apophisloader_wnd';
  WND_TITLE = 'Apophis Loader';
  WND_STYLE = WS_CAPTION or WS_VISIBLE;

var
  HMain: HWND;
  HList: HWND;
  HBtnList: HWND;
  HBtnInject: HWND;
  HBtnClose: HWND;

  PID_List: array of integer;

procedure wnd_loop;
function CreateMainWindow: Boolean;
procedure ListProcess;

implementation

uses uinject;

procedure ListProcess;
var
  p: PROCESSENTRY32;
  ct, th: cardinal;
begin
  SetLength( PID_List, 0 ); 
  SendMessage( HList, LB_RESETCONTENT, 0, 0 );

  ct := CreateToolhelp32Snapshot( TH32CS_SNAPALL, 0 );
  Process32First( ct, p );
  while Process32Next( ct, p ) do begin
    OpenProcessToken( p.th32ProcessID, TOKEN_READ, th );
    
    SendMessage( HList, LB_ADDSTRING, 0, Integer( PChar( string( p.szExeFile ) ) ) );
    SetLength( PID_List, Length( PID_List ) + 1 );
    PID_List[ Length( PID_List ) - 1 ] := p.th32ProcessID;
  end;
end;

procedure DoInjection;
var
  i, PID: integer;
begin
  i := SendMessage( HList, LB_GETCURSEL, 0, 0 );
  if i = -1 then Exit;
  PID := PID_List[ i ];

  if( InjectLib( PID ) ) then
    MessageBox( 0, 'Injection went OK'#13#10'Now you can close the loader.', 'Injected', MB_OK + MB_ICONINFORMATION )
  else
    MessageBox( 0, 'Injection failed. :-(', 'Error', MB_OK + MB_ICONERROR );
end;

function WndProc( hwnd, msg: DWORD; wParam, lParam: Integer ): Integer; stdcall;
begin
  Result := 0;
  case msg of
    WM_CREATE: begin
        HMain := hwnd;
        HList := CreateWindow( 'LISTBOX', '',
                                  WS_VISIBLE or WS_CHILD or WS_DLGFRAME or WS_VSCROLL,
                                  0, 0, 220, 453, HMain, 0, 0, nil );

        HBtnList  := CreateWindow( 'BUTTON', 'List Process',
                                  WS_VISIBLE or WS_CHILD,
                                  220, 0, 114, 30, HMain, 1, 0, nil );

        HBtnInject  := CreateWindow( 'BUTTON', 'Inject',
                                  WS_VISIBLE or WS_CHILD,
                                  220, 30, 114, 30, HMain, 2, 0, nil );

        HBtnClose  := CreateWindow( 'BUTTON', 'Close App',
                                  WS_VISIBLE or WS_CHILD,
                                  220, 60, 114, 30, HMain, 3, 0, nil );

        ListProcess;
      end;

    WM_COMMAND: if HIWORD(wParam) = BN_CLICKED then
      case LoWord( wParam ) of
        3: SendMessage( HMain, WM_DESTROY, 0, 0 );
        2: DoInjection;
        1: ListProcess;
      end;

    WM_DESTROY: begin
      PostQuitMessage( 0 );
      Exit;
    end;
  end;

  Result := DefWindowProc( hwnd, msg, wParam, lParam );
end;

function CreateMainWindow: Boolean;
var
  wc: TWndClass;
begin
  ZeroMemory( @wc, SizeOf( wc ) );
  with wc do begin
    style         := CS_HREDRAW or CS_VREDRAW or CS_OWNDC;
    lpfnWndProc   := @WndProc;
    hCursor       := LoadCursor(0, IDC_ARROW);
    hbrBackground := 1;
    lpszClassName := WND_CLASS;
  end;

  Result := ( RegisterClass( wc ) <> 0 ) and
            ( CreateWindowEx( 0, WND_CLASS, WND_TITLE, WND_STYLE,
                            160, 120, 340, 480, 0, 0, 0, nil ) <> 0 );
end;

procedure wnd_loop;
var
  msg: TMsg;
begin
  while GetMessage(msg, 0, 0, 0) do begin
    TranslateMessage(msg);
    DispatchMessage(msg);
  end
end;

end.
