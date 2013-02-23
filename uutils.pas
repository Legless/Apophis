unit uutils;

interface

uses windows;

function IntToStr( val: integer): string;
function StrToInt( const S: string ): integer;

function isActive( v: boolean ): string;

implementation


function IntToStr( val: Integer ): string;
begin
  Str( val, Result );
end;

function StrToInt( const S: string ): integer;
var
  er: integer;
begin
  Val( S, Result, er );
end;

function isActive( v: boolean ): string;
begin
  if v then Result := 'Enabled'
  else      Result := 'Disabled';
end;

end.
