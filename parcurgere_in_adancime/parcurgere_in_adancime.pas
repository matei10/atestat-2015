program parcurgere_in_adancime;
var a :array[1..100, 1..100] of 0..1; { matricea de adiacenta }
    s :array[0..100] of byte; { stiva }
    viz :array[1..100] of boolean; { vectorul cu noduri vizitate }
    i, n, m, x, p :byte;
    i_s, n_s :integer;
    ok :boolean;


procedure citire_matrice_adiacenta;
{ citim  matricea de adiacenta a grafului }
var i, x, y :integer;
begin
write('n=');
readln(n); { numarul de noduri }

write('m=');
readln(m); { numarul de muchii }

{ initlializam matriea cu 0 }
fillchar(a, sizeof(a), 0);

writeln('In continuare introduceti extremitatile arcelor :');
for i := 1 to m do
    begin
    write('x=');
    readln(x); { extremitatea initiala a arcului (x, y) }

    write('y=');
    readln(y); { extremitatea finala a arcului (x, y) }

    a[x, y] := 1;
    writeln;
    end;
end;


procedure init_stiva;
{ initializam stiva }
begin
n_s := 0;
i_s := 0;
end;


procedure push_stiva(x :byte);
{ adaugam elementul <x> in stiva }
begin
inc(n_s);
s[n_s] := x;
end;


function este_vida_stiva:boolean;
{ returnam TRUE daca stiva este vida, si FALSE in caz contrar }
begin
este_vida_stiva := (n_s = i_s );
end;


procedure pop_stiva;
{ eliminam un element din stiva }
begin
dec(n_s); { eliminam elementul }
end;

function acces_stiva:byte;
{ accesam elementul din varful stivei }
begin
acces_stiva := s[n_s];
end;


procedure init_viz;
{ initializam vectorul cu nodurile vizitate cu FALSE, nici
  un nod nu a fost viziat }
begin
fillchar(viz, sizeof(viz), FALSE);
end;


procedure vizitat(i :byte);
{ marcam nodul <i> ca fiind vizitat }
begin
viz[i] := TRUE;
end;


function a_fost_vizitat(i :byte):boolean;
{ returneaza TRUE daca nodul a fost viziat, in caz contrar
  returneaza FALSE }
begin
a_fost_vizitat := viz[i];
end;


procedure prelucrare_nod(x :byte);
{ prelugram nodul, in cazu de fata o sa il afisam doar }
begin
writeln('Prelugram nodul :', x);
end;


begin
init_stiva; { initializam stiva }

citire_matrice_adiacenta; { citim toate elementele grafului }

write('De la ce nod doriti sa pornim : ');
readln(x); { citim nodul de pornire }

push_stiva(x); { adaugam <x> in stiva }

while  not este_vida_stiva() do { cat timp mai avem noduri de prelucrat in stiva }
    begin

    p := acces_stiva; { accesam elementul din varful stivei }

    if not a_fost_vizitat(p) then { daca elementul nu a fost vizitat }
        begin
        prelucrare_nod(p); { prelucreazal }
        vizitat(p); { noteazal ca fiind vizitat }
        end;

    { cautam un nod de la care putem ajunge de la p, care nu a fost vizitat }
    ok := false; { presupunem ca nu exista nici un nod }
    for i := 1 to n do
        if (a[p, i] = 1) AND ( not a_fost_vizitat(i) ) then
            begin
            push_stiva(i);
            ok := true;
            break;
            end;

    if not ok then
        pop_stiva();

    
    end;

writeln;
end.






