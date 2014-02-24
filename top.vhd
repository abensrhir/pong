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
-- Module Name:    top - RTL 
-- Project Name: 
-- Target Devices: 	   Xilinx Spartan Familly
-- Tool versions: 	   Xilinx ISE 12.1
-- Description: 
--		 Entité globale du systeme
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
use ieee.std_logic_1164.all; 
-----------*-------------------------------------------	
-- Declaration de l'Entité
-----------*-------------------------------------------
entity top is
   port (
      clk: in std_logic; 
      levier: in std_logic;
      btn: in std_logic_vector (3 downto 0);
      hsync, vsync: out  std_logic;
      rgb: out std_logic_vector(2 downto 0)
   );
end top;
-----------*-------------------------------------------	
-- Declaration de L'architecture
-----------*-------------------------------------------
architecture RTL of top is

   signal cclk25mhz : std_logic;
   signal pixel_x, pixel_y: std_logic_vector (9 downto 0);
   signal video_on, pixel_tick: std_logic;
   signal rgb1,rgb2 :std_logic_vector(2 downto 0);
-----------*-------------------------------------------	
-- Declaration du component Game_graphic_generation
-----------*-------------------------------------------
	component Game_graphic_generation is
			Port ( CLK25 : in  STD_LOGIC;
           btn : in  STD_LOGIC_VECTOR (3 downto 0);
           video_on : in  STD_LOGIC;
           pixel_x : in  STD_LOGIC_VECTOR (9 downto 0);
           pixel_y : in  STD_LOGIC_VECTOR (9 downto 0);
           graph_rgb : out  STD_LOGIC_VECTOR (2 downto 0));
   end component Game_graphic_generation;	
-----------*-------------------------------------------	
-- Declaration du component mux2
-----------*-------------------------------------------
	component mux2 is
    Port ( rgb1 : in  STD_LOGIC_VECTOR (2 downto 0);
           rgb2 : in  STD_LOGIC_VECTOR (2 downto 0);
           cond : in  STD_LOGIC;
           rgb : out  STD_LOGIC_VECTOR (2 downto 0));
	 end component mux2;
-----------*-------------------------------------------	
-- Declaration du component CLK25MHZ
-----------*-------------------------------------------	
	component CLK25MHZ is
    Port ( CLK50Mhz : in  STD_LOGIC;
           CLK25 : out  STD_LOGIC);
	end component;
-----------*-------------------------------------------	
-- Declaration du component VGA_SYNC
-----------*-------------------------------------------		
	component VGA_SYNC is
    Port ( CLK25 : in  STD_LOGIC;
           Video_on : out  STD_LOGIC;
           HSync : out  STD_LOGIC;
		   pixel_X: out STD_LOGIC_VECTOR(9 downto 0);
		   pixel_Y: out STD_LOGIC_VECTOR(9 downto 0);
           VSync : out  STD_LOGIC);
	end component;	 
-----------*-------------------------------------------	
-- Declaration du component Pong_text
-----------*-------------------------------------------	
   component  pong_text
   port(
      CLK25,video_on: in std_logic;
      pixel_x, pixel_y: in std_logic_vector(9 downto 0);
      text_rgb: out std_logic_vector(2 downto 0));
	end component;	
begin	   
   -- instantiatiation de CLK25MHZ
   clklent : CLK25MHZ port map (clk,cclk25mhz);
   -- instantiatiation de VGA sync
   vga_sync_unit: VGA_SYNC port map(cclk25mhz, video_on, hsync,pixel_x, pixel_y, vsync);
   -- instantiatiation de Game_graphic_generation
   Game_graphic_generation_unit: Game_graphic_generation port map (cclk25mhz, btn, video_on, pixel_x, pixel_y, rgb1);	 
   -- instantiatiation de logo_unit
   logo_unit : pong_text port map (cclk25mhz,video_on,pixel_x,pixel_y,rgb2);
   -- instantiatiation de mux2
   mux2_unit : mux2 port map(rgb1,rgb2,levier,rgb);
   
end RTL;