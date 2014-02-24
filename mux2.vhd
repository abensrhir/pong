 --------------------------------------------------------------------------                                                                    
-- ,-----.,------.,--.  ,--.,--------.,------.   ,---.  ,--.   ,------.  --
--'  .--./|  .---'|  ,'.|  |'--.  .--'|  .--. ' /  O  \ |  |   |  .---'  --
--|  |    |  `--, |  |' '  |   |  |   |  '--'.'|  .-.  ||  |   |  `--,   --
--'  '--'\|  `---.|  | `   |   |  |   |  |\  \ |  | |  ||  '--.|  `---.  --
---`-----'`------'`--'  `--'   `--'   `--' '--'`--' `--'`-----'`------' ---
---------------------------------------------------------------------------                                                                     
---------------------------------------------------------------------------
-- Company: 		  Ecole Centrale PAris ( MS Embedded Systems )
-- Engineer: 		  Anass Bensrhir   ---   Marouane Benamor
-- 
-- Create Date:    01:58:31 10/21/2010 
-- Design Name:    Pong V1.0
-- Module Name:    mux2 - RTL 
-- Project Name: 
-- Target Devices: 	   Xilinx Spartan Familly
-- Tool versions: 	   Xilinx ISE 12.1
-- Description: 
--		 RGB MUX
-- Dependencies: 		NoNE
--
-- Revision: 
-- Revision 0.01 - 
-- Additional Comments: 
--
----------------------------------------------------------------------------------	 
-----------*-------------------------------------------	
-- Declaration des Librairies
-----------*-------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-----------*-------------------------------------------	
-- Declaration de L'entité
-----------*-------------------------------------------
entity mux2 is
    Port ( rgb1 : in  STD_LOGIC_VECTOR (2 downto 0);
           rgb2 : in  STD_LOGIC_VECTOR (2 downto 0);
           cond : in  STD_LOGIC;
           rgb : out  STD_LOGIC_VECTOR (2 downto 0));
end mux2;
-----------*-------------------------------------------	
-- Declaration de L'architecture
-----------*-------------------------------------------
architecture RTL of mux2 is

begin
rgb<= rgb1 when cond='1' else	-- (rgb=rgb1 if Cond='1' else egb2)====>Mux2to1
	  rgb2;
end RTL;

