library ieee;
use ieee.math_real.ceil;
use ieee.math_real.log2;
use ieee.numeric_bit.all;

entity regfile is
    generic(
        regn: natural := 32;
        wordSize: natural := 64
    );
    port(
        clock: in bit;
        reset: in bit;
        regWrite: in bit;
        rr1, rr2, wr: in bit_vector(natural(ceil(log2(real(regn)))) - 1 downto 0);
        d: in bit_vector(wordSize - 1 downto 0);
        q1, q2: out bit_vector(wordSize - 1 downto 0)
    );
end regfile;

architecture regfile of regfile is
    type qArray is array (regn - 1 downto 0) of bit_vector (wordSize - 1 downto 0);
    signal qA: qArray;
    signal ld: bit_vector(regn - 1 downto 0);
    component reg is
        generic (wordSize: natural := wordSize);
        port (
            clock: in bit;
            reset: in bit;
            load: in bit;
            d: in bit_vector(wordSize - 1 downto 0);
            q: out bit_vector(wordSize - 1 downto 0)
        );
    end component reg;

    begin
        GEN_REG:
        for i in 0 to regn - 1 generate
            GEN_REG31:
                if i = (regn - 1) generate
                    regx : reg port map (clock, '1', ld(i), d, qA(i));
                end generate;
            GEN_REG2:
                if i /= (regn - 1) generate
                    regx: reg port map (clock, reset, ld(i), d, qA(i));
                end generate;
        end generate;

        p1: process (regWrite)
            begin
                if regWrite = '1' then
                    ld(to_integer(unsigned(wr))) <= '1';
                elsif regWrite = '0' then
                    ld <= (others => '0');
                end if;
                
        end process;

        q1 <= qA(to_integer(unsigned(rr1)));
        q2 <= qA(to_integer(unsigned(rr2)));
end architecture;

        
