program program_complex;
uses crt;
const n_max = 1000;
      p_inf = 1.e10;
      m_inf = -1.e10;
type
    vector_int = array[1..n_max] of integer;
    vector_bool = array[1..n_max] of boolean;
    matrice_int = array[1..n_max, 1..n_max] of integer; { vector cu elementei integer }
    matrice_real = array[1..n_max, 1..n_max] of real; { vector cu elemente reale }
    matrice_bool = array[1..n_max, 1..n_max] of boolean; { vector cu elemente de tip boolean }

    drum = record { o structura care retine un drum }
        v :vector_int; { elementele drumului }
        n : integer; { numarul de elemente ale drumului }
        end;

    stiva = object
        vector :vector_int; { vector de stocare }
        n :integer; { numar de elemente }
        procedure init; { initializam stiva }
        procedure push(x :integer); { adaugam un element in stiva }
        procedure pop; { eliminam un element din stiva }
        function acces:integer; { accesam elementul din varful stivei }
        function vida:boolean; { verificam daca stiva este sau nu vida }
    end;

    coada = object
        vector :vector_int; { vector de stocare }
        n, i :integer; { numar de elemente }
        procedure init; { initializam coada }
        procedure push(x :integer); { adaugam un element in coada }
        procedure pop; { scoatem un element din coada }
        function acces:integer; { accesam primul element din coada }
        function vida:boolean; { verificam daca coada este vida sau nu }
    end;

    vizitate = object
        vector :vector_bool;
        n :integer;
        procedure init(x :integer); { initializam vectorul de noduri vizitate }
        procedure vizitat(x :integer); { notam nodul <x> ca fiind vizitat }
        function exista_neviz: boolean; { vedem daca mai avem noduri nevizitate }
        function este_neviz(x :integer): boolean; { vedem daca nodul <x> este nevizitat }
    end;

    matrice_drum = array[1..n_max, 1..n_max] of drum; 

    graf = object
        nume, fisier, cauta_roy, cauta_dj :string; { numele grafului, si numele fisierului de unde a fost citit, cauta - reprezinta ce s-a cautat, drumul
                                         minim sau maxim }
        n :integer; { n - numarul de noduri al grafului }
        citit, roy_floyd, dijkstra :boolean; { retine daca graful a fost sau nu citit }
        mat_adiacenta :matrice_bool; { matricea de adiacenta }
        mat_drum :matrice_drum; { matricea de drumuri, pentru roy_floyd }
        mat_costuri, mat_costuri_roy, mat_costuri_dj :matrice_real; { matricea de costuri }
        matrice_drum_dj :matrice_int; { fiecare linie din matrice va fi un vector de drumuri pentru algoritmul dikkstra }
        coada :coada; { coada }
        stiva :stiva; { stiva }
        vizitate :vizitate; { vector cu noduri vizitate }

        procedure init;
        procedure initializare(x :integer); { procedure de initializare a grafului dupa ce stim numarul de noduri }
        procedure initializare_fisier(x :string); { initlializam numele fisierului }
        procedure afisare; { afisam lista arcelor }
        procedure citire_mat_adiacenta; { procedure de citire a matrici de adiacenta din fisier }
        procedure citire_mat_costuri; { procedura care citeste matricea de costuri }
        procedure config_mat_costuri(x :real); { initializam matricea costurilor pentru a cauta drumurile maxime sau minime }
        procedure parcurgere_in_latime(x :integer); { parcurgem graful in latime pornind de la nodul <x> si afisam nodurile gasite }
        procedure parcurgere_in_adancime(x :integer); { parcurgem graful in adancime pornind de la nodul <x> si afisam nodurile gasite }
        procedure set_nume(s :string); { setam un nume }
        procedure set_file(s :string); { setam un fisier }
        procedure afis_mat_adiacenta; { afisam matricea de adiacenta }
        procedure afis_mat_costuri; { afisam matricea costurilor }
        procedure afis_lista_noduri; { afisam lista nodurilor }
        procedure afis_lista_noduri_cost; { afisam lista nodurilor si a costurilor }
        procedure roy_floyd_min; { aflam drumurile minime folosind algoritmul roy_floyd }
        procedure roy_floyd_max; { aflam drumurile minime folosind algoritmul roy_floyd }
        procedure dijkstra_min(x :integer); { aflam drumurile minime del a <x> la restul nodurilor folosind algorimtul dijkstra}
        procedure afis_drum_roy(s :string);  { afisam drumurile maxime }
        procedure afis_drum_dj(x :integer); {afisam drumurile minime de la un nod anume la alte noduri }
        procedure drum_min(a, b :integer); { afisam drumul minim dintre nodul <a> si nodul <b> }
        procedure drum_max(a, b :integer); { afisam drumul maxim dintre nodul <a> si nodul <b> }
    end;

var gf :graf;
{===================================================================================}
{ Metode drumuri }
procedure afis_dr(x, i :integer);
begin
if i <> 0 then
    begin
    afis_dr(x, gf.matrice_drum_dj[x, i]);
    write(i, ' ');
    end;
end;
procedure afis_mat_drum;
var i, j, k :integer;
begin
for i := 1 to gf.n do
    for j := 1 to gf.n do
        begin
        writeln('Drum : ', i, ' - ', j);
        for k := 1 to gf.mat_drum[i, j].n do
            write(gf.mat_drum[i, j].v[k], ' ');
        writeln;
        end;
end;
function inf_or_nr(x :real):string;
begin
if x = p_inf then
    inf_or_nr := 'infinit'
else
    if x = m_inf then
        inf_or_nr := '-infinit'
    else
        str(x:4:2, inf_or_nr);
end;

procedure init_drum(var x :drum);
{ initializam un drum }
begin
x.n := 0;
end;

procedure init_mat_drumuri_min;
{ initializam matricea de drumuri, pentru arcele existente }
var i, j :integer;
begin
for i := 1 to gf.n do
    for j := 1 to gf.n do
        begin
        if (i <> j) AND (gf.mat_costuri[i, j] < p_inf) then
            begin
            gf.mat_drum[i, j].n := 2;
            gf.mat_drum[i, j].v[1] := i;
            gf.mat_drum[i, j].v[2] := j;
            end
        else
            init_drum(gf.mat_drum[i, j]);

        end;
end;


procedure init_mat_drumuri_max;
{ initializam matricea de drumuri, pentru arcele existente }
var i, j :integer;
begin
for i := 1 to gf.n do
    for j := 1 to gf.n do
        begin
        if (i <> j) AND (gf.mat_costuri[i, j] > m_inf) then
            begin
            gf.mat_drum[i, j].n := 2;
            gf.mat_drum[i, j].v[1] := i;
            gf.mat_drum[i, j].v[2] := j;
            end
        else
            init_drum(gf.mat_drum[i, j]);
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

