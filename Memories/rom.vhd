library ieee;
use ieee.numeric_bit.all;

library STD;
use std.textio.all;

entity rom is
    generic (
        addressSize : natural := 64;
        wordSize : natural :=64;
        mifFileName : string := "rom.dat"
    );
    port (
        addr : in bit_vector(addressSize - 1 downto 0);
        data : out bit_vector(wordSize - 1 downto 0)
    );
end rom;

architecture structural of rom is 
    constant data_depth : natural := 2**addressSize;
    type mem_tipo is array (0 to data_depth - 1) of bit_vector (wordSize - 1 downto 0);

    impure function init_mem(mif_file_name : in string) return mem_tipo is
        file mif_file : text open read_mode is mif_file_name;
        variable mif_line : line;
        variable temp_bv : bit_vector(wordSize - 1 downto 0);
        variable temp_mem : mem_tipo;

        begin
            for i in mem_tipo'range loop
                readline(mif_file, mif_line);
                read(mif_line, temp_bv);
                temp_mem(i) := temp_bv;
            end loop;
        return temp_mem;
    end function;

    constant mem : mem_tipo := init_mem(mifFileName);

    begin
    data <= mem(to_integer(unsigned(addr)));

end architecture;
