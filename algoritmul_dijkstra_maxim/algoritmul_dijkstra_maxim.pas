program algoritmul_dijkstra_minim;
uses crt;

const p_infinit = 1.e10;
      m_infinit = -1.e10;
      max_noduri = 1000;

type matrice=array[1..max_noduri, 1..max_noduri] of real;
     vector_i=array[1..max_noduri] of integer;
     vector=array[1..max_noduri] of real;

var c, c2 :matrice; { matricea costurilor }
    costuri_drum : vector; { costul drumului de la nodu de pornire la <i> }
    drum : vector_i; { drumul de la nodu de pornire la oricare nod }
    vizitate :array[1..max_noduri] of boolean; { tinem cont de ce noduri am vizitat }
    n, pornire :integer;
    f :text;

procedure citire_matrice_costuri;
var i, j :integer;
begin
assign(f, 'costuri.txt');
reset(f);

readln(f, n);

for i := 1 to n do
    begin
    for j := 1 to n do
        begin
        read(f, c[i, j]);
        if c[i, j] = -1 then { intifint in text e codificat ca si <-1> }
            c[i, j] := p_infinit;
        end;
    readln(f);
    end;
close(f);
end;

procedure init_vizitate;
{ initializam vectorul cu noduri vizitate }
var i :integer;
begin
for i := 1 to n do
    vizitate[i] := False;
end;

procedure vizitat(x :integer);
{ notam nodul <x> ca fiind vizitat }
begin
vizitate[x] := True;
end;

function exista_neviz:boolean;
{ returnam True daca mai exista noduri nevizitate }
var i :integer;
    aux :boolean;
begin
aux := false; { presupunem ca nu mai exista noduri de vizitat }
for i := 1 to n do
    if vizitate[i] = False then { daca nodul <i> nu a fost vizitat }
        begin
        aux := true; { atunci mai exista noduri de vizitat }
        break; { oprin cautarea }
        end;
exista_neviz := aux;
end;

function este_neviz(x :integer):boolean; 
{ returnam True daca nodul <x> este nevizitat, false in faz contrar }
begin
este_neviz := not vizitate[x];
end;


procedure init_drum_costuri;
{ initlializam costurile fiecarui drum }
var i : integer;
begin
for i := 1 to n do
    if (i <> pornire)  then { daca i nu este nodul de pornire }
        costuri_drum[i] := c[pornire, i] { drumul e constituit doar dintr-un arc si costul este cher costul arcului }
    else
        costuri_drum[i] := 0; { nu exista arc, deci initializam cu 0 }

end;

procedure init_drum;
{ initlializam vectorul drumurilor de la nodu de pornire la restu }
var i :integer;
begin
for i := 1 to n do
    if (i <> pornire) AND (c[pornire, i] < p_infinit) then { daca exista arc de la nodu de pornire la i }
        drum[i] := pornire { fiind doar un arc, extremitatea initiala e chear nodul de pornire }
    else
        drum[i] := 0 ; 
end;

procedure dijkstra;
var i, k, c1 :integer;
    min :real;
begin
c1 := 0;
while exista_neviz() and (c1 < n) do { cat mai exista noduri nevizitate }
(* for j := 1 to n-2 do *)
    begin
    c1 := c1 + 1;
    min := p_infinit;
    k := 0;

    for i := 1 to n do  { cautam nodul la care putem ajunge cel mai usor }
        if este_neviz(i) AND (costuri_drum[i] < min )then 
            begin
            min := costuri_drum[i];
            k := i;
            end;

    vizitat(k);

    for i := 1 to n do
        if este_neviz(i) AND (c[k, i] <> p_infinit) then { daca exista arc  de la k la i }

            if (costuri_drum[i] > costuri_drum[k] + c[k, i]) OR (costuri_drum[i] = p_infinit) then { daca drumul de la nodu pe care il avem de la nodu de
                                                                  pornire pana la <i> este mai lung decat drumul prin nodul
                                                                  <k> atunci drumul minim trece prin k }
                begin
                costuri_drum[i] :=  costuri_drum[k] + c[k, i]; { costul minim e cel al drumului pana la <k> + de la <k> la <i>}
                drum[i] := k; { la nodul <i> se ajunge prin nodul <k> }
                end;
    end;
end;

procedure afisare_drum(i :integer);
{ afisam drumul de la nodu de pornire pana la nodul <i> }
begin
if i <> 0 then
    begin
    afisare_drum(drum[i]);
    write(i, ' ');
    end;
end;

function calc_cost(k :integer):real;
begin

if k <> 0 then
    begin
    calc_cost := c2[drum[k], k] + calc_cost(drum[k]);
    end
else
    calc_cost := 0;
end;

procedure afis;
var i :integer;
begin
for i := 1 to n do
    if i <> pornire then
        if drum[i] <> 0 then  { am gasit un drum de la <pornire> la <i> }
            begin
            writeln('Drumul de la ', pornire, ' la ', i, ' are lungimea :', calc_cost(i):4:2);
            writeln('Si este compus din ');
            write(' ':7);
            afisare_drum(i);
            writeln;
            end
        else
            writeln('Nu exista drum de la ', pornire, ' la ', i);
end;

procedure re_init_costuri;
var i, j :integer;
begin
c2 := c;
for i := 1 to n do
    for j := 1 to n do
        if (c[i, j] < p_infinit) AND (c[i, j] > 0) then
            c[i, j] :=  1 /  c[i, j];
end;




begin
citire_matrice_costuri; { citim matricea de costuri }
re_init_costuri;

write('Nodul de pornire :');
readln(pornire);

vizitat(pornire);

init_drum;
init_drum_costuri;

dijkstra;


afis;
end.

