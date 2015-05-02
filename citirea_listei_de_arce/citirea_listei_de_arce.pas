program citirea_listei_de_arce;
var a :array[1..100, 1..100] of 0..1;
    i, j, n, m, x, y :byte;

begin
write('n=');
readln(n); { numarul de noduri }

write('m=');
readln(m); { numarul de muchii }

{ initlializam matriea cu 0 }
fillchar(a, sizeof(a), 0);

for i := 1 to m do
    begin
    write('x=');
    readln(x); { extremitatea initiala a arcului (x, y) }

    write('y=');
    readln(y); { extremitatea finala a arcului (x, y) }

    a[x, y] := 1;
    end;

{ afisam matricea de adiacenta }
for i := 1 to n do
    begin
    for j := 1 to n do
        write(a[i, j], ' ');
    writeln;
    end;
writeln;
end.
