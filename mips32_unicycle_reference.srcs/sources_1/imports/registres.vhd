---------------------------------------------------------------------------------------------
--
--	Universit? de Sherbrooke 
--  Département de génie électrique et génie informatique
--
--	S4i - APP4 
--	
--
--	Auteur: 		Marc-Andr? Tétrault
--					Daniel Dalle
--					Sébastien Roy
-- 
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPS32_package.all;

entity BancRegistres is
    Port ( clk          : in  std_logic;
           reset        : in  std_logic;
           i_RS1        : in  std_logic_vector (4 downto 0);
           i_RS2        : in  std_logic_vector (4 downto 0);
           i_Wr_DAT     : in  std_logic_vector (31 downto 0);
           i_Wr_DATWIDE : in  std_logic_vector (127 downto 0);
           i_WDest      : in  std_logic_vector (4 downto 0);
           i_WE 	    : in  std_logic_vector (3 downto 0);
           o_RS1_DAT    : out std_logic_vector (31 downto 0);
           o_RS1_DATWIDE: out std_logic_vector (127 downto 0);
           o_RS2_DAT    : out std_logic_vector (31 downto 0);
           o_RS2_DATWIDE: out std_logic_vector (127 downto 0)
           );
end BancRegistres;

architecture comport of BancRegistres is
    signal regs: RAM(0 to 31) := (29 => X"100103FC", -- registre $SP
                                others => (others => '0'));
begin
    process( clk )
    begin
        if clk='1' and clk'event then
            if i_WE(0) = '1' and reset = '0' and i_WDest /= "00000" then
                regs( to_integer( unsigned(i_WDest))) <= i_Wr_DAT;
            end if;
            if i_WE(1) = '1' and reset = '0' and i_WDest /= "00000" then
                regs( to_integer( unsigned(i_WDest))) <= i_Wr_DATWIDE(63 downto 32) when to_integer(unsigned(i_WDest)) < 31;
            end if;
            if i_WE(2) = '1' and reset = '0' and i_WDest /= "00000" then
                regs( to_integer( unsigned(i_WDest))) <= i_Wr_DATWIDE(95 downto 64) when to_integer(unsigned(i_WDest)) < 30;
            end if;
            if i_WE(3) = '1' and reset = '0' and i_WDest /= "00000" then
                regs( to_integer( unsigned(i_WDest))) <= i_Wr_DATWIDE(127 downto 96) when to_integer(unsigned(i_WDest)) < 29;
            end if;
        end if;
    end process;
    
    o_RS1_DAT <= regs( to_integer(unsigned(i_RS1)));
    o_RS2_DAT <= regs( to_integer(unsigned(i_RS2)));
    
    o_RS1_DATWIDE(127 downto 96) <= regs( to_integer(unsigned(i_RS1)) + 3) when to_integer(unsigned(i_RS1)) < 29;
    o_RS1_DATWIDE(95 downto 64)  <= regs( to_integer(unsigned(i_RS1)) + 2) when to_integer(unsigned(i_RS1)) < 30;
    o_RS1_DATWIDE(63 downto 32)  <= regs( to_integer(unsigned(i_RS1)) + 1) when to_integer(unsigned(i_RS1)) < 31;
    o_RS1_DATWIDE(31 downto 0)   <= regs( to_integer(unsigned(i_RS1)) + 0);
     
    o_RS2_DATWIDE(127 downto 96) <= regs( to_integer(unsigned(i_RS2)) + 3) when to_integer(unsigned(i_RS2)) < 29;
    o_RS2_DATWIDE(95 downto 64)  <= regs( to_integer(unsigned(i_RS2)) + 2) when to_integer(unsigned(i_RS2)) < 30;
    o_RS2_DATWIDE(63 downto 32)  <= regs( to_integer(unsigned(i_RS2)) + 1) when to_integer(unsigned(i_RS2)) < 31;
    o_RS2_DATWIDE(31 downto 0)   <= regs( to_integer(unsigned(i_RS2)) + 0);
    
end comport;