procedure init_vector_drum(x :integer);
var i :integer;
begin
for i := 1 to gf.n do
    begin
    if (x <> i) AND (gf.mat_costuri[x, i] < p_inf) then
        gf.matrice_drum_dj[x, i] := x
    else
        gf.matrice_drum_dj[x, i] := 0;
    writeln;
    end;
end;

{===================================================================================}
{ Metode obiect vizitate }
procedure vizitate.init(x :integer);
{ initializam vectorul de vizitate cu false }
var i :integer;
begin
n := x;

for i := 1 to n do
    vector[i] := False;
end;

procedure vizitate.vizitat(x :integer);
{ notam nodul <x> ca fiind vizitat }
begin
vector[x] := true;
end;

function vizitate.exista_neviz:boolean;
{ verificam daca mai exista sau nu noduri nevizitate }
var i :integer;
begin
exista_neviz := false;
for i := 1 to n do
    if vector[i] = false then
        begin
        exista_neviz := true;
        break;
        end;
end;

function vizitate.este_neviz(x :integer):boolean;
{ verificam daca nodul <x> a fost sau nu vizitat }
begin
este_neviz := not vector[x];
end;
{===================================================================================}
{ Metode obiect stiva }
procedure stiva.init;
{ initializam stiva }
begin
n := 0;
end;

procedure stiva.push(x :integer);
{ adaugam un element in stiva }
begin
n := n + 1;
vector[n] := x;
end;

procedure stiva.pop;
{ eliminam un vector din stiva }
begin
n := n - 1;

if vida() then { daca stiva devine vida }
    init(); { o initializam }
end;

function stiva.acces:integer;
{ returnam elementul din capul stivei }
begin
acces := vector[n];
end;

function stiva.vida:boolean;
{ returnam <True> daca stiva e goala si false in caz contrar }
begin
vida := ( n <= 0 );
end;
{===================================================================================}
{ Metode obiect coada }
procedure coada.init;
{ initializam coada }
begin
i := 1;
n := 0;
end;

procedure coada.push(x :integer);
{ adaugam un element in coada }
begin
n := n + 1;
vector[n] := x;
end;

procedure coada.pop;
{ eliminam un vector din coada }
begin
i := i + 1;

if vida() then { daca stiva este vida }
    init(); { o initializam }
end;

function coada.acces:integer;
begin
acces := vector[i];
end;

function coada.vida:boolean;
begin
vida := (i > n);
end;
{===================================================================================}
{ Metode obiect Graf }

procedure graf.initializare(x :integer);
{ initlializam toate componentele in functie de n }
var i, j :integer;
begin
n := x;

{ initlializam matricea de adiacenta cu False }
for i := 1 to n do
    for j := 1 to n do
        mat_adiacenta[i, j] := False;

end;

procedure graf.initializare_fisier(x :string);
begin
fisier := x;
end;

procedure graf.citire_mat_costuri;
{ citim matricea de costuri si initializam si matricea de adiacenta, si n o data cu asta }
var f :text;
    x, i, j :integer;
begin
assign(f, fisier);
reset(f);

readln(f, x);

{ initlializam graful cu numarul de noduri <x> }
initializare(x);

for i := 1 to x do
    begin
    for j := 1 to x do
        begin
        read(f, mat_costuri[i, j]);
        if mat_costuri[i, j] > 0 then
            mat_adiacenta[i, j] := True;
        end;
    readln(f);
    end;
close(f);
n := x;
citit := true; { marcam graful ca fiind citit }
end;

procedure graf.config_mat_costuri(x :real);
{ configuram matricea costurilor, adica inlocuim <-1> cu x, care va fi <p_inf> sau <m_inf> }
var i, j :integer;
begin
for i := 1 to n do
    for j := 1 to n do
        if (mat_costuri[i, j] = -1) OR (mat_costuri[i, j] = p_inf) OR (mat_costuri[i, j] = m_inf) then
            mat_costuri[i, j] := x;
end;

procedure graf.citire_mat_adiacenta;
var f :text;
    aux, i, j, x :integer;
    
begin
assign(f, fisier);
reset(f);

readln(f, x);

{ initlializam elementele matrici in fuctie de <x> noduri }
initializare(x);

for i := 1 to x do
    begin
    for j := 1 to x do
        begin
        read(f, aux);
        if aux = 1 then
            mat_adiacenta[i, j] := true;
        end;
    readln(f);
    end;
close(f);

{ initliazizam matricea costurilor cu 1 }

for i := 1 to n do
    for j := 1 to n do
        if i = j then
            mat_costuri[i, j] := 0
        else
            if mat_adiacenta[i, j] then
                mat_costuri[i, j] := 1
            else
                mat_costuri[i, j] := -1;
    
citit := true; { marcam graful ca fiind citit }
end;

procedure graf.afisare;
var i, j :integer;
begin
writeln('Graful cu numele :', nume);
writeln('Are urmatoarele arce :');
for i := 1 to n do
    for j := 1 to n do
        if mat_adiacenta[i, j] then
            writeln(i, ' - ', j);
end;

procedure graf.init;
{ procedura care initializeaza un graf }
begin
nume := 'No Name';
fisier := '';
n := 0;
cauta_roy := 'none';
cauta_dj := 'none';
citit := false;
end;

procedure graf.set_nume(s :string);
begin
nume := s;
end;

procedure graf.parcurgere_in_latime(x :integer);
var i, p :integer;
    procedure prelucrare(nod :integer);
    { prelucram nodul <nod>, momentan doar in afisam }
    begin
    write(nod, ' ');
    end;

begin

{ initializam coada }
coada.init;

{ initializam vectorul vizitate }
vizitate.init(n);

{ adaugam nodul <x> in coada }
coada.push(x);

writeln('Graful cu numele <', nume, '>, parcurs in latime de la nodul : ',x);
writeln('Ii gasim urmatoarele noduri :');

while not coada.vida do
    begin

    p := coada.acces;
    if vizitate.este_neviz(p) then { nodul din varful stivei trebuie procesat }
        begin
        prelucrare(p);
        vizitate.vizitat(p);
        end
    else
        coada.pop;

    for i := 1 to n do
        if mat_adiacenta[p, i] AND vizitate.este_neviz(i) then
            coada.push(i);
    end;

writeln;
end;

procedure graf.parcurgere_in_adancime(x :integer);
var i, p :integer;
    ok :boolean;
    procedure prelucrare(nod :integer);
    { prelucram nodul <nod>, momentan doar in afisam }
    begin
    write(nod, ' ');
    end;
begin

{ initializam stiva }
stiva.init;

{ initializam vectorul vizitate }
vizitate.init(n);

