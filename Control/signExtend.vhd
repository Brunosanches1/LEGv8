library ieee;
use ieee.numeric_bit.all;

entity signExtend is
    port (
        i: in bit_vector(31 downto 0); -- input
        o: out bit_vector(63 downto 0) -- output
    );
end signExtend;

architecture behav of signExtend is
    signal outp: bit_vector(63 downto 0);

    begin
        
        with i(31 downto 30) select
            o <= (63 downto 9 => i(20)) & i(20 downto 12) when "11",
                    (63 downto 19 => i(23)) & i(23 downto 5) when "10",
                    (63 downto 26 => i(25)) & i(25 downto 0) when "00",
                    (others => '0') when others;

end architecture;