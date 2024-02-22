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

package MIPS32_package is
    -- codes d'opération internes de l'ALU
    -- Nous définissons ces codes et on aurait pu adopter un autre encodage
    constant ALU_AND  : std_logic_vector( 3 downto 0 ) := "0000";
    constant ALU_OR   : std_logic_vector( 3 downto 0 ) := "0001";
    constant ALU_ADD  : std_logic_vector( 3 downto 0 ) := "0010";
    constant ALU_SLTU : std_logic_vector( 3 downto 0 ) := "0011";
    constant ALU_SUB  : std_logic_vector( 3 downto 0 ) := "0110";
    constant ALU_SLT  : std_logic_vector( 3 downto 0 ) := "0111";
    
    constant ALU_XOR  : std_logic_vector( 3 downto 0 ) := "1000";
    constant ALU_NOR  : std_logic_vector( 3 downto 0 ) := "1001";
    constant ALU_SLL  : std_logic_vector( 3 downto 0 ) := "1010";
    constant ALU_SRL  : std_logic_vector( 3 downto 0 ) := "1011";
    constant ALU_SRA  : std_logic_vector( 3 downto 0 ) := "1100";
    constant ALU_MULTU: std_logic_vector( 3 downto 0 ) := "1101";
    constant ALU_SLL16: std_logic_vector( 3 downto 0 ) := "1110";
    constant ALU_NULL : std_logic_vector( 3 downto 0 ) := "1111";
    
    -- codes du champ function des instructions de type R
    -- Ces codes sont définis par l'encodage des instructions MIPS
    -- voir entre autres p. 301 COD édition 5
    constant ALUF_SLL       : std_logic_vector( 5 downto 0 ) := "000000";
    constant ALUF_SRL       : std_logic_vector( 5 downto 0 ) := "000010";
    constant ALUF_SRA       : std_logic_vector( 5 downto 0 ) := "000110";
    constant ALUF_JR        : std_logic_vector( 5 downto 0 ) := "001000";
    constant ALUF_MFHI      : std_logic_vector( 5 downto 0 ) := "010000";
    constant ALUF_MFLO      : std_logic_vector( 5 downto 0 ) := "010010";
    constant ALUF_MULTU     : std_logic_vector( 5 downto 0 ) := "011001";
    constant ALUF_ADD       : std_logic_vector( 5 downto 0 ) := "100000";
    constant ALUF_ADDU      : std_logic_vector( 5 downto 0 ) := "100001";
    constant ALUF_SUB       : std_logic_vector( 5 downto 0 ) := "100010";
    constant ALUF_AND       : std_logic_vector( 5 downto 0 ) := "100100";
    constant ALUF_OR        : std_logic_vector( 5 downto 0 ) := "100101";
    constant ALUF_XOR       : std_logic_vector( 5 downto 0 ) := "100110";
    constant ALUF_NOR       : std_logic_vector( 5 downto 0 ) := "100111";
    constant ALUF_SLT       : std_logic_vector( 5 downto 0 ) := "101010";
    constant ALUF_SLTU      : std_logic_vector( 5 downto 0 ) := "101011";
    constant ALUF_SYSCALL	: std_logic_vector( 5 downto 0 ) := "001100";
    
    -- opcodes dans le décodage d'instructions
    constant OP_Rtype : std_logic_vector( 5 downto 0 ) := "000000";
    constant OP_J     : std_logic_vector( 5 downto 0 ) := "000010";
    constant OP_JAL   : std_logic_vector( 5 downto 0 ) := "000011";
    constant OP_BEQ   : std_logic_vector( 5 downto 0 ) := "000100";
    constant OP_ADDI  : std_logic_vector( 5 downto 0 ) := "001000";
    constant OP_ADDIU : std_logic_vector( 5 downto 0 ) := "001001";
    constant OP_ORI   : std_logic_vector( 5 downto 0 ) := "001101";
    constant OP_LUI   : std_logic_vector( 5 downto 0 ) := "001111";
    constant OP_LW    : std_logic_vector( 5 downto 0 ) := "100011";
    constant OP_SW    : std_logic_vector( 5 downto 0 ) := "101011";
	
	
	constant c_Mips32_Nop	 	: std_logic_vector(31 downto 0) := X"00000000";
	-- equivalent au c_Mips32_Nop, mais permet de mieux visualiser dans vivado
	constant c_Mips32_Flush	: std_logic_vector(31 downto 0) := X"00000001";
    
    type RAM is array (natural range <>) of std_logic_vector (31 downto 0);
						
	
    type op_type is (
		sim_OP_NOP,
		sim_OP_FLUSH,
		sim_OP_BULLE,
		sim_OP_STALL, -- for cache, similar to bubble
        sim_OP_AND,
        sim_OP_OR,
		sim_OP_NOR,
        sim_OP_ADD,
		sim_OP_ADDU,
        sim_OP_SUB,
        sim_OP_SLL,
        sim_OP_SRL,
        sim_OP_SLT,
        sim_OP_SLTU,
        sim_OP_MULTU,
        sim_OP_MFHI,
        sim_OP_MFLO,
        sim_OP_J,
        sim_OP_JAL,
        sim_OP_JR,
        sim_OP_BEQ,
        sim_OP_ADDI,
        sim_OP_ADDIU,
        sim_OP_ORI,
        sim_OP_LUI,
		sim_OP_LW,
		sim_OP_SW,
		sim_OP_SYSCALL,
        sim_OP_Undefined
    );
    function f_DisplayOp(InstructionDebug : std_logic_vector( 31 downto 0 )
                        ) return op_type;
						
	
	type alu_action_types is (
        sim_alu_AND,
        sim_alu_OR,
        sim_alu_NOR,
        sim_alu_ADD,
        sim_alu_SUB,
        sim_alu_SLL,
        sim_alu_SRL,
        sim_alu_SLL16,
        sim_alu_SLT,
        sim_alu_SLTU,
        sim_alu_MULTU,
        sim_alu_NULL,
        sim_alu_Undefined
    );
	function f_DisplayAluAction(alu_funct : std_logic_vector( 3 downto 0 )
                        ) return alu_action_types;			


