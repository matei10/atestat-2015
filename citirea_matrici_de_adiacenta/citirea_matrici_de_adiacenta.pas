program citirea_matrici_de_adiacenta;
var a :array[1..100, 1..100] of 0..1;
    i, j, n :byte;

begin
write('n=');
readln(n); { numarul de noduri }

{ initlializam matriea cu 0 }
fillchar(a, sizeof(a), 0);

for i := 1 to n do
    for j := 1  to n do
        begin
        { citim valoarea (0 sau 1) a fiecarui element din matricea de adiacenta }
        write('a[', i, ', ', j, ']=');
        readln(a[i, j]);
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
