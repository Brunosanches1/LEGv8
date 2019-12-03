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
    type control_signals is record
        reg2loc : bit;
        uncondBranch : bit;
        branch: bit;
        memRead: bit;
        memToReg: bit;
        aluOp: bit_vector(1 downto 0);
        memWrite: bit;
        aluSrc: bit;
        regWrite: bit;
    end record;

    signal cs: control_signals;

    begin
        cs <= ('0', '0', '0', '1', '1', "00", '0', '1', '1') when opcode = "11111000010" else
              ('1', '0', '0', '0', '0', "00", '1', '1', '0') when opcode = "11111000000" else
              ('1', '0', '1', '0', '0', "01", '0', '0', '0') when opcode(10 downto 3) = "10110100" else
              ('0', '1', '0', '0', '0', "00", '0', '0', '0') when opcode(10 downto 5) = "000101" else
              ('0', '0', '0', '0', '0', "10", '0', '0', '1') when opcode = "10001011000" or
                                                                  opcode = "11001011000" or
                                                                  opcode = "10001010000" or
                                                                  opcode = "10101010000"else 
              ('0', '0', '0', '0', '0', "00", '0', '0', '0');

        reg2Loc <= cs.reg2loc;
        uncondBranch <= cs.uncondBranch;
        branch <= cs.branch;
        memRead <= cs.memRead;
        memToReg <= cs.memToReg;
        aluOp <= cs.aluOp;
        memWrite <= cs.memWrite;
        aluSrc <= cs.aluSrc;
        regWrite <= cs.regWrite;
end architecture;
    
    