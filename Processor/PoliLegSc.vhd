library ieee;
use ieee.numeric_bit.all;

entity reg is
    generic (wordSize: natural := 64);
    port (
            clock: in bit;
            reset: in bit;
            load: in bit;
            d: in bit_vector(wordSize - 1 downto 0);
            q: out bit_vector(wordSize - 1 downto 0)
    );
end reg;

architecture reg of reg is
begin
rg: process (clock, reset)
    begin
        if reset = '1' then
            q <= (others => '0');
        elsif clock = '1' and clock'event then
            if load = '1' then
                q <= d;
            end if;
        end if;
end process;

end architecture;

---RegFile
library ieee;
use ieee.math_real.ceil;
use ieee.math_real.log2;
use ieee.numeric_bit.all;

entity regfile is
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
end regfile;

architecture regfile of regfile is
    type qArray is array (regn - 1 downto 0) of bit_vector (wordSize - 1 downto 0);
    signal qA: qArray;
    signal ld: bit_vector(regn - 1 downto 0);
    component reg is
        generic (wordSize: natural := wordSize);
        port (
            clock: in bit;
            reset: in bit;
            load: in bit;
            d: in bit_vector(wordSize - 1 downto 0);
            q: out bit_vector(wordSize - 1 downto 0)
        );
    end component reg;

    begin
        GEN_REG:
        for i in 0 to regn - 1 generate
            GEN_REG31:
                if i = (regn - 1) generate
                    regx : reg port map (clock, '1', ld(i), d, qA(i));
                end generate;
            GEN_REG2:
                if i /= (regn - 1) generate
                    regx: reg port map (clock, reset, ld(i), d, qA(i));
                end generate;
        end generate;

        p1: process (regWrite, wr)
            begin
                if regWrite = '1' then
                    ld <= (others => '0');
                    ld(to_integer(unsigned(wr))) <= '1';
                elsif regWrite = '0' then
                    ld <= (others => '0');
                end if;
                
        end process;

        q1 <= qA(to_integer(unsigned(rr1)));
        q2 <= qA(to_integer(unsigned(rr2)));
end architecture;

----Arithmetic Logic Unit
library IEEE;
use IEEE.numeric_bit.all;

entity fulladder is
    port (
        a, b, cin: in bit;
        s, cout: out bit
    );
end entity;

architecture behav_fulladder of fulladder is
signal sum: bit;
signal c: bit;
begin
    sum <= a xor b xor cin;
    c <= (cin and (a or b)) or (a and b);

    s <= sum;
    cout <= c;
end behav_fulladder;


library IEEE;
use IEEE.numeric_bit.all;

entity alu1bit is
    port (
        a, b, less, cin: in bit;
        result, cout, set, overflow: out bit;
        ainvert, binvert: in bit;
        operation: in bit_vector(1 downto 0)
    );
end entity;

architecture behav of alu1bit is

    component fulladder is
    port (
            a, b, cin: in bit;
            s, cout: out bit
        );
end component;

signal ai, bi, ci, co, sum, ov, res, ls: bit;

begin

ai <= a xor ainvert;
bi <= b xor binvert;
ci <= cin;

f1: fulladder port map (ai, bi, ci, sum, co);

cout <= co;
set <= sum;
ov <= co xor ci;

with operation select res <=
    (ai and bi) when "00",
    (ai or bi) when "01",
    sum when "10",
    b when "11"; 

result <= res;
overflow <= ov;
end behav;

library IEEE;
use IEEE.numeric_bit.all;

entity alu is 
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
    end entity alu;

