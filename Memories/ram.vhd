library ieee;
use ieee.numeric_bit.all;

entity ram is
    generic (
        addressSize : natural := 64;
        wordSize : natural := 32
    ) ;

    port (
        ck, wr : in bit;
        addr : bit_vector (addressSize - 1 downto 0);
        data_i : in bit_vector (wordSize - 1 downto 0);
        data_o : out bit_vector (wordSize - 1 downto 0)
    ) ;
end ram;

architecture structural of ram is
    constant enderecos : natural := 2**addressSize;
    type mem_tipo is array (0 to (enderecos - 1)) of bit_vector (wordSize - 1 downto 0);
    signal ram : mem_tipo;
    begin

        p1: Process (ck) is
            begin                
                if ck'event and ck = '1' then
                    if (wr = '1') then
                        ram(to_integer(unsigned(addr))) <= data_i;
                        end if;
                end if;
        end process p1;
        

        data_o <= ram(to_integer(unsigned(addr)));
       
end architecture;
