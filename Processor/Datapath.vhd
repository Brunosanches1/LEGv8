library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;

entity datapath is 
    port (
        --Common
        clock: in bit;
        reset: in bit;
        --From Control Unit
        reg2loc:in bit;
        pcsrc: in bit;
        memToReg: in bit;
        aluCtrl: in bit_vector(3 downto 0);
        aluSrc: in bit;
        regWrite: in bit;
        --To Control Unit
        opcode: out bit_vector(10 downto 0);
        zero: out bit;
        --IM interface
        imAddr: out bit_vector(63 downto 0);
        imOut: in bit_vector(31 downto 0);
        --DM Interface
        dmAddr: out bit_vector(63 downto 0);
        dmIn: out bit_vector(63 downto 0);
        dmOut: in bit_vector(63 downto 0)
    );
end entity datapath;

architecture RTL of datapath is

    component regfile is
        generic(
            regn: natural := 32;
            wordSize: natural := 64
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

    component signExtend is
        port (
            i: in bit_vector(31 downto 0); -- input
            o: out bit_vector(63 downto 0) -- output
        );
    end component;

    component reg is
        generic (wordSize: natural := 64);
        port (
            clock: in bit;
            reset: in bit;
            load: in bit;
            d: in bit_vector(wordSize - 1 downto 0);
            q: out bit_vector(wordSize - 1 downto 0)
        );
    end component;

    component alu is 
        generic (
             size: natural := 64 --bit size of the alu
            );
        port (
            A, B: in bit_vector(size-1 downto 0); --inputs
            F: out bit_vector(size - 1 downto 0); --output
            S: in bit_vector(3 downto 0); --op selection
            Z: out bit; --zero flag
            Ov: out bit; --overflow flag
            Co: out bit -- Carry out
        );
    end component;

    
    signal clk, res: bit;
    signal rr1, rr2, wr: bit_vector(4 downto 0);
    signal regData, q1, q2: bit_vector(63 downto 0);

    signal SigExIn: bit_vector(31 downto 0);
    signal SigExOut, shiftOut: bit_vector(63 downto 0);

    signal Alu1Res, Alu1_in2, Alu2Res, AluPcRes: bit_vector(63 downto 0);

    signal PCOut, PCInput: bit_vector(63 downto 0);

    signal ZeroFlag: bit;


    begin
    clk <= clock;
    res <= reset;

    rr1 <= imOut(9 downto 5);
    with reg2loc select 
        rr2 <= imOut(20 downto 16) when '0',
               imOut(4 downto 0) when '1';
    wr <= imOut(4 downto 0);

    SigExIn <= imOut;
    shiftOut <= SigExOut(61 downto 0) & "00";

    with pcsrc select 
        PCInput <= AluPCRes when '0',
                   Alu2Res when '1';

    with aluSrc select
        Alu1_in2 <= q2 when '0',
                    SigExOut when '1';

    with memToReg select 
        regData <= dmOut when '1',
                   Alu1Res when '0';
    

    regfile1: regfile port map(clk, res, regWrite, rr1, rr2, wr, regData, q1, q2);

    pc: reg port map(clk, res, '1', PCInput, PCOut);

    alu1: alu port map(q1, Alu1_in2, Alu1Res, aluCtrl, ZeroFlag, open, open);

    alu2: alu port map(PCOut, shiftOut, Alu2Res, "0010", open, open, open);

    alupc: alu port map(PCOut, x"0000000000000004", AluPcRes, "0010", open, open, open);

    signex: signExtend port map(SigExIn, SigExOut);

    opcode <= imOut(31 downto 21);
    zero <= ZeroFlag;
    imAddr <= PCOut;
    dmAddr <= Alu1Res;
    dmIn <= q2;

end architecture;