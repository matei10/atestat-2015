program algoritmul_roy_floyd_minim;
uses crt;
const p_infinit = 1.e10;
      m_infinit = -1.e10;
      n_max = 100;
type 
    vector=array[1..n_max] of integer;
    drum = record { va retine un drum }
        v :vector; { nodurile drumului }
        n :integer; { cate noduri are drumul }
        end;

var drumuri :array[1..n_max, 1..n_max] of drum; { matricea care va retine drumul de la un element la latul }
    costuri :array[1..n_max, 1..n_max] of real; { matricea costurilor }
    i, j, n :integer;
    f :text;

procedure citire_mat_costuri;
{ citim matricea de costuri, de unde aflam si ce muchii exista in graf 
  citirea se face dintr-un fisier 'costuri.txt' care are pe prima linie 
  numarul de noduri apoi pe fiecare linie urmatoare o linie din matricea costurilpr }
var i, j :integer;
begin
assign(f, 'costuri.txt');
reset(f);

readln(f, n);

for i := 1 to n do
    begin
    for j := 1 to n do
        begin
        read(f, costuri[i, j]);
        if costuri[i, j] = -1 then
            costuri[i, j] := p_infinit;
        end;
    writeln;
    end;
close(f);
end;

procedure init_drum(var x :drum);
{ initializam un drum }
begin
x.n := 0;
end;

procedure init_mat_drumuri;
{ initializam matricea de drumuri, pentru arcele existente }
begin
for i := 1 to n do
    for j := 1 to n do
        begin
        if (i <> j) AND (costuri[i, j] < p_infinit) then
            begin
            drumuri[i, j].n := 2;
            drumuri[i, j].v[1] := i;
            drumuri[i, j].v[2] := j;
            end
        else
            init_drum(drumuri[i, j]);
        end;
end;


function concat_drum(x, y :drum):drum;
{ alipim doua drumuri, nodul din mijloc se scrie o singura data }
var i :integer;
    aux :drum;
begin
init_drum(aux); { initializam drumul }
if (x.v[x.n] = y.v[1]) AND (x.n > 0) AND (y.n > 0) then { daca exista macar un nod in ambele drumuri }
    begin
    for i := 1 to x.n do
        begin
        aux.n := aux.n + 1;
        aux.v[aux.n] := x.v[i];
        end;
    for i := 2 to y.n do
        begin
        aux.n := aux.n + 1;
        aux.v[aux.n] := y.v[i];
        end;
    end;

concat_drum := aux;
end;


procedure afis;
{ afisam drumurile si costurie }
var i, j, k :integer;
    aux :drum;
begin
for i := 1 to n do
    for j := 1 to n do
        if i <> j then { un drum de la un nod la el insusi nu are sens }
            if (costuri[i, j] < p_infinit) then { daca exista drum de la i -> j }
                begin
                { afisam costul si drumul cel mai scurt }
                writeln('Intre nodul ', i, ' ,', j, ' are costul ', costuri[i, j]:4:2);
                writeln('Drumul este :');
                aux := drumuri[i, j];
                write(' ':5);
                for k := 1 to aux.n do
                    write(aux.v[k], ' ');
                writeln;
                end
            else
                writeln('Intre nodul ', i, ', ', j, ' nu exista drum !');
end;

procedure roy_floyd;
{ algoritmul principal }
var i, j, k :integer;
begin
for k := 1 to n do { verificam pentru fiecare nod in graf }
    for i := 1 to n do { pentru fiecare nod in graf }
        for j := 1 to n do { pentru pereche de noduri i, j }
            if (k <> i) AND ( k <> j) then { daca nodul k este diferit de nodurile i si j }
                if ( costuri[i, j] > costuri[i, k] + costuri[k, j]) then { si daca drumul i - k - j este mai scurt decat drumul i - j }
                    begin
                    costuri[i, j] := costuri[i, k] + costuri[k, j]; { modifica costul cu noul cost, mai mic }
                    drumuri[i, j] := concat_drum(drumuri[i, k], drumuri[k, j]); { alipeste drumurile i - k si k - j si salveazale in locul drumului i - j }
                    end;
end;

begin
citire_mat_costuri; { citim costurile }
init_mat_drumuri; { initializam drumurile }

clrscr; { curatam ecranul }

roy_floyd;

afis; { afisam rezultatul }

readln;
end.







