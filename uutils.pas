unit uutils;

interface

uses windows;

function IntToStr( val: integer): string;
function StrToInt( const S: string ): integer;
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

end.
