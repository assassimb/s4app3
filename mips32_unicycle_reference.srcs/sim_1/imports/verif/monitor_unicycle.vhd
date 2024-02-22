---------------------------------------------------------------------------------------------
--
--	Université de Sherbrooke 
--  Département de génie électrique et génie informatique
--
--	S4i - APP4 
--	
--
--	Auteurs: 		Marc-André Tétrault
--					Daniel Dalle
--					Sébastien Roy
-- 
---------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPS32_package.all;

library std;
use std.env.stop;


entity monitor_unicycle is
end monitor_unicycle;

architecture Behavioral of monitor_unicycle is

	signal show_alu_action			: alu_action_types;
	signal show_Instruction		: op_type;
	signal show_alu_unsupported	: std_logic;
	signal flag_syscall				: std_logic;
	signal end_program				: std_logic;
    
begin

	show_alu_unsupported	<= <<signal .mips_unicycle_tb.dut.inst_Datapath.inst_alu.s_unsupported : std_logic>>;
	show_alu_action 		<= f_DisplayAluAction(<<signal .mips_unicycle_tb.dut.inst_Datapath.inst_alu.i_alu_funct : std_logic_vector>>);


EncapsulerExtraction: block
    constant c_Registre_V0  : integer := 2;
    constant c_EndProgramCode : integer := 10;
    
	signal s_Instruction		: std_logic_vector (31 downto 0);
    signal regs                     : RAM(0 to 31);
begin
	regs                <= <<signal .mips_unicycle_tb.dut.inst_Datapath.inst_Registres.regs : RAM>>;
	s_Instruction		<= <<signal .mips_unicycle_tb.dut.inst_Datapath.s_Instruction : std_logic_vector>>;
	
	show_Instruction	<= f_DisplayOp(s_Instruction);

    flag_syscall <= '1' when show_Instruction = sim_OP_SYSCALL else '0';
    end_program  <= '1' when flag_syscall = '1' and unsigned(regs(c_Registre_V0)) = c_EndProgramCode else '0';
end block;
	
process
begin
    wait until end_program'event;
    if(end_program = '1') then
        wait for 20 ns;
        stop;
    end if;
end process;

end Behavioral;