{ adaugam nodul <x> in stiva }
stiva.push(x);
(* vizitate.vizitat(stiva.acces); *)


writeln('Graful cu numele <', nume, '>, parcurs adancime de la nodul : ', x);
writeln('Ii gasim urmatoarele noduri :');


while not stiva.vida do
    begin

    p := stiva.acces; { salvam elementul din capul stivei }

    if vizitate.este_neviz(p) then { nodul din varful stivei trebuie procesat }
        begin
        prelucrare(p);
        vizitate.vizitat(p);
        end;

    ok := false; { presupunem ca nu am gasti nici un alt nod nevizitat pornind de la <p> }

    for i := 1 to n do
        if mat_adiacenta[p, i] AND vizitate.este_neviz(i) then
            begin
            stiva.push(i); { adaugam nodul gasit in stiva }
            ok := true; { memoram faptul ca am gasit un nod de la <p> }
            break;
            end;


    if not ok then  { daca nu am gasit nici un nod, eliminam nodul din stiva }
        stiva.pop;
    end;

writeln;
end;

procedure graf.set_file(s :string);
{ setam un fisier de citire }
begin
fisier := s;
end;

procedure graf.afis_mat_adiacenta;
{ afisam matricea de adiacenta }
var i, j :integer;
begin
for i := 1 to n do
    begin
    for j := 1 to n do
        if mat_adiacenta[i, j] then
            write(' * ')
        else
            write(' x ');
    writeln;
    end;
end;

procedure graf.afis_mat_costuri;
{ afisam matricea costurilor }
var i, j :integer;
begin
for i := 1 to n do
    begin
    for j := 1 to n do
        write(' ',inf_or_nr(mat_costuri[i, j]):8, ' ');
    writeln;
    end;
end;

procedure graf.afis_lista_noduri;
var i, j :integer;
begin
writeln('Graful cu numele ', nume, ' are urmatoarele noduri :');
for i := 1 to n do
    for j := 1 to n do
        if mat_adiacenta[i, j] then
            writeln(i, ' - ', j);
end;

procedure graf.afis_lista_noduri_cost;
var i, j :integer;
begin
writeln('Graful cu numele ', nume, ' are urmatoarele noduri :');
for i := 1 to n do
    for j := 1 to n do
        if mat_adiacenta[i, j] then
            writeln(i, ' - ', j, '  : ', mat_costuri[i, j]:4:2);
end;

procedure graf.roy_floyd_min;
var i, j, k :integer;
    a, b, c :string;
begin
{ initializam matricea de costuri }

config_mat_costuri(p_inf);

mat_costuri_roy := mat_costuri;


{ initializam matricea de drumuri }
init_mat_drumuri_min;

writeln(' Vom afisa si modul de lucru al algoritmului :');
writeln;
writeln;

for i := 1 to n do
    for j := 1 to n do
        for k := 1 to n do
            if (k <> i) AND (k <> j) then
                begin

                a := inf_or_nr(mat_costuri_roy[i, j]);
                b := inf_or_nr(mat_costuri_roy[i, k]);
                c := inf_or_nr(mat_costuri_roy[k, j]);
                writeln('Vedem daca drumul direct de la ', i, ' la ', j, ' cu costul : ', a);
                writeln('Este mai mic decat suma drumului de la ', i, ' la ', k, ' cu costul :', b);
                writeln('cu drumul de la ', k, ' la ', j, ' cu costul :', c);

                if (mat_costuri_roy[i, j] > mat_costuri_roy[i, k] + mat_costuri_roy[k, j]) then
                    begin
                    writeln('Costul fiind mai mic, modificam matricea drumurilor si a costurilir !');
                    mat_costuri_roy[i, j] := mat_costuri_roy[i, k] + mat_costuri_roy[k, j];
                    mat_drum[i, j] := concat_drum(mat_drum[i, k], mat_drum[k, j]);
                    end;
                writeln;
                end;

writeln;
writeln;
writeln('Afisam drumurile minime obtinute folosind algoritmul lui Roy-Floyd :');
afis_drum_roy('min');
cauta_roy := 'min';
end;

procedure graf.roy_floyd_max;
var i, j, k :integer;
    a, b, c :string;
begin
{ initializam matricea de costuri }
config_mat_costuri(m_inf);

mat_costuri_roy := mat_costuri;

{ initializam matricea de drumuri }
init_mat_drumuri_max;

writeln(' Vom afisa si modul de lucru al algoritmului :');
writeln;
writeln;

for i := 1 to n do
    for j := 1 to n do
        for k := 1 to n do
            begin
            if (k <> i) AND (k <> j) AND (i <> j) AND (mat_costuri_roy[i, k] > m_inf) AND (mat_costuri_roy[k, j] > m_inf) then
                begin
                a := inf_or_nr(mat_costuri_roy[i, j]);
                b := inf_or_nr(mat_costuri_roy[i, k]);
                c := inf_or_nr(mat_costuri_roy[k, j]);
                writeln('Vedem daca drumul direct de la ', i, ' la ', j, ' cu costul : ', a);
                writeln('Este mai mare decat suma drumului de la ', i, ' la ', k, ' cu costul :', b);
                writeln('cu drumul de la ', k, ' la ', j, ' cu costul :', c);
                if (mat_costuri_roy[i, j] < mat_costuri_roy[i, k] + mat_costuri_roy[k, j]) then
                    begin
                    writeln('Costul fiind mai maxim, modificam matricea drumurilor si a costurilir !');
                    mat_costuri_roy[i, j] := mat_costuri_roy[i, k] + mat_costuri_roy[k, j];
                    mat_drum[i, j] := concat_drum(mat_drum[i, k], mat_drum[k, j]);
                    end;
                writeln;
                end;
            end;


writeln;
writeln;
writeln('Afisam drumurile maxime obtinute folosind algoritmul lui Roy-Floyd :');
afis_drum_roy('max');
cauta_roy := 'max';
end;

procedure graf.dijkstra_min(x :integer);
var p, i, count  :integer;
    min :real;
    s :string;
begin

count := 0;

config_mat_costuri(p_inf);

mat_costuri_dj := mat_costuri; { duplicam matricea costurilor }

vizitate.init(n); { initializam vecotrul cu elemente vizitate }

vizitate.vizitat(x); { notam nodul de pornire x ca fiind vizitat }

init_vector_drum(x); { initializam vectorul drumrilor pentru nodul x }

