-------------------------------------------------
--! @file alucontrol.vhd
--! @brief Testbench for ALU Controler
--! @author Bruno M. Sanches (brunosanches@usp.br)
--! @date 2019-11-13
-------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity alucontrol_tb is
end entity alucontrol_tb;

architecture testbench of alucontrol_tb is
  -- Component declaration
  component alucontrol is
    port (
        aluop: in bit_vector(1 downto 0);
        opcode: in bit_vector(10 downto 0);
        aluCtrl: out bit_vector(3 downto 0)
    );
  end component alucontrol;
    
  -- Signals    
    signal aluop: bit_vector(1 downto 0);
    signal opcode: bit_vector(10 downto 0);
    signal aluctrl: bit_vector(3 downto 0);

begin  
  -- component instantiation  
  A : component alucontrol port map (aluop, opcode, aluctrl);

  -- Simulation occurs in this process
  process
    type pattern_type is record
        aluop: bit_vector(1 downto 0);
        opcode: bit_vector(10 downto 0);
        aluctrl: bit_vector(3 downto 0);
        
    end record;
    type pattern_array is array (natural range <>) of pattern_type;
    constant patterns : pattern_array :=
      (("00", "11111111111", "0010"),
       ("01", "00000000000", "0111"),
       ("10", "10001011000", "0010"),
       ("10", "11001011000", "0110"),
       ("10", "10001010000", "0000"),
       ("10", "10101010000", "0001"));


  begin
    wait for 3 ns;
    -- Check for each pattern
    for i in patterns'range loop
      aluop <= patterns(i).aluop;
      opcode <= patterns(i).opcode;
      -- wait for the results
      wait for 10 ns;
      -- check for the outputs
      assert aluctrl = patterns(i).aluctrl report " ALU Control bad count value" severity error;
    end loop;
    assert false report "end of test" severity note;
    wait; --  Wait forever; this will finish the simulation. 
  end process;
end architecture testbench;

  
