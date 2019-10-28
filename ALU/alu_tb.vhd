-------------------------------------------------
--! @file alu_tb.vhd
--! @brief Testbench for ALU 
--! @author Bruno M. Sanches (brunosanches@usp.br)
--! @date 2019-10-28
-------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity alu_tb is
end entity alu_tb;

architecture testbench of alu_tb is
  -- Component declaration
  component alu is
     generic (
        size: natural := 3 --bit size of the alu
    );
    port (
        A, B: in bit_vector(size-1 downto 0); --inputs
        F: out bit_vector(size - 1 downto 0); --output
        S: in bit_vector(3 downto 0); --op selection
        Z: out bit; --zero flag
        Ov: out bit; --overflow flag
        Co: out bit -- Carry out
    );
  end component alu;
    
  -- Signals
  constant size: natural := 3;    
  signal A, B, F: bit_vector (size - 1 downto 0);
  signal S: bit_vector (3 downto 0);
  signal Z, Ov, Co: bit;

begin  
  -- component instantiation  
  X : alu port map (A, B, F, S, Z, Ov, Co);

  -- Simulation occurs in this process
  process
    type pattern_type is record
      A, B, F: bit_vector (size - 1 downto 0);
      S: bit_vector (3 downto 0);
      Z, Ov, Co: bit;
        
    end record;
    type pattern_array is array (natural range <>) of pattern_type;
    constant patterns : pattern_array := 
    --    A      B      F      S      Z    Ov   Co
      (("000", "000", "000", "0000", '1', '0', '0'),
       ("111", "111", "111", "0000", '0', '0', '1'),
       ("000", "101", "101", "0001", '0', '0', '0'),
       ("001", "010", "011", "0010", '0', '0', '0'),
       ("001", "011", "100", "0010", '0', '1', '0'),
       ("100", "010", "010", "0110", '0', '1', '1'),
       ("010", "010", "000", "0110", '1', '0', '1'),
       ("011", "010", "001", "0111", '0', '0', '1'),
       ("000", "000", "111", "1100", '0', '0', '1'),
       ("010", "010", "000", "0111", '1', '0', '1'),
       ("010", "111", "001", "0111", '0', '0', '0'),
       ("111", "111", "000", "1100", '1', '0', '0'));

  begin
    wait for 1 ns;
    -- Check for each pattern
    for i in patterns'range loop
      A <= patterns(i).A;
      B <= patterns(i).B;
      S <= patterns(i).S;
      -- wait for the results
      wait for 10 ns;
      -- check for the outputs
      assert F = patterns(i).F report " F bad count value" severity error;
      assert Z = patterns(i).Z report "Z bad count value" severity error;
      assert Ov = patterns(i).Ov report "Ov bad count value" severity error;
      assert Co = patterns(i).Co report "Co bad count value" severity error;
    end loop;
    assert false report "end of test" severity note;
    wait; --  Wait forever; this will finish the simulation. 
  end process;
end architecture testbench;

  