while vizitate.exista_neviz() AND ( count < n) do
    begin
    min := p_inf; { pe care il stim momentan }
    p := 0;

    for i := 1 to n do { cautam nodul la care putem ajunge cel mai usor de la nodul de pornire }
        if vizitate.este_neviz(i) AND (mat_costuri_dj[x, i] < min ) then
            begin
            min := mat_costuri_dj[x ,i];
            p := i;
            end;

    vizitate.vizitat(p);

    for i := 1 to n do
        if vizitate.este_neviz(i) AND mat_adiacenta[p, i] then
            if mat_costuri_dj[x, i] > mat_costuri_dj[x, p] + mat_costuri[p, i] then
                begin
                mat_costuri_dj[x, i] := mat_costuri_dj[x, p] + mat_costuri[p, i];
                matrice_drum_dj[x, i] := p;
                end;
    count := count + 1;
    end;
writeln(' Drumurile minime de la nodul ', x, ' la restul nodurilor din graf :');
afis_drum_dj(x);
str(x, s);
cauta_dj := cauta_dj + s;
end;

procedure graf.afis_drum_roy(s :string);
var i, j, k :integer; 
    aux :drum;
begin
if s = 'min' then
    begin
    for i := 1 to n do
        for j := 1 to n do
            if i <> j then
                if (mat_costuri_roy[i, j] <> p_inf) then
                    begin
                    writeln('Intre nodurile ', i, ' si  ', j, ' drumul are costul : ', mat_costuri_roy[i, j]:4:2);
                    writeln('Drumul este :');
                    aux := mat_drum[i, j];
                    write(' ':5);
                    for k := 1 to aux.n do
                        write(aux.v[k], ' ');
                    writeln;
                    writeln;
                    end
                else
                    writeln('Intre nodurile ', i, ' si ', j, ' nu exista drum !');
    end
else
    begin
    for i := 1 to n do
        for j := 1 to n do
            if i <> j then
                if (mat_costuri_roy[i, j] <> m_inf) then
                    begin
                    writeln('Intre nodurile ', i, ' si  ', j, ' drumul are costul : ',  mat_costuri_roy[i, j]:4:2);
                    writeln('Drumul este :');
                    aux := mat_drum[i, j];
                    write(' ':5);
                    for k := 1 to aux.n do
                        write(aux.v[k], ' ');
                    writeln;
                    writeln;
                    end
                else
                    writeln('Intre nodurile ', i, ' si ', j, ' nu exista drum !');
    end;
end;

procedure graf.afis_drum_dj(x :integer);
var i :integer;
begin
for i := 1 to n do
    if i <> x then
        if (matrice_drum_dj[x, i] <> 0) then 
            begin
            writeln('Drumul de la ', x, ' la ', i ,' are costul :', mat_costuri_dj[x, i]:4:2);
            writeln('Si este compus din :');
            write(' ':7);
            afis_dr(x, i);
            writeln;
            end
        else
            writeln('Nu exista drum de la ', x, ' la ', i, ' !');
end;

procedure graf.drum_min(a, b :integer);
var i :integer;
    s :string;
begin
str(a, s);
if cauta_roy = 'min' then
    begin
    writeln('Drumul minim a fost folosit deja folosind algoritmul roy-floyd');
    writeln('Drumul minim este :');
    if mat_costuri_roy[a, b] < p_inf then
        for i := 1 to mat_drum[a, b].n do
            write(mat_drum[a, b].v[i], ' ')
    else
        writeln(' Din pacate nu se poate ajunge de la ', a, ' la ', b);
    writeln;
    end
else
    if pos(s, cauta_dj) <> 0 then
        begin
        writeln('Drumul minim a fost folosit deja folosind algoritmul dijkstra ');
        if (mat_costuri_dj[a, b] <> 0) AND (mat_costuri_dj[a, b] < p_inf) then
            begin
            writeln('Drumul de la ', a, ' la ', b ,' are costul :', mat_costuri_dj[a, b]:4:2);
            writeln('Si este compus din :');
            write(' ':7);
            afis_dr(a, b);
            end
        else
            writeln('Nu exista drum de la ', a, ' la ', b, ' !');
        end
    else
        begin
        writeln('Drumul minim nu a fost deja calculat asa ca il vom calcula folosind aglgoritmul dikstra ');

        dijkstra_min(a);

        writeln;
        writeln('Am terminat de calculat drumul minim !');
        writeln;

        if (mat_costuri_dj[a, b] <> 0) AND (mat_costuri_dj[a, b] < p_inf) then
            begin
            writeln('Drumul de la ', a, ' la ', b ,' are costul :', mat_costuri_dj[a, b]:4:2);
            writeln('Si este compus din :');
            write(' ':7);
            afis_dr(a, b);
            end
        else
            writeln('Nu exista drum de la ', a, ' la ', b, ' !');
        end;
writeln;
end;

procedure graf.drum_max(a, b :integer);
var i, k :integer;
    s :string;
    aux :drum;
begin
str(a, s);
if cauta_roy = 'max' then
    begin
    writeln('Drumul maxim a fost folosit deja folosind algoritmul roy-floyd');
    writeln('Drumul maxim este :');
    if mat_costuri_roy[a, b] < p_inf then
        for i := 1 to mat_drum[a, b].n do
            write(mat_drum[a, b].v[i], ' ')
    else
        writeln(' Din pacate nu se poate ajunge de la ', a, ' la ', b);
    writeln;
    end
else
    begin
    writeln('Drumul maxim nu a fost deja calculat asa ca il vom calcula folosind aglgoritmul roy-floyd ');

    roy_floyd_max;

    writeln;
    writeln('Am terminat de calculat drumul roy-floyd!');
    writeln;

    if (mat_costuri_roy[a, b] <> m_inf) AND (mat_costuri_roy[a, b] <> p_inf) then
        begin
        writeln('Intre nodurile ', a, ' si  ', b, ' drumul are costul : ', mat_costuri_roy[a, b]:4:2);
        writeln('Drumul este :');
        aux := mat_drum[a, b];
        write(' ':5);
        for k := 1 to aux.n do
            write(aux.v[k], ' ');
        writeln;
        writeln;
        end
    else
        writeln('Intre nodurile ', a, ' si ', b, ' nu exista drum !');
    end;
writeln;
end;

{===================================================================================}
{ metode ajutatoare }
function to_int(s :string):integer;
{ transformam stringul <s> in integer si il validam }
var cod, n :integer;
begin
val(s, n, cod);

if (cod = 0) and(n <= n_max) and(n <= gf.n) then
    to_int := n
else
    to_int := 0;
end;
function strip(s :string):string;
{ eliminam spatiile albe de la inceputu si finalul stringului si in intoarcem scris cu litere mici }
begin
if length(s) > 0 then 
    begin
    { eliminam spatiile de la inceputul textului }
    while s[1] = ' ' do
        delete(s, 1, 1);

    { eliminam spatiile de la sfarstitul textului }
    while s[length(s)] = ' ' do
        delete(s, length(s), 1);
    end;
strip := lowercase(s);
end;

