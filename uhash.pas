unit uhash;

interface
uses Windows;

function hash(p: pointer; size: integer): integer;

implementation

function hash(p: pointer; size: integer): integer;
var
  i: integer;
  n: ^byte; 
begin
  Result := 0;

  try
    n := p;
    for i:=0 to size-1 do begin
      Result := Result + n^;
      inc( n );
    end;

  except { :-( } end;
end;

end.
