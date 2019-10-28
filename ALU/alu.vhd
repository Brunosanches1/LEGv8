library IEEE;
use IEEE.numeric_bit.all;

entity alu is 
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
                X: alu1bit port map (A(i), B(i), less, op(2), 
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
    less <= set(size - 1) and not ze;
    ze <= '1' when set = (set'range => '0') else
         '0';

    Co <= carry_out(size - 1);
    Ov <= overflow;
    Z <= '1' when alu_output = (alu_output'range => '0') else
        '0';
    F <= alu_output;
end alu_arch;
