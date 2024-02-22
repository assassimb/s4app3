---------------------------------------------------------------------------------------------
--
--	Université de Sherbrooke 
--  Département de génie électrique et génie informatique
--
--	S4i - APP4 
--	
--
--	Auteur: 		Marc-André Tétrault
--					Daniel Dalle
--					Sébastien Roy
-- 
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPS32_package.all;

entity alu is
Port ( 
	i_a          : in std_logic_vector (31 downto 0);
	i_b          : in std_logic_vector (31 downto 0);
	i_alu_funct  : in std_logic_vector (3 downto 0);
	i_shamt      : in std_logic_vector (4 downto 0);
	o_result     : out std_logic_vector (31 downto 0);
	o_multRes    : out std_logic_vector (63 downto 0);
	o_zero       : out std_logic
	);
end alu;

architecture comport of alu is
    
    signal decale 			: unsigned( 4 downto 0);
    signal s_result 		: std_logic_vector (31 downto 0);
    signal s_multRes 		: std_logic_vector (63 downto 0);
    signal s_unsupported    : std_logic;
	
begin
    -- conversion de type
    decale <= unsigned(i_shamt);
    
    -- decodage et exécution de l'opération
    process(i_alu_funct, i_a, i_b, decale)
    begin
        s_unsupported <= '0';
        case i_alu_funct is
            when ALU_AND => 
                s_result <= i_a and i_b;
            when ALU_OR => 
                s_result <= i_a or i_b;
            when ALU_NOR => 
                s_result <= i_a nor i_b;
            when ALU_ADD => 
                s_result <= std_logic_vector(signed(i_a) + signed(i_b));
            when ALU_SUB => 
                s_result <= std_logic_vector(signed(i_a) - signed(i_b));
            when ALU_SLL => 
                s_result <= std_logic_vector(signed(i_b) sll to_integer( decale ));  
            when ALU_SRL => 
                s_result <= std_logic_vector(signed(i_b) srl to_integer( decale )); 
			when ALU_SLL16 =>
				s_result <= std_logic_vector(signed(i_b) sll 16 ); 
            when ALU_SLT => 
                if(signed(i_a) < signed(i_b)) then
                    s_result <= X"00000001";      
                else
                    s_result <= X"00000000";
                end if;
            when ALU_SLTU => 
                if(unsigned(i_a) < unsigned(i_b)) then
                    s_result <= X"00000001";      
                else
                    s_result <= X"00000000";
                end if;
            when ALU_MULTU =>
                s_multRes <= std_logic_vector(unsigned(i_a) * unsigned(i_b));
            when ALU_NULL => 
				s_result <= (others => '0');
            when others =>
                s_result <= i_a and i_b;
                s_unsupported <= '1';
         end case;
     end process;
     
     -- sorties spéciales, utiles pour certaines instructions
     o_zero <= '1' when (signed(s_result) = 0) else '0';
	 o_result <= s_result;
	 o_multRes <= s_multRes;
            
end comport;
