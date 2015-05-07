program btk_maxim;
type vector = array[1..1000] of integer;
    drum = record
    v :vector;
    n :integer;
    cost :real;
    end;

var aux, sol :drum;
    f :text;
    c, r, first, last, max, n, i, j, m :integer;
    drumuri :array[1..100, 1..100] of drum;
    costuri :array[1..100, 1..100] of real;
    stiva :array[1..100] of integer;

procedure citire_costuri;
var i, j :integer;
begin
assign(f, 'costuri.txt');
reset(f);

readln(f, n);

for i := 1 to n do
    begin
    for j := 1 to n do
        read(f, costuri[i, j]);
    readln(f);
    end;
close(f);
end;

procedure init(k :integer);
begin
stiva[k] := 0;
end;

procedure init_drum(dr :drum);
begin
dr.n := 0;
dr.cost := 0;
end;


function continua(k :integer):boolean;
var i :integer;
begin
continua := (stiva[1] = first) AND (k <= m ) ;

for i := 2 to k do
    if costuri[stiva[i-1], stiva[i]] = -1 then
        begin
        continua := false;
        end;

for i := 1 to k-1 do 
    for j := i+1 to k do
        if stiva[i] = stiva[j]  then
            begin
            continua := false;
            end;
end;

function exista(k :integer):boolean;
begin
exista := stiva[k] < n;
end;

function solutie(k :integer):boolean;
begin
solutie := stiva[k] = last;
end;

procedure optimizare(k :integer);
var i :integer;
    cost :real;
begin
cost := 0;
for i := 2 to k do
    begin
    cost := costuri[stiva[i-1], stiva[i]] + cost;
    end;

if sol.cost < cost then 
    begin
    init_drum(sol);

    for i := 1 to k do
        sol.v[i] := stiva[i];
    sol.n := k;
    sol.cost := cost;
    end;
end;

procedure bkt(k :integer);
begin
init(k);

while exista(k) do
    begin
    inc(stiva[k]);

    if continua(k) then
        if solutie(k) then 
            optimizare(k)
        else
            bkt(k+1);
    end;
end;

begin
citire_costuri;

{ aflam numarul de muchii }
m := 1;
for i := 1 to n do
    for j := 1 to n do 
        if (costuri[i, j] <> -1) AND ( i <> j) then 
            inc(m);

first := 1;
last := 1;

while first <= n do
    begin
    last := 1;
    while last <= n do
        begin
        writeln(first, ' - ', last);
        writeln;
        if first  <>  last then 
            begin
            writeln('Cautam drumul maxim dintre ', first, ' si ', last );

            init_drum(sol);

            bkt(1);

            if sol.n > 0 then
                begin
                writeln('Drumul maxim de la ', first, ' la ', last , ' are costul :', sol.cost:4:2);
                writeln('Drumul este compus din :');
                for r := 1 to sol.n do
                    write(sol.v[r], ' ');
                writeln;
                end
            else
                writeln('Nu exista drum de la ', first , ' la ',  last);

            drumuri[i, j] := sol;
            end
        else
            writeln('Nu am intrat');

        last := last + 1;
        end;
    first := first + 1;
    end;

end.
