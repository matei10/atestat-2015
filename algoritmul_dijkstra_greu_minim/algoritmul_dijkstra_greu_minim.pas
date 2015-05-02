program algoritmul_dijkstra_greu_minim;
uses crt;
type mat = array[1..20, 1..20] of integer;
     sir = array[1..20] of integer;
var 
    c :mat;
    d, p :sir;
    i, j, k, n, pl :byte;
    ramase :set of byte;
    min :real;
    f :text;

const p_inf = 1000;

procedure drum(i :byte);
begin
if i <> 0 then
    begin
    drum(p[i]);
    write(i:4);
    end;
end;

begin
clrscr;
assign(f, 'costuri.txt');
reset(f);

readln(f, n);

for i := 1 to n do
    begin
    for j := 1 to n do
        begin
        read(f, c[i, j]);
        if c[i, j] = -1 then
            c[i, j] := p_inf;
        end;
    readln(f);
    end;

for i := 1 to n do
    begin
    for j := 1 to n do
        if c[i, j] = p_inf then
            write(-1:4)
        else
            write(c[i, j]:4);
    writeln;
    end;

write('nodul de plecare :');
readln(pl);

ramase := [1..n] - [pl];

for i := 1 to n do
    if ( i in ramase) then
        d[i] := c[pl, i];

for i := 1 to n do
    if (c[pl, i] <> p_inf) AND (i <> pl) then
        p[i] := pl
    else
        p[i] := 0;

for k := 1 to n-2 do
    begin
    min := 1e20;
    for i := 1 to n do
        if (i in ramase) AND (d[i] < min) then
            begin
            min := d[i];
            j := i;
            end;

    writeln('Am gasit minim : ', j, ' cost :', min);

    ramase := ramase - [j];

    for i := 1 to n do
        if (i in ramase) AND (c[j, i] <> p_inf) then
            if (d[i] = p_inf) or (d[i] > d[j] + c[j, i]) then
                begin
                d[i] := d[j] + c[j, i];
                p[i] := j;
                end;
    end;

for i := 1 to n do
    if i <> pl then 
        begin
        if p[i] = 0 then
            writeln('nu exista')
        else
            begin
            drum(i);
            writeln;
            end;
        end;


for i := 1 to n do 
    write(p[i], ' ');
writeln;
close(f);

end.