function elm_spc(s :string):string;
{ eliminam spatiile din <s> }
begin
while pos(' ' ,s) <> 0 do
    delete(s, pos(' ', s), 1);
elm_spc := s;
end;

function elm_space(s :string):string;
{ eliminam toate spatiile albe dintr-un string si il convertim in litere mici  }
begin
s := elm_spc(s); { eliminam spatiile }
elm_space := lowercase(s); { convertim in litera mica }
end;

procedure split_args(s :string; var a, b :string; var ok :boolean);
{ programul imparte comanda in 2 <a> si <b> in functie de paranteze, si foloseste variabila boolean
  pentru a vedea daca parsarea s-a facut corect }
var first, last :integer;
begin
s := elm_spc(s); { eliminam spatiile din s }
ok := true;
first := pos('(', s);
last := pos(')', s);
a := '';
b := '';

if (first = 0) or (last = 0) then
    ok := false;

a := copy(s, 1, first-1);
b := copy(s, first+1, last - first - 1);

end;

procedure split_args2(s :string; var a, b :string; var ok :boolean);
{ programul imparte comanda in 2 <a> si <b> in functie de paranteze, si foloseste variabila boolean
  pentru a vedea daca parsarea s-a facut corect }
var comma :integer;
begin
s := elm_spc(s); { eliminam spatiile din s }
ok := true;
comma := pos(',', s);
a := '';
b := '';

if comma  = 0 then
    ok := false;

a := copy(s, 1, comma-1);
b := copy(s, comma+1, length(s));
end;


function check_close(s :string):boolean;
{ verificam daca utilizatorul a folosit comanda <close> } 
begin
if (elm_space(s) = 'close') or (elm_space(s) = 'exit') or (elm_space(s) = 'bye') then
    check_close := true
else
    check_close := false;
end;


function check_info(s :string):boolean;
{ verificam daca utilizatorul a tastat comanda <info> }
begin
if (elm_space(s) = 'info') then
    check_info := true
else
    check_info := false;
end;

function check_clear(s :string):boolean;
{ verificam daca utilizatorul a tastat comanda <clear> }
begin
if elm_space(s) = 'clear' then
    check_clear := true
else
    check_clear := false;
end;

function check_set_file(s :string):boolean;
{ verificam daca utilizatorul doreste sa seteze un fisier de citire }
var a, b :string;
    ok :boolean;
begin
split_args(s, a, b, ok);

check_set_file :=  ok and (elm_space(a) = 'set_file');
end;

function check_set_nume(s :string):boolean;
{ verificam daca utilizatorul doreste sa seteze un nume }
var a, b :string;
    ok :boolean;
begin
split_args(s, a, b, ok);

check_set_nume :=  ok and (elm_space(a) = 'set_nume');
end;

function check_help(s :string):boolean;
{ verificam daca utilizatorul doreste sa seteze un nume }
begin
s := elm_spc(s);

s := copy(s, 1, 4);

check_help := elm_space(s) = 'help';
end;

function check_citire_adj(s :string):boolean;
begin
s := elm_space(s);

check_citire_adj := s = 'citire_mat_adj';
end;

function check_citire_cost(s :string):boolean;
begin
s := elm_space(s);

check_citire_cost := elm_space(s) = 'citire_mat_cost';
end;

function check_parcurge_latime(s :string):boolean;
var a, b :string;
    ok :boolean;
    n :integer;
begin
split_args(s, a, b, ok);

n := to_int(b);


check_parcurge_latime := (elm_space(a) = 'parcurge_latime') and ok and (n > 0);
end;

function check_parcurge_adancime(s :string):boolean;
var a, b :string;
    ok :boolean;
    n :integer;
begin
split_args(s, a, b, ok);

n := to_int(b);

check_parcurge_adancime := (elm_space(a) = 'parcurge_adancime') and ok and (n > 0);
end;

function check_afisare_muchii(inp :string):boolean;
begin
check_afisare_muchii := elm_space(inp) = 'afisare_muchii';
end;

function check_afisare_muchii_cost(inp :string):boolean;
begin
check_afisare_muchii_cost := elm_space(inp) = 'afisare_muchii_cost';
end;

function check_afis_mat_adj(inp :string):boolean;
begin
check_afis_mat_adj := elm_space(inp) = 'afis_mat_adj';
end;

function check_afis_mat_cost(inp :string):boolean;
begin
check_afis_mat_cost := elm_space(inp) = 'afis_mat_cost';
end;


function check_roy_floyd_min(inp :string):boolean;
begin
check_roy_floyd_min := elm_space(inp) = 'roy_floyd_min';
end;

function check_roy_floyd_max(inp :string):boolean;
begin
check_roy_floyd_max := elm_space(inp) = 'roy_floyd_max';
end;


function check_dijkstra_min(inp :string):boolean;
var a, b :string;
    n :integer;
    ok :boolean;
begin
split_args(inp, a, b, ok);

n := to_int(b);

check_dijkstra_min :=  ok AND (elm_space(a) = 'dijkstra_min') AND ( n > 0 );
end;

function check_drum_min(inp :string):boolean;
var a, b :string;
    ok :boolean;
begin
split_args(inp, a, b, ok);

check_drum_min := ok AND (a = 'drum_min');
end;

function check_drum_max(inp :string):boolean;
var a, b :string;
    ok :boolean;
begin
split_args(inp, a, b, ok);

check_drum_max := ok AND (a = 'drum_max');
end;

function check_credit(inp :string):boolean;
begin
check_credit := elm_space(inp) = 'credit';
end;

function check_blank(inp :string):boolean;
begin
check_blank := elm_space(inp) = '';
end;
{===================================================================================}
{ Metode de afisare }
procedure help(s :string);
{ afisam help in functie de input }
var a, b :string;
    ok :boolean;
begin
s := elm_space(s);
split_args(s, a, b, ok);

