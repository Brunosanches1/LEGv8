library IEEE;
use IEEE.numeric_bit.all;

entity fulladder is
    port (
        a, b, cin: in bit;
        s, cout: out bit
    );
end entity;

architecture behav_fulladder of fulladder is
signal sum: bit;
signal c: bit;
begin
    sum <= a xor b xor cin;
    c <= (cin and (a or b)) or (a and b);

    s <= sum;
    cout <= c;
end behav_fulladder;


library IEEE;
use IEEE.numeric_bit.all;

entity alu1bit is
    port (
        a, b, less, cin: in bit;
        result, cout, set, overflow: out bit;
        ainvert, binvert: in bit;
        operation: in bit_vector(1 downto 0)
    );
end entity;

architecture behav of alu1bit is

component fulladder is
    port (
            a, b, cin: in bit;
            s, cout: out bit
        );
end component;

signal ai, bi, ci, co, sum, ov, res, ls: bit;

begin

ai <= a xor ainvert;
bi <= b xor binvert;
ci <= cin;

f1: fulladder port map (ai, bi, ci, sum, co);

cout <= co;
set <= sum;
ov <= co xor ci;

with operation select res <=
    (ai and bi) when "00",
    (ai or bi) when "01",
    sum when "10",
    b when "11"; 

result <= res;
overflow <= ov;
end behav;