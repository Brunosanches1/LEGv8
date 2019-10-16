library IEEE;
use IEEE.numeri_bit.all;

entity fulladder is
    port (
        af, bf, cinf: in bit;
        sf, coutf: out bit
    );
end entity;

architecture behav_fulladder of fulladder is
signal sum: bit;
signal c: bit;
begin
    sum <= af xor bf xor cinf;
    cout <= (cinf and (af or bf)) or (af and bf);

    sf <= sum;
    coutf <= c;
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
            af, bf, cinf: in bit;
            sf, coutf: out bit
        );
end component;

signal ai, bi, ci, co, sum, ov, res, ls: bit;

ai <= a xor ainvert;
b1 <= b xor binvert;
ci <= cin;

f1: port map fulladder(ai, bi, ci, sum, co);

cout <= co;
set <= sum;
ov <= co and (not sum);

if operation = '00' then
    res <= ai and bi;
elsif operation = '01' then
    res <= ai or bi;
elsif operation = '10' then 
    res <= sum;
else then 
    res <= less;
end if;

result <= res;
overflow <= ov;
end behav;