writeln;
case b of
    '' :begin
        writeln('Aveti la dispozitie urmatoarele comenzi :');
        writeln('   set_nume(arg)');
        writeln('   set_file(arg)');
        writeln('   citire_mat_cost');
        writeln('   citire_mat_adj');
        writeln('   parcurge_adancime(arg)');
        writeln('   parcurge_latime(arg)');
        writeln('   afisare_muchii');
        writeln('   afisare_muchii_cost');
        writeln('   afis_mat_adj');
        writeln('   afis_mat_cost');
        writeln('   roy_floyd_max');
        writeln('   roy_floyd_min');
        writeln('   dijkstra_min(arg)');
        writeln('   drum_max(arg, arg)');
        writeln('   drum_min(arg, arg)');
        writeln('   credit');
        writeln('');
        writeln('   Pentru mai multe informatii legate de fiecare comanda puteti accesa !');
        writeln('   <help(commanda)> .');
        writeln('   ');
        writeln('   Exemplu de utilizare:');
        writeln('       help(set_nume)');
        writeln('       help(drum_max)');
        writeln('       help(parcurge_latime)');
        writeln('');
        end;
    'set_nume':begin
        writeln('set_nume(arg)');
        writeln('   Cu ajutorul acestei comenzi puteti seta numele grafului.');
        writeln('   Acest nume va fi folosit daca doriti sa salvati graful. ');
        writeln('   Exemplu de utilizare:');
        writeln('       set_nume(GrafulMeu)');
        writeln('   set_nume(arg)');
        writeln('');
        end;
    'set_file':begin
        writeln('set_file(arg)');
        writeln('   Cu ajutorul acestei comenzi puteti seta un fisier sursa al');
        writeln('   grafului.Din acest fisier se va citit, matricea de adiacenta,');
        writeln('   sau matricea costurilor grafului.');
        writeln('   Exemplu de utilizare:');
        writeln('       set_file(graf.txt)');
        writeln('       set_file(costuri.in)');
        end;
    'citire_mat_cost' :begin
        writeln('   citire_mat_cost');
        writeln('   Cu ajutorul acestei comenzi puteti citi matricea costurilor din fiseirul');
        writeln('   setat cu ajutorul comenzi <set_file(arg)> !');
        writeln('   Exemplu de utilizare:');
        writeln('       citire_mat_cost');
        end;
    'citire_mat_adj' :begin
        writeln('   citire_mat_adj');
        writeln('   Cu ajutorul acestei comenzi puteti citi matricea de adiacenta din fiseirul');
        writeln('   setat cu ajutorul comenzi <set_file(arg)> !');
        writeln('   Exemplu de utilizare:');
        writeln('       citire_mat_adj');
        end;
    'parcurge_adancime':begin
        writeln('   parcurgere_adancime(arg)');
        writeln('   Cu ajutorul acestei comenzi puteti parcurge graful in adancime,' );
        writeln('   graful, pornind de la nodul specificat ca si argument .');
        writeln('   Exemplu de utilizare:');
        writeln('       parcurge_adancime(2)');
        writeln('       parcurge_adancime(33)');
        end;
    'parcurge_latime':begin
        writeln('   parcurgere_latime(arg)');
        writeln('   Cu ajutorul acestei comenzi puteti parcurge graful in latime,' );
        writeln('   graful, pornind de la nodul specificat ca si argument .');
        writeln('   Exemplu de utilizare:');
        writeln('       parcurge_latime(2)');
        writeln('       parcurge_latime(33)');
        end;
    'afisare_muchii':begin
        writeln('   afisare_muchii');
        writeln('   Cu ajutorul acestei comenzi putem afisa muchiile grafului stocat momentan .');
        writeln('   Exemplu de utilizare:');
        writeln('       afisare_muchii');
        end;
    'afisare_muchii_cost':begin
        writeln('   afisare_muchii_cost');
        writeln('   Cu ajutorul acestei comenzi putem afisa muchiile grafului stocat momentan si ');
        writeln('   costul asociat fiecarei muchii .'); 
        writeln('   Exemplu de utilizare:');
        writeln('       afisare_muchii');
        end;
    'afis_mat_cost':begin
        writeln('   afis_mat_cost');
        writeln('   Cu ajutorul acestei comenzi putem afisa matricea costurilor asociata grafului. ');
        writeln('   Exemplu de utilizare:');
        writeln('       afis_mat_adj');
        end;
    'afis_mat_adj':begin
        writeln('   afis_mat_adj');
        writeln('   Cu ajutorul acestei comenzi putem afisa matreia de adiacenta a graului .');
        writeln('   Exemplu de utilizare:');
        writeln('       afis_mat_adj');
        end;
    'roy_floyd_max':begin
        writeln('   roy_floyd_max');
        writeln('   Cu ajutorul acestei comenzi cautam drumurile maxiem de la orce nod din graf la restul nodurilor');
        writeln('   cu ajutorul algoritmului lui Roy-Floyd.');
        writeln('   Exemplu de utilizare:');
        writeln('       roy_floyd_max');
        end;
    'roy_floyd_min': begin
        writeln('   roy_floyd_min');
        writeln('   Cu ajutorul acestei comenzi cautam drumurile minime de la orce nod din graf la restul nodurilor');
        writeln('   cu ajutorul algoritmului lui Roy-Floyd.');
        writeln('   Exemplu de utilizare:');
        writeln('       roy_floyd_min');
        end;
    'dijkstra_max':begin
        writeln('   dijkstra_max(arg)');
        writeln('   Cu ajutorul acestei comenzi aflam drumurile maxime de la nodul primit ca si argument ');
        writeln('   si restul nodurilor din graf .');
        writeln('   Exemplu de utilizare:');
        writeln('       dijkstra_max(1)');
        writeln('       dijkstra_max(4)');
        end;
    'dijkstra_min':begin
        writeln('   dijkstra_min(arg)');
        writeln('   Cu ajutorul acestei comenzi aflam drumurile minime de la nodul primit ca si argument ');
        writeln('   si restul nodurilor din graf .');
        writeln('   Exemplu de utilizare:');
        writeln('       dijkstra_min(1)');
        writeln('       dijkstra_min(4)');
        end;
    'drum_max':begin
        writeln('   drum_max(arg, arg)'); 
        writeln('   Cu ajutorl acestei comenzi vom afisa drumul maxim de la nodul primit ca prim argument ');
        writeln('   pana la nodul primit ca al doilea argument. Programul va verifica daca cautarea nu a fost deja ');
        writeln('   facuta. Daca nu a fost facuta, va cauta drumul folosit algoritmul roy-floyd.');
        writeln('   Exemplu de utilizare:');
        writeln('       drum_max(1, 2);');
        writeln('       drum_max(3, 6);');
        end;
    'drum_min':begin
        writeln('   drum_min(arg, arg)'); 
        writeln('   Cu ajutorl acestei comenzi vom afisa drumul minin de la nodul primit ca prim argument ');
        writeln('   pana la nodul primit ca al doilea argument. Programul va verifica daca cautarea nu a fost deja ');
        writeln('   facuta. Daca nu a fost facuta, va cauta drumul folosit algoritmul Dijkstra .');
        writeln('   Exemplu de utilizare:');
        writeln('       drum_min(1, 2);');
        writeln('       drum_min(3, 6);');
        end;
    'credit':begin
        writeln('   credit');
        writeln('   Aceasta comanda va afisa informatii utile despre autorul programului, utilizare, menire si licenta ');
        end;
    end;
