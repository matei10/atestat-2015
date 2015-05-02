program algoritm_creeare_matrice_costuri;
var i, j, n, m, x, y :integer;
    v :array[1..1000, 1..1000] of real;
    f :text;
    s :string;

begin
write('Numarul de noduri :');
readln(n);

write('Numarul de arce :');
readln(m);

{ initializam matricea costurilor }
for i := 1 to n do
    for j := 1 to n do
        if i = j then 
            v[i, j] := 0
        else
            v[i, j] := -1;


{ citim muchiile }
for i := 1 to m do
    begin
    write('x= ');
    readln(x);

    write('y= ');
    readln(y);

    write('Costul arcului ', x, ' ', y,' :');
    readln(v[x, y]);
    end;

{ afisam matricea costurilor }

writeln;
writeln;
for i := 1 to n do
    begin
    for j := 1 to n do
        write(v[i, j]:4:2, ' ');
    writeln;
    end;
writeln;
writeln;
repeat
    write('Doriti sa salvam matricea costurilor intr-un fisier?(y/n) ');
    readln(s);
until (s = 'y') OR (s = 'n');

if s = 'y' then
    begin
    write('Numele fisierului in care doriti sa salvam : ');
    readln(s);

    assign(f, s);
    rewrite(f);

    writeln(f, n);

    for i := 1 to n do
        begin
        for j := 1 to n do
            write(f, v[i, j]:4:2, ' ');
        writeln(f);
        end;

    close(f);
    end;

end.
