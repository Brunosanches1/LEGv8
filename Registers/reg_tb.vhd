-------------------------------------------------
--! @file ram_tb.vhd
--! @brief Testbench for Reg
--! @author Bruno M. Sanches (brunosanches@usp.br)
--! @date 2019-09-05
-------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity reg_tb is
end entity reg_tb;

architecture testbench of reg_tb is
  -- Component declaration
    component reg is
        generic (wordSize: natural := 4);
        port (
            clock: in bit;
            reset: in bit;
            load: in bit;
            d: in bit_vector(wordSize - 1 downto 0);
            q: out bit_vector(wordSize - 1 downto 0)
        );
    end component reg;

    
  -- Signals    
  constant wordSize : natural := 4; 
  signal ck, res, ld : bit;
  signal dt : bit_vector (wordSize - 1 downto 0);
  signal qt: bit_vector (wordSize - 1 downto 0);
    
begin  
  -- component instantiation  
  R : component reg port map (ck, res, ld, dt, qt);
      
  -- Clock generator
  clk: process is
  begin
    ck <= '0';
    wait for 5 ns;
    ck <= '1';
    wait for 5 ns;
  end process clk;  

  -- Simulation occurs in this process
  process
    type pattern_type is record
        res, ld : bit;
        dt : bit_vector (wordSize - 1 downto 0);
        qt : bit_vector (wordSize - 1 downto 0); 
    end record;
    type pattern_array is array (natural range <>) of pattern_type;
    constant patterns : pattern_array :=
      (('1','0', "0000", "0000"),
       ('0','1', "0001", "0001"),
       ('0','0', "0010", "0001"),
       ('0','1', "0010", "0010"),
       ('0','0', "0011", "0010"),
       ('0','1', "0011", "0011"),
       ('0','0', "0101", "0011"),
       ('0','1', "0101", "0101"),
       ('0','0', "1111", "0101"),
       ('0','1', "1111", "1111"),
       ('0','0', "1110", "1111"),
       ('1','0', "1110", "0000"));

  begin
    wait for 3 ns;
    -- Check for each pattern
    for i in patterns'range loop
      res <= patterns(i).res;
      ld <= patterns(i).ld;
      dt <= patterns(i).dt;
      -- wait for the results
      wait for 10 ns;
      -- check for the outputs
      assert qt = patterns(i).qt report "bad count value" severity error;
    end loop;
    assert false report "end of test" severity note;
    wait; --  Wait forever; this will finish the simulation. 
  end process;
end architecture testbench;

  