writeln;
end;
procedure info;
begin
writeln;
writeln('       Drumuri Minime si Maxime in Grafuri orientate       ');
writeln('   ');
writeln('   ');
writeln('   Accesati comanda <help> pentru mai multe informatii !');
writeln('   ');
writeln('   ');
writeln;
end;

procedure clear;
{ curatam ecranul }
begin
clrscr;
end;

procedure set_file(s :string);
{ setam un fisier de citire }
var a, b :string;
    ok :boolean;
begin
split_args(s, a, b, ok);

if ok then
    begin
    writeln('Am setat fisierul sursa ca fiind :', b);
    gf.set_file(b);
    end;
end;

procedure set_nume(s :string);
{ setam un numele grafului }
var a, b :string;
    ok :boolean;
begin
split_args(s, a, b, ok);

if ok then
    begin
    writeln('Am setat numele grafului ca fiind :', b);
    gf.set_nume(b);
    end;
end;

procedure citire_mat_adiacenta;
begin
writeln;

if gf.fisier <> '' then
    begin
    writeln('Citim matricea de adiacenta din fisierul : ', gf.fisier);
    gf.citire_mat_adiacenta;
    gf.citit := true;
    writeln('Citirea a fost facuta cu succes !');
    end
else
    begin
    writeln('ERROARE:');
    writeln('Nu ati selectat un fisier de unde putem citit matricea de adiacenta !');
    writeln('Folositi comanda <set_file(arg)> pentru a seta unul .');
    writeln('Pentru mai multe informatii folosit comanda <help> .');
    end;
writeln;
end;

procedure citire_mat_costuri;
begin
writeln;

if gf.fisier <> '' then
    begin
    writeln('Citim matricea costurilor din fisierul : ', gf.fisier);
    gf.citire_mat_costuri;
    gf.citit := true;
    writeln('Citirea a fost facuta cu succes !');
    end
else
    begin
    writeln('ERROARE:');
    writeln('Nu ati selectat un fisier de unde putem citit matricea costurilor !');
    writeln('Folositi comanda <set_file(arg)> pentru a seta unul .');
    writeln('Pentru mai multe informatii folosit comanda <help> .');
    end;
writeln;
end;

procedure parcurge_latime(s :string);
{ parcurgem in latime graful }
var a, b :string;
    ok :boolean;
    i :integer;
begin
split_args(s, a, b, ok); { impartim argumentele }

i := to_int(b); { transformam argumentu in integer }

writeln;
if i  > 0 then
    begin
    writeln;
    gf.parcurgere_in_latime(i);
    writeln;
    writeln('Am terminat de parcurs !');
    end
else
    begin
    writeln('ERROARE:');
    writeln(' A aparut o eroare incercand sa parcurgem graful in latime. ');
    writeln(' Folotisi comanda <help> pentru a vede mai multe informatii .');
    end;
writeln;
end;

procedure parcurge_adancime(s :string);
{ parcurgem in latime graful }
var a, b :string;
    ok :boolean;
    i :integer;
begin
split_args(s, a, b, ok); { impartim argumentele }

i := to_int(b); { transformam argumentu in integer }

writeln;
if i  > 0 then
    begin
    writeln;
    gf.parcurgere_in_adancime(i);
    writeln;
    writeln('Am terminat de parcurs !');
    end
else
    begin
    writeln('ERROARE:');
    writeln(' A aparut o eroare incercand sa parcurgem graful in adancime. ');
    writeln(' Folotisi comanda <help> pentru a vede mai multe informatii .');
    end;
writeln;
end;


procedure afisare_muchii(inp :string);
begin
if (gf.n > 0)  then
    gf.afis_lista_noduri
else
    begin
    writeln(' ERROARE:');
    writeln(' Nu avem nici un graf citit, cosnutlati comanda <help> ')
    end;
end;

procedure afisare_muchii_cost(inp :string);
begin
if (gf.n > 0)  then
    gf.afis_lista_noduri_cost
else
    begin
    writeln(' ERROARE:');
    writeln(' Nu avem nici un graf citit, cosnutlati comanda <help> ')
    end;
end;


procedure afis_mat_adj(inp :string);
begin
if gf.citit then
    gf.afis_mat_adiacenta
else
    begin
    writeln(' ERROARE:');
    writeln(' Nu avem nici un graf citit, cosultati comanda <help> ');
    writeln(' pentru mai multe informatii .');
    end;
end;

procedure afis_mat_cost(inp :string);
begin
if gf.citit then
    gf.afis_mat_costuri
else
    begin
    writeln(' ERROARE:');
    writeln(' Nu avem nici un graf citit, cosultati comanda <help> ');
    writeln(' pentru mai multe informatii .');
    end;
end;

procedure roy_floyd_min(inp :string);
var a, b :string;
    ok :boolean;
begin
split_args(inp, a, b, ok);


if gf.citit then
    begin
    gf.roy_floyd_min;
    writeln;
    writeln(' Am terminat de aflat drumurile minime . . . ');
    end
else
    begin
    writeln(' ERROARE:');
    writeln(' Nu avem nici un graf citit, cosultati comanda <help> ');
    writeln(' pentru mai multe informatii .');
    end;
end;

procedure roy_floyd_max(inp :string);
var a, b :string;
    ok :boolean;
begin
split_args(inp, a, b, ok);


if gf.n > 0 then
    begin
    gf.roy_floyd_max;
    writeln;
    writeln(' Am terminat de aflat drumurile maxime. . . ');
    end
else
    begin
    writeln(' ERROARE:');
    writeln(' Nu avem nici un graf citit, cosultati comanda <help> ');
    writeln(' pentru mai multe informatii .');
    end;
end;

procedure dijkstra_min(inp :string);
var a, b :string;
    ok :boolean;
    n :integer;
begin
split_args(inp, a, b, ok);

n := to_int(b);

if gf.n > 0 then
    if n > 0 then
        begin
        gf.dijkstra_min(n);
        writeln(' Am terminat de aflat drumurile minime de la nodul ', n, ' la restul nodurilor . . . ');
        end
    else
        begin
        writeln(' ERROARE:');
        writeln(' Parametrul transmis functiei este incorect, folositi comadna <help> ');
        writeln(' pentru mai multe informatii .');
        end
else
    begin
    writeln(' ERROARE:');
    writeln(' Nu avem nici un graf citit, cosultati comanda <help> ');
    writeln(' pentru mai multe informatii .');
    end;
end;

procedure drum_max(inp :string);
var a, b, c, d :string;
    x, y :integer;
    ok1, ok2 :boolean;
begin
split_args(inp, a, b, ok1);
split_args2(b, c, d, ok2);

x := to_int(c);
y := to_int(d);

