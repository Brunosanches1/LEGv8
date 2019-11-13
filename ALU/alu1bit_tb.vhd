-------------------------------------------------
--! @file alu1bit_tb.vhd
--! @brief Testbench for ALU 1 bit
--! @author Bruno M. Sanches (brunosanches@usp.br)
--! @date 2019-10-25
-------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity alu1bit_tb is
end entity alu1bit_tb;

architecture testbench of alu1bit_tb is
  -- Component declaration
  component alu1bit is
    port (
      a, b, less, cin: in bit;
      result, cout, set, overflow: out bit;
      ainvert, binvert: in bit;
      operation: in bit_vector(1 downto 0)
    );
  end component alu1bit;
    
  -- Signals    
  signal a_sig, b_sig, less_sig, cin_sig, result_sig, cout_sig, set_sig, overflow_sig, ainvert_sig, binvert_sig : bit;
  signal operation_sig : bit_vector (1 downto 0);

begin  
  -- component instantiation  
  A : component alu1bit port map (a_sig, b_sig, less_sig, cin_sig, result_sig, cout_sig, set_sig, overflow_sig,
                                  ainvert_sig, binvert_sig, operation_sig);

  -- Simulation occurs in this process
  process
    type pattern_type is record
      operation : bit_vector (1 downto 0);
      a, b, cin, ainvert, binvert, less, cout, set, result, overflow: bit;
        
    end record;
    type pattern_array is array (natural range <>) of pattern_type;
    constant patterns : pattern_array :=
    --  Op,   a,   b,  cin, ai,  bi, less, cout, set, res, ov
      (("00",'1', '1', '0', '0', '0', '0', '1', '0', '1', '1'),
       ("00",'0', '1', '0', '0', '0', '0', '0', '1', '0', '0'),
       ("01",'1', '1', '0', '0', '0', '0', '1', '0', '1', '1'),
       ("01",'1', '0', '0', '0', '0', '0', '0', '1', '1', '0'),
       ("10",'0', '0', '0', '0', '0', '0', '0', '0', '0', '0'),
       ("10",'0', '0', '1', '0', '0', '0', '0', '1', '1', '1'),
       ("10",'0', '1', '0', '0', '0', '0', '0', '1', '1', '0'),
       ("10",'0', '1', '1', '0', '0', '0', '1', '0', '0', '0'),
       ("10",'1', '0', '0', '0', '0', '0', '0', '1', '1', '0'),
       ("10",'1', '0', '1', '0', '0', '0', '1', '0', '0', '0'),
       ("10",'1', '1', '0', '0', '0', '0', '1', '0', '0', '1'),
       ("10",'1', '1', '1', '0', '0', '0', '1', '1', '1', '0'),
       ("10",'1', '0', '0', '0', '1', '0', '1', '0', '0', '1'),
       ("11",'1', '0', '0', '0', '0', '1', '0', '1', '0', '0'));


  begin
    wait for 3 ns;
    -- Check for each pattern
    for i in patterns'range loop
      a_sig <= patterns(i).a;
      b_sig <= patterns(i).b;
      operation_sig <= patterns(i).operation;
      cin_sig <= patterns(i).cin;
      ainvert_sig <= patterns(i).ainvert;
      binvert_sig <= patterns(i).binvert;
      less_sig <= patterns(i).less;
      -- wait for the results
      wait for 10 ns;
      -- check for the outputs
      assert cout_sig = patterns(i).cout report " Cout bad count value" severity error;
      assert set_sig = patterns(i).set report "set bad count value" severity error;
      assert result_sig = patterns(i).result report "Result bad count value" severity error;
      assert overflow_sig = patterns(i).overflow report "Overflow bad count value" severity error;
    end loop;
    assert false report "end of test" severity note;
    wait; --  Wait forever; this will finish the simulation. 
  end process;
end architecture testbench;

  
