-------------------------------------------------
--! @file signExtend.vhd
--! @brief Testbench for Sign Extender
--! @author Bruno M. Sanches (brunosanches@usp.br)
--! @date 2019-11-12
-------------------------------------------------

library IEEE;
use IEEE.numeric_bit.all;

entity signExtend_tb is
end entity signExtend_tb;

architecture testbench of signExtend_tb is
  -- Component declaration
  component signExtend is
    port (
      i: in bit_vector (31 downto 0);
      o: out bit_vector(63 downto 0)
    );
  end component signExtend;
    
  -- Signals    
  signal inp: bit_vector(31 downto 0);
  signal outp: bit_vector(63 downto 0);

begin  
  -- component instantiation  
  A : component signExtend port map (inp, outp);

  -- Simulation occurs in this process
  process

  begin
    wait for 1 ns;
    -- Check for each pattern
    inp <= "11111000010000000100000000000001";

    wait for 1 ns;
    assert outp = "0000000000000000000000000000000000000000000000000000000000000100" report "Output bad count value" severity error;

    inp <= "11111000010100000100000000000001";

    wait for 1 ns;
    assert outp = "1111111111111111111111111111111111111111111111111111111100000100" report "Output bad count value" severity error;

    inp <= "11111000000100000100000000000001";

    wait for 1 ns;
    assert outp = "1111111111111111111111111111111111111111111111111111111100000100" report "Output bad count value" severity error;

    inp <= "10110100000000000000000010000001";

    wait for 1 ns;
    assert outp = "0000000000000000000000000000000000000000000000000000000000000100" report "Output bad count value" severity error;

    inp <= "00010100000000000000000000000100";

    wait for 1 ns;
    assert outp = "0000000000000000000000000000000000000000000000000000000000000100" report "Output bad count value" severity error;
    
  assert false report "end of test" severity note;
  wait; --  Wait forever; this will finish the simulation. 
  end process;
end architecture testbench;

  
