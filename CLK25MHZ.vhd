 --------------------------------------------------------------------------                                                                    
--  ,-----.,------.,--.  ,--.,--------.,------.   ,---.  ,--.   ,------.  --
-- '  .--./|  .---'|  ,'.|  |'--.  .--'|  .--. ' /  O  \ |  |   |  .---'  --
-- |  |    |  `--, |  |' '  |   |  |   |  '--'.'|  .-.  ||  |   |  `--,   --
-- '  '--'\|  `---.|  | `   |   |  |   |  |\  \ |  | |  ||  '--.|  `---.  --
--- `-----'`------'`--'  `--'   `--'   `--' '--'`--' `--'`-----'`------' ---
----------------------------------------------------------------------------                                                                    
---------------------------------------------------------------------------
-- Company: 		  Ecole Centrale PAris ( MS Embedded Systems )
-- Engineer: 		  Anass Bensrhir   ---   Marouane Ben amor
-- 
-- Create Date:    01:58:31 10/21/2010 
-- Design Name:    Pong V1.0
-- Module Name:    CLK25MHZ - RTL 
-- Project Name: 
-- Target Devices: 	   Xilinx Spartan Familly
-- Tool versions: 	   Xilinx ISE 12.1
-- Description: 
--		 Diviser l'horloge de 50 MHz pour générer l'horloge de 25 Mhz
-- Dependencies: 		
--
-- Revision: 
-- Revision 0.01 - 
-- Additional Comments: 
--
------------------------------------------------------------------------------ 
-----------*-------------------------------------------	
-- Declaration des Librairies
-----------*-------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
use ieee.numeric_std.all;
-----------*-------------------------------------------	
-- Declaration de L'entitÈ
-----------*-------------------------------------------

entity CLK25MHZ is
    Port ( CLK50Mhz : in  STD_LOGIC;
           CLK25 : out  STD_LOGIC);
end CLK25MHZ;

-----------*-------------------------------------------	
-- Declaration de L'architecture
-----------*-------------------------------------------
architecture Behavioral of CLK25MHZ is

Signal CLKlent : STD_LOGIC :='0';

begin

CLK25 <= CLKlent;
process(CLK50Mhz)
variable i:integer range 0 to 1:=0;
begin
	if (CLK50Mhz'event and CLK50Mhz='1') then
		if (i=1) then CLKlent<= not(CLK50Mhz);i:=0;
		else CLKlent <= CLK50Mhz;
		i:=i+1;
		end if;	
	end if;
end process;

end Behavioral;

