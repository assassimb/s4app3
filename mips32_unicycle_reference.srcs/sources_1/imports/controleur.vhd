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

entity controleur is
Port (
    i_Op          	: in std_logic_vector(5 downto 0);
    i_funct_field 	: in std_logic_vector(5 downto 0);
    
    o_RegDst    	: out std_logic;
    o_Branch    	: out std_logic;
    o_MemtoReg  	: out std_logic;
    o_AluFunct  	: out std_logic_vector (3 downto 0);
    o_MemRead   	: out std_logic;
    o_MemWrite  	: out std_logic;
    o_ALUSrc    	: out std_logic;
    o_RegWrite  	: out std_logic;
	
	-- Sorties supp. vs 4.17
    o_Jump 			: out std_logic;
	o_jump_register : out std_logic;
	o_jump_link 	: out std_logic;
	o_alu_mult      : out std_logic;
	o_mflo          : out std_logic;
	o_mfhi          : out std_logic;
	o_SignExtend 	: out std_logic
    );
end controleur;

architecture Behavioral of controleur is

    signal s_R_funct_decode   : std_logic_vector(3 downto 0);

begin

    -- Contrôles pour les différents types d'instructions
    -- 
    process( i_Op, s_R_funct_decode )
    begin
        
        case i_Op is
			-- pour tous les types R
            when OP_Rtype => 
                o_AluFunct <= s_R_funct_decode;
			when OP_ADDI => 
				o_AluFunct <= ALU_ADD;
			when OP_ADDIU =>
				o_AluFunct <= ALU_ADD;
			when OP_ORI => 
				o_AluFunct <= ALU_OR;
			when OP_LUI => 
				o_AluFunct <= ALU_SLL16;
			when OP_BEQ => 
				o_AluFunct <= ALU_SUB;
			when OP_JAL =>
				o_AluFunct <= ALU_NULL;
			when OP_SW => 
				o_AluFunct <= ALU_ADD;
			when OP_LW => 
				o_AluFunct <= ALU_ADD;
            -- when OP_??? =>   -- autres cas?
			-- sinon
            when others =>
				o_AluFunct <= (others => '0');
        end case;
    end process; 
    
    -- Commande à l'ALU pour les instructions "R"
    process(i_funct_field)
    begin
        case i_funct_field is
            when ALUF_AND => 
                s_R_funct_decode <= ALU_AND;
            when ALUF_OR => 
                s_R_funct_decode <= ALU_OR;
            when ALUF_NOR =>
                s_R_funct_decode <= ALU_NOR;
            when ALUF_ADD => 
                s_R_funct_decode <= ALU_ADD;
            when ALUF_SUB => 
                s_R_funct_decode <= ALU_SUB;                
            when ALUF_SLL => 
                s_R_funct_decode <= ALU_SLL;  
            when ALUF_SRL => 
                s_R_funct_decode <= ALU_SRL; 
            when ALUF_ADDU => 
                s_R_funct_decode <= ALU_ADD;
            when ALUF_SLT => 
                s_R_funct_decode <= ALU_SLT; 
            when ALUF_SLTU => 
                s_R_funct_decode <= ALU_SLTU; 
            when ALUF_MULTU => 
                s_R_funct_decode <= ALU_MULTU; 
            when ALUF_MFHI => 
                s_R_funct_decode <= ALU_NULL; 
            when ALUF_MFLO => 
                s_R_funct_decode <= ALU_NULL; 
            -- à compléter au besoin avec d'autres instructions
            when others =>
                s_R_funct_decode <= ALU_NULL;
         end case;
     end process;
	
	
	o_RegWrite		<= '1' when i_Op = OP_Rtype or 
								i_Op = OP_ADDI or 
								i_Op = OP_ADDIU or 
								i_Op = OP_ORI or 
								i_Op = OP_LUI or 
								i_Op = OP_LW or 
								i_Op = OP_JAL
						else '0';
	
	o_RegDst 		<= '1' when i_Op = OP_Rtype else '0';
	
	o_ALUSrc 		<= '0' when i_Op = OP_Rtype or
								i_Op = OP_BEQ
						else '1';
	o_Branch 		<= '1' when i_Op = OP_BEQ   else '0';
	o_MemRead 		<= '1' when i_Op = OP_LW else '0';
	o_MemWrite 		<= '1' when i_Op = OP_SW else '0';
	o_MemtoReg 		<= '1' when i_Op = OP_LW else '0';
	o_SignExtend	<= '1' when i_OP = OP_ADDI or
	                           i_OP = OP_BEQ 
	                     else '0';
	
	
	o_Jump	 		<= '1' when i_Op = OP_J or 
	                            i_Op = OP_JAL 
						else '0';
				
				
	o_jump_link 	<= '1' when i_Op = OP_JAL else '0';
	o_jump_register <= '1' when i_Op = OP_Rtype and 
								i_funct_field = ALUF_JR 
						else '0';
	
	o_alu_mult      <= '1' when i_op = OP_Rtype and i_funct_field = ALUF_MULTU else '0';
	o_mflo          <= '1' when i_op = OP_Rtype and i_funct_field = ALUF_MFLO else '0';
	o_mfhi          <= '1' when i_op = OP_Rtype and i_funct_field = ALUF_MFHI else '0';

end Behavioral;
