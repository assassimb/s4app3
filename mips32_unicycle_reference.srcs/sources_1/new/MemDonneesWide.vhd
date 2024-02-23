----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/23/2024 02:20:03 PM
-- Design Name: 
-- Module Name: MemDonneesWide - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.MIPS32_package.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MemDonneesWide is
  Port (
      clk          : in std_logic;
      reset        : in std_logic;
      i_MemRead    : in std_logic;
      i_MemWrite   : in std_logic;
      i_Addresse   : in std_logic_vector(31 downto 0);
      i_WriteData  : in std_logic_vector(31 downto 0);
      o_ReadData   : out std_logic_vector(31 downto 0);
      
      i_MemReadWide         : in std_logic;
      i_MemWriteWide        : in std_logic;
      i_WriteDataWide       : in std_logic_vector(127 downto 0);
      o_ReadDataWide        : out std_logic_vector(127 downto 0)
);
end MemDonneesWide;

architecture Behavioral of MemDonneesWide is
    signal ram_DataMemory : RAM(0 to 255) := (
    ------------------------
-- Insérez vos donnees ici
------------------------

-- Test calculSurvivant + ACS
-- output: 4042
-- metrique + input
X"00000003",
X"00000002",
X"00000004",
X"00000003",
X"00000005",
X"00000004",
X"00000000",
X"00000003",
X"00000003",
X"00000002",
X"00000004",
X"00000003",
X"00000003",
X"00000002",
X"00000002",
X"00000005",

X"00000002",
X"00000004",
X"00000000",
X"00000004",

------------------------
-- Fin de votre code
------------------------
    others => X"00000000");
    
    signal s_MemoryIndex    : integer range 0 to 255;
    signal s_MemoryRangeValid : std_logic;
    
    signal s_WideMemoryRangeValid : std_logic;
begin

    s_MemoryIndex   <= to_integer(unsigned(i_Addresse(9 downto 2)));
    s_MemoryRangeValid <= '1' when i_Addresse(31 downto 10) = (X"10010" & "00") else '0';
    
    s_WideMemoryRangeValid <= '1' when (i_Addresse(31 downto 10) = (X"10010" & "00") and i_Addresse(3 downto 2) = "00") else '0';
    
	process( clk )
    begin
        if clk='1' and clk'event then
            if i_MemWriteWide = '1' and reset = '0' and s_WideMemoryRangeValid = '1' then
				ram_DataMemory(s_MemoryIndex + 3) <= i_WriteDataWide(127 downto 96);
				ram_DataMemory(s_MemoryIndex + 2) <= i_WriteDataWide( 95 downto 64);
				ram_DataMemory(s_MemoryIndex + 1) <= i_WriteDataWide( 63 downto 32);
				ram_DataMemory(s_MemoryIndex + 0) <= i_WriteDataWide( 31 downto  0);
            elsif i_MemWrite = '1' and reset = '0' and s_MemoryRangeValid = '1' then
                ram_DataMemory(s_MemoryIndex) <= i_WriteData;
            end if;
        end if;
    end process;

    -- Valider que nous sommes dans le segment de mémoire, avec 256 addresses valides
    o_ReadData <= ram_DataMemory(s_MemoryIndex) when s_MemoryRangeValid = '1'
                    else (others => '0');
	
	-- valider le segment et l'alignement de l'adresse
	o_ReadDataWide <= ram_DataMemory(s_MemoryIndex + 3) & 
					  ram_DataMemory(s_MemoryIndex + 2) & 
					  ram_DataMemory(s_MemoryIndex + 1) & 
					  ram_DataMemory(s_MemoryIndex + 0)   when s_WideMemoryRangeValid = '1'
					else (others => '0');

end Behavioral;
