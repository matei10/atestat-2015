program functii_grad_interior_exterior_izolat;
var a :array[1..100, 1..100] of 0..1;
    i, j, n, m, x, y :byte;

function gr_ext(i :byte):byte;
{ subprogramu returneaza gradul exterior al nodului <i> }
var j, s :byte;
begin
s := 0;

for j := 1 to n do
    s := s + a[i, j];

gr_ext := s;
end;

function gr_int(i :byte):byte;
{ subprogramu returneaza gradul interior al nodului <i> }
var j, s :byte;
begin
s := 0;

for j := 1 to n do
    s := s + a[j, i];

gr_int:= s;
end;


function vf_izolat(i :byte):boolean;
{ subprogramu returneaza TRUE daca nodul <i> este izolat si 
  FALSE in caz contrar }
begin
vf_izolat := (gr_ext(i) = 0) AND (gr_int(i) = 0);
end;

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
