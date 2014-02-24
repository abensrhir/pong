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
-- Module Name:    Game_graphic_generation - RTL 
-- Project Name: 
-- Target Devices: 	   Xilinx Spartan Familly
-- Tool versions: 	   Xilinx ISE 12.1
-- Description: 
-- VGA_SYNC produit le signal hsync qui specifie le temps exige pour parcourir une ligne et le signal vsync qui 
-- spécifie le temps exigé pour parcourir l'écran entier. 
-- Ce travail est basé sur une résolution de 640-by-480 pixel avec une fréquence de 25 MHz 
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
-- Declaration de L'entitŽ
-----------*-------------------------------------------

entity VGA_SYNC is
    Port ( CLK25 : in  STD_LOGIC;
           Video_on : out  STD_LOGIC;
           HSync : out  STD_LOGIC;
	       pixel_X: out STD_LOGIC_VECTOR(9 downto 0);
           pixel_Y: out STD_LOGIC_VECTOR(9 downto 0);
           VSync : out  STD_LOGIC);
end VGA_SYNC;

-----------*-------------------------------------------	
-- Declaration de L'architecture
-----------*-------------------------------------------
architecture RTL of VGA_SYNC is

Signal on_off: STD_LOGIC;
signal H_count : STD_LOGIC_VECTOR(9 downto 0):=(others=>'0');
signal V_count : STD_LOGIC_VECTOR(9 downto 0):=(others=>'0');
Signal x: STD_LOGIC_VECTOR(9 downto 0);
Signal y: STD_LOGIC_VECTOR(9 downto 0);

begin
x <= H_count - 144; -- initialiser les coordonnées du pixel selon la norme VGA
y <= V_count - 31;  -- initialiser les coordonnées du pixel selon la norme VGA
pixel_X <= x;
pixel_Y <= y;
Video_on <= on_off; -- video on , video off
process(CLK25,H_count,V_count)
begin
	if rising_edge(clk25) then

		if x < 640 and y < 480 then
      			on_off <= '1'; -- Si on est dans la zone d'affichage alors on affiche
    		else
      			on_off <= '0'; -- sinon on n'affiche pas
    		end if;	

        	if H_count > 0 and H_count < 97 then
      			HSync <= '0'; -- Dans cette région, on met Hsync ˆ 0 pour recommencer un autre scan horizontale
    		else
      			HSync <= '1'; -- sinon Hsync reste ˆ 1 (en cours d'un scan horizontale) 
    		end if;
	
		if V_count > 0 and V_count < 3 then
      			VSync <= '0'; -- On met Vsync ˆ 0 pour recommencer le scan verticale et horizontale => pixel(0,0)
    		else
      			VSync <= '1'; -- Le scan verticale n'est pas encore terminé.
    		end if;

    		H_count <= H_count+1; -- incrémenter compteur horizontale 

    		if H_count = 800 then
      			V_count <= V_count+1; -- incrémenter compteur verticale => passer a la ligne suivante
      			H_count <= "0000000000"; -- initialiser compteur horizontale pour recommencer un scan horizontale a partir du pixel(V_count,0)
    		end if;

    		if V_count = 521 then		    
      			V_count <= "0000000000"; -- initialiser compteur verticale pour recommencer ds le pixel(0,0) 
    		end if;
	end if;
end process;
end RTL;