end package MIPS32_package;

package body MIPS32_package is
	

function f_DisplayOp(InstructionDebug : std_logic_vector( 31 downto 0 )
                        ) return op_type is 
	variable CurrentOp : op_type;
	variable OperatorField  : std_logic_vector( 5 downto 0 );
	variable FunctField  : std_logic_vector( 5 downto 0 );
	
begin

	OperatorField	:= InstructionDebug(31 downto 26);
	FunctField		:= InstructionDebug(5 downto 0);
	
	if(InstructionDebug = c_Mips32_Nop) then
		return sim_OP_NOP;
	end if;
	if(InstructionDebug = c_Mips32_Flush) then
		return sim_OP_FLUSH;
	end if;
	
	case OperatorField is
        when OP_Rtype =>
			case FunctField is 
				when ALUF_AND =>
					CurrentOp := sim_OP_AND;
				when ALUF_OR =>
					CurrentOp := sim_OP_OR;
				when ALUF_NOR =>
					CurrentOp := sim_OP_NOR;
				when ALUF_ADD =>
					CurrentOp := sim_OP_ADD;
				when ALUF_ADDU =>
					CurrentOp := sim_OP_ADDU;
				when ALUF_SUB =>
					CurrentOp := sim_OP_SUB;
				when ALUF_SLL =>
					CurrentOp := sim_OP_SLL;
				when ALUF_SRL =>
					CurrentOp := sim_OP_SRL;
				when ALUF_SLT =>
					CurrentOp := sim_OP_SLT;
				when ALUF_SLTU =>
					CurrentOp := sim_OP_SLTU;
				when ALUF_JR =>
					CurrentOp := sim_OP_JR;
				when ALUF_MULTU =>
				    CurrentOp := sim_OP_MULTU;
				when ALUF_MFHI =>
				    CurrentOp := sim_OP_MFHI;
				when ALUF_MFLO =>
				    CurrentOp := sim_OP_MFLO;
				when ALUF_SYSCALL =>
					CurrentOp := sim_OP_SYSCALL;
				when others =>
					CurrentOp := sim_OP_Undefined;
			end case;
        when OP_J =>
			CurrentOp := sim_OP_J;
        when OP_JAL =>
			CurrentOp := sim_OP_JAL;
        when OP_BEQ =>
			CurrentOp := sim_OP_BEQ;
        when OP_ADDI =>
			CurrentOp := sim_OP_ADDI;
        when OP_ADDIU =>
			CurrentOp := sim_OP_ADDIU;
        when OP_LUI =>
			CurrentOp := sim_OP_LUI;
        when OP_ORI =>
			CurrentOp := sim_OP_ORI;
		when OP_LW =>
			CurrentOp := sim_OP_LW;
		when OP_SW =>
			CurrentOp := sim_OP_SW;
		when others =>
			CurrentOp := sim_OP_Undefined;
	end case;
	
	return CurrentOp;
end function;


function f_DisplayAluAction(alu_funct : std_logic_vector( 3 downto 0 )
                        ) return alu_action_types is 
	variable CurrentAction : alu_action_types;	
begin

        
	case alu_funct is
		when ALU_AND =>
			CurrentAction := sim_alu_AND;
		when ALU_OR =>
			CurrentAction := sim_alu_OR;
		when ALU_NOR =>
			CurrentAction := sim_alu_NOR;
		when ALU_ADD =>
			CurrentAction := sim_alu_ADD;
		when ALU_SUB =>
			CurrentAction := sim_alu_SUB;
		when ALU_SLL =>
			CurrentAction := sim_alu_SLL;
		when ALU_SRL =>
			CurrentAction := sim_alu_SRL;
		when ALU_SLL16 =>
			CurrentAction := sim_alu_SLL16;
		when ALU_SLT =>
			CurrentAction := sim_alu_SLT;
		when ALU_SLTU =>
			CurrentAction := sim_alu_SLTU;
		when ALU_MULTU =>
			CurrentAction := sim_alu_MULTU;
		when ALU_NULL =>
			CurrentAction := sim_alu_NULL;
		when others =>
			CurrentAction := sim_alu_Undefined;
	end case;
	
	return CurrentAction;
end function;

end package body MIPS32_package;