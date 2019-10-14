-------------------------------------------------
--! @file ram_tb.vhd
--! @brief Testbench for Ram
--! @author Bruno M. Sanches (brunosanches@usp.br)
--! @date 2019-08-20
-------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity ram_tb is
end entity ram_tb;

architecture testbench of ram_tb is
  -- Component declaration
  component ram is
    generic (
        addressSize : natural := 8;
        wordSize : natural := 2
    ) ;

    port (
        ck, wr : in bit;
        addr : bit_vector (addressSize - 1 downto 0);
        data_i : in bit_vector (wordSize - 1 downto 0);
        data_o : out bit_vector (wordSize - 1 downto 0)
    ) ;
  end component ram;
    
  -- Signals    
  constant addressSize : natural := 8;
  constant wordSize : natural := 2; 
  signal clock, wr : bit;
  signal address : bit_vector (addressSize - 1 downto 0);
  signal datain : bit_vector (wordSize - 1 downto 0);
  signal dataout: bit_vector (wordSize - 1 downto 0);
    
begin  
  -- component instantiation  
  R : component ram port map (clock, wr, address, datain, dataout);
      
  -- Clock generator
  clk: process is
  begin
    clock <= '0';
    wait for 5 ns;
    clock <= '1';
    wait for 5 ns;
  end process clk;  

  -- Simulation occurs in this process
  process
    type pattern_type is record
        wr : bit;
        address : bit_vector (addressSize - 1 downto 0);
        datain : bit_vector (wordSize - 1 downto 0);
        dataout : bit_vector (wordSize - 1 downto 0); 
    end record;
    type pattern_array is array (natural range <>) of pattern_type;
    constant patterns : pattern_array :=
      (('1',"00000001", "01", "01"),
       ('1',"10000000", "11", "11"),
       ('0',"00000001", "00", "01"),
       ('1',"00010101", "11", "11"),
       ('1',"01000001", "10", "10"),
       ('0',"00010101", "00", "11"),
       ('0',"01000001", "01", "10"),
       ('1',"01111101", "00", "00"),
       ('1',"10010011", "01", "01"),
       ('0',"10010011", "00", "01"),
       ('0',"01111101", "00", "00"),
       ('0',"00000001", "00", "01"));

  begin
    wait for 3 ns;
    -- Check for each pattern
    for i in patterns'range loop
      wr <= patterns(i).wr;
      address <= patterns(i).address;
      datain <= patterns(i).datain;
      -- wait for the results
      wait for 10 ns;
      -- check for the outputs
      assert dataout = patterns(i).dataout report "bad count value" severity error;
    end loop;
    assert false report "end of test" severity note;
    wait; --  Wait forever; this will finish the simulation. 
  end process;
end architecture testbench;

  
