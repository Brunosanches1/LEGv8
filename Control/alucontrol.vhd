library ieee;
use ieee.numeric_bit.all;

entity alucontrol is
    port (
        aluop: in bit_vector(1 downto 0);
        opcode: in bit_vector(10 downto 0);
        aluCtrl: out bit_vector(3 downto 0)
    );
end entity;

architecture behav of alucontrol is
    begin
        aluCtrl <= "0010" when (aluop = "00" or (aluop = "10" and
                                            opcode(9) =  '0' and opcode(3) = '1')) else
              "0000" when (aluop = "10" and opcode(8) = '0' and opcode(3) = '0') else
              "0111" when (aluop = "01") else
              "0110" when (aluop = "10" and opcode(9) = '1') else
              "0001" when (aluop = "10" and opcode(8) = '1');

end architecture;