architecture alu_arch of alu is
    component alu1bit is
        port (
        a, b, less, cin: in bit;
        result, cout, set, overflow: out bit;
        ainvert, binvert: in bit;
        operation: in bit_vector(1 downto 0)
        ); 
    end component; 

    signal carry_out, set, alu_output: bit_vector (size - 1 downto 0);
    signal overflow, less, ze: bit;
    signal op: bit_vector (3 downto 0);

    begin 

    GEN_ALU1BIT:
        for i in 0 to size - 1 generate
            GEN_First: if (i = 0) generate
                X: alu1bit port map (A(i), B(i), '0', op(2), 
                    alu_output(i), carry_out(i), set(i), open, op(3), op(2), op(1 downto 0));
            end generate;

            GEN_LAST: if (i = size - 1) generate
                X: alu1bit port map (A(i), B(i), '0', carry_out(i - 1), 
                    alu_output(i), carry_out(i), set(i), overflow, op(3), op(2), op(1 downto 0));
            end generate;

            GEN_ALU: if (i > 0 and i < size - 1) generate
                X: alu1bit port map (A(i), B(i), '0', carry_out(i - 1), 
                    alu_output(i), carry_out(i), set(i), open, op(3), op(2), op(1 downto 0));
            end generate;
    end generate;
        
    op <= S;
    less <= set(size - 1);
    Co <= carry_out(size - 1);
    Ov <= overflow;
    Z <= '1' when alu_output = (alu_output'range => '0') else
        '0';
    F <= alu_output;
end alu_arch;

---Alu Controler
library ieee;
use ieee.numeric_bit.all;

entity alucontrol is
    port (
        aluop: in bit_vector(1 downto 0);
        opcode: in bit_vector(10 downto 0);
        aluCtrl: out bit_vector(3 downto 0)
    );
end entity;

architecture behav of alucontrol is
    begin
        aluCtrl <= "0010" when (aluop = "00" or (aluop = "10" and
                                            opcode(9) =  '0' and opcode(3) = '1')) else
              "0000" when (aluop = "10" and opcode(8) = '0' and opcode(3) = '0') else
              "0111" when (aluop = "01") else
              "0110" when (aluop = "10" and opcode(9) = '1') else
              "0001" when (aluop = "10" and opcode(8) = '1');

end architecture;

--Control Unit

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

--Sign Extend

library ieee;
use ieee.numeric_bit.all;

entity signExtend is
    port (
        i: in bit_vector(31 downto 0); -- input
        o: out bit_vector(63 downto 0) -- output
    );
end signExtend;

architecture behav of signExtend is
    signal outp: bit_vector(63 downto 0);

    begin
        
        with i(31 downto 30) select
            o <= (63 downto 9 => i(20)) & i(20 downto 12) when "11",
                    (63 downto 19 => i(23)) & i(23 downto 5) when "10",
                    (63 downto 26 => i(25)) & i(25 downto 0) when "00",
                    (others => '0') when others;

end architecture;

---Datapath

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

    signal rr1, rr2, wr: bit_vector(4 downto 0);
    signal regData, q1, q2: bit_vector(63 downto 0);

    signal SigExOut, shiftOut: bit_vector(63 downto 0);

    signal Alu1Res, Alu1_in2, Alu2Res, AluPcRes: bit_vector(63 downto 0);

    signal PCOut, PCInput: bit_vector(63 downto 0);

    signal ZeroFlag: bit;

    begin

    rr1 <= imOut(9 downto 5);
    with reg2loc select 
        rr2 <= imOut(20 downto 16) when '0',
               imOut(4 downto 0) when '1';
    wr <= imOut(4 downto 0);

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
    

    regfile1: regfile port map(clock, reset, regWrite, rr1, rr2, wr, regData, q1, q2);

    pc: reg port map(clock, reset, '1', PCInput, PCOut);

    alu1: alu port map(q1, Alu1_in2, Alu1Res, aluCtrl, ZeroFlag, open, open);

    alu2: alu port map(PCOut, shiftOut, Alu2Res, "0010", open, open, open);

    alupc: alu port map(PCOut, x"0000000000000004", AluPcRes, "0010", open, open, open);

    signex: signExtend port map(imOut, SigExOut);

    opcode <= imOut(31 downto 21);
    zero <= ZeroFlag;
    imAddr <= PCOut;
    dmAddr <= Alu1Res;
    dmIn <= q2;

end architecture;

---Processor

library IEEE;
use ieee.numeric_bit.all;

entity polilegsc is
    port (
        clock, reset: in bit;
        -- Data Memory
        dmem_addr: out bit_vector(63 downto 0);
        dmem_dati: out bit_vector(63 downto 0);
        dmem_dato: in bit_vector(63 downto 0);
        dmem_we: out bit;
        -- Instruction Memory
        imem_addr: out bit_vector(63 downto 0);
        imem_data: in bit_vector(31 downto 0)
    );
end entity;

architecture processor of polilegsc is
    
    Component DataPath is
        port (
        --Common
        clock: in bit;
        reset: in bit;
        --From Control Unit
        reg2loc: in bit;
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
    end component;

    Component controlunit is 
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
    end component;

    Component alucontrol is
        port (
        aluop: in bit_vector(1 downto 0);
        opcode: in bit_vector(10 downto 0);
        aluCtrl: out bit_vector(3 downto 0)
    );
    end component;

    signal reg2loc, pcsrc, zero, ucb, b, mTr, memW, aluSrc, rw: bit;
    signal aluOp: bit_vector(1 downto 0);
    signal aluCtrl: bit_vector(3 downto 0);
    signal opcode: bit_vector(10 downto 0);
    begin

    dp: datapath port map (clock, reset, reg2loc, pcsrc, mTr, aluCtrl, 
                             aluSrc, rw, opcode, zero, imem_addr, imem_data, dmem_addr, dmem_dati, dmem_dato);

    cunit: controlunit port map (reg2Loc, ucb, b, open, mTr, aluOp, memW, aluSrc, rw, opcode);

    aluctu: alucontrol port map (aluOp, opcode, aluCtrl);

    pcsrc <= (zero AND b) or ucb; 

    dmem_we <= memW;

end architecture;