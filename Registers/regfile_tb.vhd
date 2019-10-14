library IEEE;
use IEEE.std_logic_1164.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;

entity regfile_tb is
end entity regfile_tb;

architecture testbench of regfile_tb is
  -- Component declaration
    component regfile is
        generic(
            regn: natural := 4;
            wordSize: natural := 2
        );
        port(
            clock: in bit;
            reset: in bit;
            regWrite: in bit;
            rr1, rr2, wr: in bit_vector(natural(ceil(log2(real(regn)))) - 1 downto 0);
            d: in bit_vector(wordSize - 1 downto 0);
            q1, q2: out bit_vector(wordSize - 1 downto 0)
        );
    end component;

  -- Signals
    constant regn: natural :=4;    
    constant wordSize : natural := 2; 
    signal ck, res, rw : bit;
    signal rr1s, rr2s, wrs: bit_vector(natural(ceil(log2(real(regn)))) - 1 downto 0);
    signal ds: bit_vector(wordSize - 1 downto 0);
    signal q1s, q2s: bit_vector(wordSize - 1 downto 0);
    
begin  
  -- component instantiation  
    R : component regfile port map (ck, res, rw, rr1s, rr2s, wrs, ds, q1s, q2s);
      
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
            res, rw : bit;
            rr1s, rr2s, wrs: bit_vector(natural(ceil(log2(real(regn)))) - 1 downto 0);
            ds: bit_vector(wordSize - 1 downto 0);
            q1s, q2s: bit_vector(wordSize - 1 downto 0); 
    end record;
    type pattern_array is array (natural range <>) of pattern_type;
    constant patterns : pattern_array :=
      (('1','0', "00", "00", "00", "00", "00", "00"),
       ('0','1', "00", "01", "00", "11", "11", "00"),
       ('0','0', "00", "01", "01", "11", "11", "00"),
       ('0','1', "00", "01", "01", "11", "11", "11"),
       ('0','0', "00", "01", "00", "11", "11", "11"),
       ('0','1', "10", "01", "10", "11", "11", "11"),
       ('0','0', "10", "01", "00", "11", "11", "11"),
       ('0','1', "11", "01", "11", "11", "00", "11"),
       ('0','0', "11", "01", "00", "11", "00", "11"),
       ('0','0', "00", "01", "00", "11", "11", "11"),
       ('0','0', "00", "01", "00", "10", "11", "11"),
       ('0','1', "00", "01", "01", "10", "11", "10"),
       ('0','0', "00", "01", "00", "10", "11", "10"),
       ('0','1', "11", "10", "11", "10", "00", "11"),
       ('0','0', "11", "00", "00", "10", "00", "11"),
       ('1','0', "00", "00", "00", "00", "00", "00"));

  begin
    wait for 3 ns;
    -- Check for each pattern
    for i in patterns'range loop
      res <= patterns(i).res;
      rw <= patterns(i).rw;
      rr1s <= patterns(i).rr1s;
      rr2s <= patterns(i).rr2s;
      wrs <= patterns(i).wrs;
      ds <= patterns(i).ds;
      -- wait for the results
      wait for 10 ns;
      -- check for the outputs
      assert q1s = patterns(i).q1s report "bad count value" severity error;
      assert q2s = patterns(i).q2s report "bad count value" severity error;
    end loop;
    assert false report "end of test" severity note;
    wait; --  Wait forever; this will finish the simulation. 
  end process;
end architecture testbench;

  