if gf.citit then
    begin
    if ok2 AND (x > 0) AND (x <= gf.n) AND (y > 0) AND (y <= gf.n) then
        begin
        writeln('Cautam drumul maxim de la ', x, ' la ', y, ' :');
        gf.drum_max(x, y);
        end
    else
        begin
        writeln(' ERROARE:');
        writeln(' Nu ati transmis argumente corect sau sunt invalide , cosultati comanda <help> ');
        writeln(' pentru mai multe informatii .');
        end;
    end
else
    begin
    writeln(' ERROARE:');
    writeln(' Nu avem nici un graf citit, cosultati comanda <help> ');
    writeln(' pentru mai multe informatii .');
    end;
end;

procedure drum_min(inp :string);
var a, b, c, d :string;
    x, y :integer;
    ok1, ok2 :boolean;
begin
split_args(inp, a, b, ok1);
split_args2(b, c, d, ok2);

x := to_int(c);
y := to_int(d);

if gf.citit then
    begin
    if ok2 AND (x > 0) AND (x <= gf.n) AND (y > 0) AND (y <= gf.n) then
        begin
        writeln('Cautam drumul minim de la ', x, ' la ', y, ' :');
        gf.drum_min(x, y);
        end
    else
        begin
        writeln(' ERROARE:');
        writeln(' Nu ati transmis argumente corect sau sunt invalide , cosultati comanda <help> ');
        writeln(' pentru mai multe informatii .');
        end;
    end
else
    begin
    writeln(' ERROARE:');
    writeln(' Nu avem nici un graf citit, cosultati comanda <help> ');
    writeln(' pentru mai multe informatii .');
    end;
end;

procedure credit(inp :string);
begin
writeln('');
writeln('   Drumuri Minime si Maxime in grafuri Orientate ');
writeln('');
writeln(' Versiunea: 3.0.1');
writeln('');
writeln(' Autor : Micu Matei-Marius');
writeln(' Email : matei10@yahoo.com');
writeln(' Gmail : micumatei@gmail.com');
writeln(' GitHub : matei10');
writeln('');
writeln(' Licenta : MIT ');
writeln('   O copie a licente MIT ar trebui sa fie distribuita o data cu programul ');
writeln('');
writeln(' Descriere :');
writeln('   Programul aduna o serie de algoritmi intr-un singur loc pentru o utilizare mai usoara ');
writeln('');
writeln(' Algoritmi :');
writeln('   - parcurgerea in adancime a unui graf orientat');
writeln('   - parcurgerea in latime a unui graf orientat ');
writeln('   - algoritmul Roy-Floyd');
writeln('   - algoritmul Dijkstra');
writeln('   - o serie de algoritmi auxiliari pentru cititre si afisare a matricilor de adiacenta si cea a costurilor !');
writeln('');
writeln('');
end;

{===================================================================================}
{ Metode de managereriere }
procedure start;
{ ascultam pentru inputul utilizatorului }
var inp :string;
    ok :boolean;
begin
write('>> ');
readln(inp);

while not check_close(inp) do
    begin

    ok := false; { presupunem ca s-a introdus o comanda gresita }

    { verificam daca utilizatorul cere informatii }
    if check_info(inp) then
        begin
        info;
        ok := true;
        end;

    { verificam daca userul doreste sa curatam ecranul }
    if check_clear(inp) then
        begin
        clear;
        ok := true;
        end;

    { verificam daca userul doreste sa seteze un fisier de citire }
    if check_set_file(inp) then
        begin
        set_file(inp);
        ok := true;
        end;

    { verificam daca userul doreste ajutor }
    if check_help(inp) then
        begin
        help(inp);
        ok := true;
        end;

    { verificam daca userul vrea sa citeasca matricea de adiacenta }
    if check_citire_adj(inp) then
        begin
        citire_mat_adiacenta;
        ok := true;
        end;

    { verificam daca userul vrea sa citeasca matricea de costuri }
    if check_citire_cost(inp) then
        begin
        citire_mat_costuri;
        ok := true;
        end;

    { verificam daca userul vrea sa parcurga graful in latime }
    if check_parcurge_latime(inp) then
        begin
        parcurge_latime(inp);
        ok := true;
        end;

    { verificam daca userul vrea sa parcurga graful in adancime }
    if check_parcurge_adancime(inp) then
        begin
        parcurge_adancime(inp);
        ok := true;
        end;

    { verificam daca userul vrea sa afisam muchiile grafului }
    if check_afisare_muchii(inp) then
        begin
        afisare_muchii(inp);
        ok := true;
        end;


    { verificam daca userul vrea sa afisam muchiile grafului si costul asociat  }
    if check_afisare_muchii_cost(inp) then
        begin
        afisare_muchii_cost(inp);
        ok := true;
        end;

    { verificam daca userul doreste sa afisam matricea de adiacenta }
    if check_afis_mat_adj(inp) then
        begin
        afis_mat_adj(inp);
        ok := true;
        end;

    { verificam daca userul doreste sa afisam matricea costurilor asociate }
    if check_afis_mat_cost(inp) then
        begin
        afis_mat_cost(inp);
        ok := true;
        end;

    { verificam daca userul doreste sa foloseasca algoritmul roy-floyd pentru drumuri minime }
    if check_roy_floyd_min(inp) then
        begin
        roy_floyd_min(inp);
        ok := true;
        end;

    { verificam daca userul doreste sa foloseasca algoritmul roy-floyd pentru drumuri maxime}
    if check_roy_floyd_max(inp) then
        begin
        roy_floyd_max(inp);
        ok := true;
        end;

    { verificam daca userul doreste sa afle durmurile minime de la un nod anume folosid algoritmul dijkstra }
    if check_dijkstra_min(inp) then
        begin
        dijkstra_min(inp);
        ok := true;
        end;

    { verificam daca utilizatorul doreste sa afisam drumul minim  dintre doua noduri }
    if check_drum_min(inp) then
        begin
        drum_min(inp);
        ok := true;
        end;

    { verificam daca utilizatorul doreste sa afisam drumul maxi dintre doua noduri }
    if check_drum_max(inp) then
        begin
        drum_max(inp);
        ok := true;
        end;

    { daca se doreste afisarea creditelor }
    if check_credit(inp) then
        begin
        credit(inp);
        ok := true;
        end;

    { daca s-a introdus o linie goala }
    if check_blank(inp) then
        begin
        ok := true;
        end;

    { daca nu s-a introdus o linie corecta }
    if not ok then
        begin
        writeln;
        writeln(' Comanca introdusa nu a fost recunoscuta ');
        writeln(' Folositi comanda <help> pentru mai multe informatii ');
        writeln;
        end;

    write('>> ');
    readln(inp);
    end;
end;

{===================================================================================}

{ Program Principal }
begin
gf.init; { initializam obiectul graf }

info; { display info }


start; { ascultam pentru mesajele utilizatorilor }
writeln;
end.
