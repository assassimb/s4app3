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


entity mips_unicycle_tb is
end mips_unicycle_tb;

architecture Behavioral of mips_unicycle_tb is
	component mips_unicycle_top is
	Port ( 
		clk : in std_logic;
		reset : in std_logic;
		o_pc : out std_logic_vector (31 downto 0)
		);
	end component;
	
	component monitor_unicycle is
	end component;
	
    constant clk_cycle : time := 10 ns;
	
    signal clk : std_logic;
    signal reset : std_logic;
	
begin
		   
-- Signal de reset
process
begin
    reset <= '1';
    wait for clk_cycle * 1; -- 
    wait for clk_cycle / 5; -- optionnel: relâcher le reset juste après le front d'horloge
    reset <= '0';
    wait;
end process;

-- horloge
process
begin
    clk <= '1';
    loop
        wait for clk_cycle/2;
        clk <= not clk;
    end loop;
end process;

-- processeur
dut : mips_unicycle_top 
Port map ( 
	clk => clk,
	reset => reset,
	o_pc => open
	);

-- Monitor pour encapsuler l'espionage du processeur et ne pas confondre avec le code fonctionnel. 
-- connections virtuelles, pour banc de test seulement.
-- Cette instance DOIT être _après_ l'instance "dut" ("device under test", parfois appelé "unit under test").
inst_monitor: monitor_unicycle; 


end Behavioral;
