unit uutils;

interface
uses Windows;

function GetCurrentDir: string;
function AnsiUpperCase(const S: string): string;

implementation

function GetCurrentDir: string;
begin
  GetDir( 0, Result );
end;

function AnsiUpperCase(const S: string): string;
var
  Len: Integer;
begin
  Len := Length(S);
  SetString(Result, PChar(S), Len);
  if Len > 0 then CharUpperBuff(Pointer(Result), Len);
end;

end.
