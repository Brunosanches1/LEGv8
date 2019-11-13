library ieee;
use ieee.numeric_bit.all;

entity controlunit is 
    port (
        --To Datapath
        reg2loc : out bit;
        uncondBranch : out bit;
        branch: out bit;
        memRead: out bit;
        memToReg: out bit;
        aluOp: out bit_vector(1 downto 0);
        memWrite: out bit;
        aluSrc: out bit;
        regWrite: out bit;
        -- From Datapath
        opcode: in bit_vector(10 downto 0)
    );
end entity;

architecture behav of controlunit is
    