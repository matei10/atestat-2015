program algoritmul_roy_floyd_greu_maxim;
uses crt;
const p_infinit = 1.e10;
      m_infinit = -1.e10;
      n_max = 100;
type 
    multime  = set of 1..n_max;

var 
    c   :array[1..n_max, 1..n_max] of real; { matricea de costuri }
    d   :array[1..n_max, 1..n_max] of multime; { matricea care va tine drumurile }
    dr  :array[1..20] of integer;
    i, j, k, n, ld :integer;
    f :text;

procedure cit_mat_C;
begin
assign(f, 'f1.txt');
reset(f);

readln(f, n);

for i := 1 to n do
    begin
    for j := 1 to n do
        begin
        read(f, c[i, j]);
        if c[i, j] = -1 then
            c[i, j] := p_infinit; { in fisier infinit e notat cu -1 }
        end;
    readln(f);
    end;
end;


procedure init_mat_D;
begin
for i := 1 to n do
    for j := 1 to n do
        if(i<>j) and (c[i, j] < p_infinit) then
            d[i, j] := [i]
        else
            d[i, j] := [ ];
end;

procedure drum_de_la(i, j :integer);
var k :integer;
begin
if (i<>j) then
    begin
    for k := 1 to n do
        if (k in d[i, j]) then
            begin
            ld := ld + 1;
            dr[ld] := k;
            drum_de_la(i, k);
            end;
    end
else
    begin
    for k := ld downto 1 do
        write(dr[k]:5);
    end;
end;

procedure afis;
begin
for i := 1 to n do
    begin
    writeln;
    for j := 1 to n do
        if (c[i, j] = p_infinit) then
            writeln('nu exista drum intre ', i, ' si ', j)
        else
            if(i <> j) then
                begin
                writeln('lungimea drumurilor minime de la ', i, ' la ', j, ' este ',c[i, j]:4:2);
                writeln('iar drumurile sunt :');
                write(' ':7);
                ld := 1;
                dr[ld] := j;
                drum_de_la(i, j);
                writeln;
                end;
    end;
end;

begin
clrscr;
cit_mat_C;
init_mat_D;

for k := 1 to n do
    for i := 1 to n do
        if (c[i, j] = c[i, k] + c[k, j]) then
            d[i, j] := d[i, j] + d[k, j]
        else
            if (c[i, j] > c[i, k] + c[k, j]) then
                begin
                c[i, j] := c[i, k] + c[k, j];
                d[i, j] := d[k, j];
                end;
afis;
(* writeln('---------------------------------'); *)
(* writeln('Matricea costurilor :'); *)
(* for i := 1 to n do *)
(*     begin *)
(*     for j := 1 to n do *)
(*         write( c[i, j] :20:20, ' '); *)
(*     writeln; *)
(*     end; *)
(* writeln; *)
(*  *)
(* writeln('Drumurile :'); *)
(* for i := 1 to n do *)
(*     begin *)
(*     for j := 1 to n do *)
(*         begin *)
(*         writeln('In ', i,', ',j ,' avem :'); *)
(*         for k := 1 to n do *)
(*             if k in d[i, j] then *)
(*                 write(k, ' '); *)
(*         writeln; *)
(*         end; *)
(*     end; *)
(*  *)
readln;
end.



































