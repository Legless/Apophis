unit uconfig;

interface
uses windows, opengl;

type
  TCfgVarType = ( vtBool, vtInt );
  TCfgVarValues = array of string;
     
  TCfgVar = record
    Name: string[ 40 ];
    p, values: Pointer;
    varType: TCfgVarType;
    max: integer;
  end;

  TConfig = class
  private
    FVars: array of TCfgVar;
    FCur: integer;
  public
    property Current: integer read FCur write FCur;

    constructor Create;

    procedure Next;
    procedure Prev;
    procedure Toggle;

    procedure AddVar( vName: string; theVar: pointer; varType: TCfgVarType; varValues: pointer = nil; varMax: integer = 0 );

    procedure Draw;
  end;

var
  cfg: TConfig;

implementation

uses uutils, ustrings, uopengl, uwallhack, uglobal;
        
constructor TConfig.Create;
begin
  Self.AddVar( 'Wallhack',        @wh_Mode      , vtInt, @WH_MODE_NAMES , WH_MODE_COUNT       );
  Self.AddVar( 'WH Color',        @wh_EnemyColor, vtInt, @WH_COLOR_NAMES, WH_COLORS_COUNT - 1 );
  Self.AddVar( 'Blur explosions', @ch_blurExpl  , vtBool );
end;

procedure TConfig.Next;
begin
  inc( FCur );
  if( FCur >= Length( FVars ) ) then
    FCur := 0;
end;
           
procedure TConfig.Prev;
begin
  dec( FCur );
  if( FCur < 0 ) then
    FCur := Length( FVars ) - 1;  
end;

procedure TConfig.Toggle;
begin
  // should never be happen, but...
  if ( FCur = -1 ) or ( FCur >= Length( FVars ) ) then Exit;

  case FVars[ FCur ].varType of
    vtBool: boolean( FVars[ FCur ].p^ ) := not boolean( FVars[ FCur ].p^ );
    vtInt: begin
      inc( integer( FVars[ FCur ].p^ ) );
      if( integer( FVars[ FCur ].p^ ) > FVars[ FCur ].max ) then
        integer( FVars[ FCur ].p^ ) := 0;
    end;
  end;
end; 

procedure TConfig.AddVar( vName: string; theVar: pointer; varType: TCfgVarType; varValues: pointer = nil;  varMax: integer = 0 );
var
  i: integer;
begin
  i := Length( FVars );
  SetLength( FVars, i + 1 );

  FVars[ i ].Name := vName;
  FVars[ i ].p := theVar;
  FVars[ i ].values := varValues;
  FVars[ i ].varType := varType;
  FVars[ i ].max := varMax;  
end;

procedure TConfig.Draw;
var
  i: integer;
  s: string;
  vals: TCfgVarValues;
begin
  vals := nil;

  // print help
  textOut( 10, 80, 'Use PgUp and PgDn for select' );
  textOut( 10, 90, 'and Ins to toggle feature' );

  // disable texture (font)
  glDisable( GL_TEXTURE_2D );  

  // draw wnd
  glColor4f( 0, 0.2, 0, 0.5 );
  glBegin( GL_QUADS );
    glVertex2f( 10 , 100 );
    glVertex2f( 250, 100 );
    glVertex2f( 250, 100 + Length( FVars ) * 10 );
    glVertex2f( 10 , 100 + Length( FVars ) * 10 );
  glEnd;
                                                 
  // enable font
  glEnable( GL_TEXTURE_2D );

  // draw variables

  for i:=0 to Length( FVars )-1 do begin
    s := FVars[ i ].Name + ': ';

    if( FVars[ i ].varType = vtInt ) then
      if FVars[ i ].values <> nil then begin
        vals := FVars[ i ].values;
        s := s + vals[ integer( FVars[ i ].p^ ) ];
      end else begin
        s := s + IntToStr( integer( FVars[ i ].p^ ) );
      end;

    if( FVars[ i ].varType = vtBool ) then
      s := s + isActive( boolean( FVars[ i ].p^ ) );

    if( i = FCur ) then s := '> ' + s
    else                s := '  ' + s;
    
    textOut( 10, 100 + i * 10, s );
  end;
end;

initialization
  cfg := TConfig.Create;

finalization
  cfg.Free;

end.
