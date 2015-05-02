program parcurgere_in_latime;
var a :array[1..100, 1..100] of 0..1; { matricea de adiacenta }
    c :array[0..100] of byte; { coada }
    viz :array[1..100] of boolean; { vectorul cu noduri vizitate }
    i, n, m, x, p :byte;
    i_c, n_c :integer;


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


procedure init_coada;
{ initializam coada }
begin
n_c := -1;
i_c := 0;
end;


procedure push_coada(x :byte);
{ adaugam elementul <x> in coada }
begin
inc(n_c);
c[n_c] := x;
end;


function este_vida_coada:boolean;
{ returnam TRUE daca coada este vida, si FALSE in caz contrar }
begin
este_vida_coada := (n_c < i_c );
end;


function pop_coada:byte;
{ returnam primul element din coada si il eliminam 
  acest subprogram se utilizeaza doar cand coada nu 
  este vida }
begin
pop_coada := c[i_c]; { returnam elementul }
inc(i_c); { eliminam elementul }
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
init_coada; { initializam coada }

citire_matrice_adiacenta; { citim toate elementele grafului }

write('De la ce nod doriti sa pornim : ');
readln(x); { citim nodul de pornire }

push_coada(x); { adaugam <x> in coada }

while  not este_vida_coada() do { cat timp mai avem noduri de prelucrat in coada }
    begin
    
    p := pop_coada; { scoatem un element din coada }

    prelucrare_nod(p); { prelucram nodul }

    vizitat(p); { noram nodul ca fiind vizitat }

    { cautam toate nodurile la care putem ajunge prin nodul x }
    for i := 1 to n do
        if (a[p, i] = 1) AND not a_fost_vizitat(i) then { daca exista arc de la <p> la <i> si daca nu
                                                        am vizitat nodul <i> }
            push_coada(i); { adauga nodul in coada }

    end;

writeln;
end.






