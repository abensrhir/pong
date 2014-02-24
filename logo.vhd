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
-- Module Name:    pong_text - RTL 
-- Project Name: 
-- Target Devices: 	   Xilinx Spartan Familly
-- Tool versions: 	   Xilinx ISE 12.1
-- Description: 
--		 Entité Pour la gestion d'affichage du Logo
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
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;  
-----------*-------------------------------------------	
-- Declaration de L'entité
-----------*-------------------------------------------
entity pong_text is
   port(
      CLK25,video_on: in std_logic;
      pixel_x, pixel_y: in std_logic_vector(9 downto 0);
      text_rgb: out std_logic_vector(2 downto 0)
   );
end pong_text;
-----------*-------------------------------------------	
-- Declaration de L'Architecture
-----------*-------------------------------------------
architecture arch of pong_text is
signal pix_x, pix_y: unsigned(9 downto 0);
signal ball: std_logic_vector(1 downto 0):="01";
signal rom_addr: std_logic_vector(10 downto 0);
signal char_addr, char_addr_l, char_addr_r: std_logic_vector(6 downto 0);
signal row_addr, row_addr_l,row_addr_r: std_logic_vector(3 downto 0);
signal bit_addr,  bit_addr_l,bit_addr_r: std_logic_vector(2 downto 0);
signal font_word: std_logic_vector(7 downto 0);
signal font_bit: std_logic;
signal  logo_on, rule_on: std_logic;
signal logo_rom_addr: unsigned(5 downto 0);	
-----------*-------------------------------------------	
-- Declaration  et instantiation de la Rom qui contient les addresses du logo ROM
-----------*-------------------------------------------
type logo_rom_type is array (0 to 63) of
       std_logic_vector (6 downto 0);
   -- caracteres pour le LOGO PONG
   constant logo_ROM: logo_rom_type :=
   (
      
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000",
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000",
      "0000000", -- 
      "0000000", -- 
      "0000000", -- 
      "0000000", -- 
      "0000000", -- 
      "0000000", -- 
      "0000000", -- 
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000",
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "0000000", --
      "1010000", -- P
      "1010010", -- R
      "1000101", -- E
      "1010011", -- S
      "1010011", -- S
      "0000000", -- 
      "0000000", -- 
      "0000000", -- 
      "0000000", --
      "1010011", --	  S
      "1010100", --	  T
      "1000001", --	  A
      "1010010", --	  R
      "1010100", --	  T
      "0000000", --
      "0000000" --
   );
begin
   pix_x <= unsigned(pixel_x);
   pix_y <= unsigned(pixel_y);
-----------*-------------------------------------------	
-- Instantiation de la ROM font 
-----------*-------------------------------------------
   font_unit: entity font_rom
      port map(CLK25=>CLK25, addr=>rom_addr, data=>font_word); 
	  
-----------*-------------------------------------------	
-- Signaux et traitement des pixels pour la zone du logo: PONG
-----------*-------------------------------------------
   logo_on <=
      '1' when pix_y(9 downto 7)=1 and
         (3<= pix_x(9 downto 6) and pix_x(9 downto 6)<=6) else
      '0';
   row_addr_l <= std_logic_vector(pix_y(6 downto 3));
   bit_addr_l <= std_logic_vector(pix_x(5 downto 3));
   with pix_x(8 downto 6) select
     char_addr_l <=
        "1010000" when "011", -- P x50
        "1001111" when "100", -- O x4f
        "1001110" when "101", -- N x4e
        "1000111" when others; --G x47
-----------*-------------------------------------------	
-- Signaux et traitement des pixels pour la zone : Press Start
-----------*-------------------------------------------
   rule_on <= '1' when pix_x(9 downto 7) = "010" and
                       pix_y(9 downto 6)=  "0100"  else
              '0';
   row_addr_r <= std_logic_vector(pix_y(3 downto 0));
   bit_addr_r <= std_logic_vector(pix_x(2 downto 0));
   logo_rom_addr <= pix_y(5 downto 4) & pix_x(6 downto 3);
   char_addr_r <= logo_ROM(to_integer(logo_rom_addr));
-----------*-------------------------------------------	
--Process Global pour gérer l'affichage de chaque composant dans les coordonnées attribués et calculés
-----------*-------------------------------------------	
   process(video_on,logo_on,rule_on,pix_x,pix_y,font_bit,
           char_addr_l,char_addr_r,
           row_addr_l,row_addr_r,bit_addr_l,bit_addr_r)
   begin
         text_rgb <= "000";  
	
	  if (video_on='0') then 
			text_rgb <= "000";

      elsif rule_on='1' then
         char_addr <= char_addr_r;
         row_addr <= row_addr_r;
         bit_addr <= bit_addr_r;
         if font_bit='1' then
            text_rgb <= "111";
         end if;
      elsif logo_on='1' then
         char_addr <= char_addr_l;
         row_addr <= row_addr_l;
         bit_addr <= bit_addr_l;
         if font_bit='1' then
            text_rgb <= "111";
         end if;
      end if;
   end process;
-----------*-------------------------------------------	
--Interface ROM
-----------*-------------------------------------------
   rom_addr <= char_addr & row_addr;
   font_bit <= font_word(to_integer(unsigned(not bit_addr)));
end arch;