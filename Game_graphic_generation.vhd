 --------------------------------------------------------------------------                                                                    
--  ,-----.,------.,--.  ,--.,--------.,------.   ,---.  ,--.   ,------.  --
-- '  .--./|  .---'|  ,'.|  |'--.  .--'|  .--. ' /  O  \ |  |   |  .---'  --
-- |  |    |  `--, |  |' '  |   |  |   |  '--'.'|  .-.  ||  |   |  `--,   --
-- '  '--'\|  `---.|  | `   |   |  |   |  |\  \ |  | |  ||  '--.|  `---.  --
--- `-----'`------'`--'  `--'   `--'   `--' '--'`--' `--'`-----'`------' ---
----------------------------------------------------------------------------                                                                    
---------------------------------------------------------------------------
-- Company: 		  Ecole Centrale PAris ( MS Embedded Systems )
-- Engineer: 		  Anass Bensrhir   ---   Marouane Benamor
-- 
-- Create Date:    01:58:31 10/21/2010 
-- Design Name:    Pong V1.0
-- Module Name:    Game_graphic_generation - RTL 
-- Project Name: 
-- Target Devices: 	   Xilinx Spartan Familly
-- Tool versions: 	   Xilinx ISE 12.1
-- Description: 
--		 Module de generation des graphiques du Jeu (2 barres et une balle) avec gestion des mouvements
-- Dependencies: 		Non
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
-- Declaration de L'entité
-----------*-------------------------------------------

entity Game_graphic_generation is
    Port ( CLK25 : in  STD_LOGIC;
           btn : in  STD_LOGIC_VECTOR (3 downto 0);	 -- 4 boutons de Direction
           video_on : in  STD_LOGIC;   -- Depuis Vga_sync
           pixel_x : in  STD_LOGIC_VECTOR (9 downto 0);
           pixel_y : in  STD_LOGIC_VECTOR (9 downto 0);
           graph_rgb : out  STD_LOGIC_VECTOR (2 downto 0));	-- Sortie RGB
end Game_graphic_generation;
-----------*-------------------------------------------	
-- Declaration de L'architecture
-----------*-------------------------------------------
architecture RTL of Game_graphic_generation is
-----------*-------------------------------------------	
-- Declaration des Constantes
-----------*-------------------------------------------	
-- Resolution du VGA 640 x 480 pixels
constant MAX_X: integer:=640;
constant MAX_Y: integer:=480;		   
-- Taille et coordonnées de la barre 1 ( 6 pixels en largeur et 72 en hauteur )
constant BAR_X_L: integer:=600;
constant BAR_X_R: integer:=606;	
constant BAR_Y_SIZE: integer:=72;	 
-- Vitesse de mouvement de la barre 1
constant BAR_V: integer:=6;			  
-- Taille et coordonnées de la barre 2 ( 6 pixels en largeur et 72 en hauteur ) 
constant BAR2_X_L: integer:=40;
constant BAR2_X_R: integer:=46;	   
constant BAR2_Y_SIZE: integer:=72;
-- Vitesse de mouvement de la barre 2 
constant BAR2_V: integer:=6;	
-- Taille de la balle
constant BALL_SIZE: integer:=8; 
-- Vitesses de mouvement de la balle , +3 et -3
constant BALL_V_P: std_logic_vector(9 downto 0):=conv_std_logic_vector(3,10);
constant BALL_V_N: std_logic_vector(9 downto 0):=std_logic_vector(to_signed(-3,10));	 
-- forme ronde de la balle stockée sur une ROM 8x8 bits
type rom_type is array (0 to 7) of std_logic_vector(0 to 7);
constant BALL_ROM : rom_type :=
(	"00111100",
	"01111110",
	"11111111",
	"11111111",
	"11111111",
	"11111111",
	"01111110",
	"00111100"
);
signal refr_tick : std_logic;
signal pixel_x_signal, pixel_y_signal: std_logic_vector(9 downto 0);
signal bar_y_t, bar_y_b: std_logic_vector(9 downto 0);
signal bar_y_reg, bar_y_next: std_logic_vector(9 downto 0);
signal bar2_y_t, bar2_y_b: std_logic_vector(9 downto 0);
signal bar2_y_reg, bar2_y_next: std_logic_vector(9 downto 0);
signal ball_x_l, ball_x_r: std_logic_vector(9 downto 0);
signal ball_y_t, ball_y_b: std_logic_vector(9 downto 0);
signal ball_x_reg, ball_x_next: std_logic_vector(9 downto 0);
signal ball_y_reg, ball_y_next: std_logic_vector(9 downto 0);
signal x_delta_reg, x_delta_next: std_logic_vector(9 downto 0);
signal y_delta_reg, y_delta_next: std_logic_vector(9 downto 0);


-- Signaux pour la gestion de la Ram qui enveloppe la forme de la balle
signal rom_addr, rom_col: std_logic_vector(2 downto 0);
signal rom_data: std_logic_vector(7 downto 0);
signal rom_bit :std_logic;	
-- Signaux pour la gestion de l'affichage des differents composants
signal wall_on, bar_on,bar2_on, sq_ball_on, rd_ball_on : std_logic;
signal wall_rgb, bar_rgb,bar2_rgb, ball_rgb : std_logic_vector(2 downto 0);
----------------------------------------------------------------  
Begin	  
pixel_x_signal <= pixel_x;
pixel_y_signal <= pixel_y; 	  
-- 60 Mhz Ballayage du VGA Complet
refr_tick <= '1' when (pixel_y_signal = 481) and (pixel_x_signal =0) else '0'; 
-----------*-------------------------------------------	
-- Process pour la gestion des coordonnées de chaque composant en fonction de l'horloge	 
-----------*-------------------------------------------	
Traitement_Clock:process(CLK25)
begin
	if (CLK25'event and CLK25='1') then
	bar_y_reg <= bar_y_next;  
	bar2_y_reg <= bar2_y_next;
	ball_x_reg <= ball_x_next;
	ball_y_reg <= ball_y_next;
	x_delta_reg <= x_delta_next;
	y_delta_reg <= y_delta_next;
	end if;
end process Traitement_Clock; 
---------------------------------------------------------------
-----------*-------------------------------------------	
-- Traitement Barre 2 signal de sortie (bar2_on)
-----------*-------------------------------------------	
-- Signaux Barre 2
----------------------------------------------------------------
bar2_y_t <= bar2_y_reg;
bar2_y_b <= bar2_y_t + BAR2_Y_SIZE -1;	

bar2_on <= '1' when (BAR2_X_L <= pixel_x_signal) and (pixel_x_signal <=BAR2_x_R) and 
						 (bar2_y_t <= pixel_y_signal) and (pixel_y_signal <= bar2_y_b) else
			 '0';
bar2_rgb <= "111"; 
----------------------------------------------------------------- 
-----------*-------------------------------------------	
--Process pour la gestion du mouvement de la barre 2 en fonction des boutons 2 et 3
-----------*-------------------------------------------	
mouvement_barre2:process(bar2_y_reg,bar2_y_b,bar2_y_t,refr_tick,btn)
begin
bar2_y_next <= bar2_y_reg;
	if refr_tick = '1' then 	 -- Condition sur le balayage complet 60 HZ
		if btn(3)='1' and bar2_y_b<(MAX_Y-1-BAR2_V) then
			bar2_y_next <= bar2_y_reg + BAR2_V;
		elsif btn(2)='1' and bar2_y_t > BAR2_V then
			bar2_y_next <= bar2_y_reg - BAR2_V;
		end if;
	end if;
end process mouvement_barre2; 
---------------------------------------------------------------
-----------*-------------------------------------------	
-- Traitement Barre 1 signal de sortie (bar1_on) similaire à Barre 2
-----------*-------------------------------------------			  
--Signaux Barre 1
----------------------------------------------------------------
bar_y_t <= bar_y_reg;
bar_y_b <= bar_y_t + BAR_Y_SIZE -1;	

bar_on <= '1' when (BAR_X_L <= pixel_x_signal) and (pixel_x_signal <=BAR_x_R) and 
						 (bar_y_t <= pixel_y_signal) and (pixel_y_signal <= bar_y_b) else
			 '0';
bar_rgb <= "111"; 
-----------*-------------------------------------------	
--Process pour la gestion du mouvement de la barre 1 en fonction des boutons 0 et 1
-----------*-------------------------------------------	
mouvement_barre1:process(bar_y_reg,bar_y_b,bar_y_t,refr_tick,btn)
begin
bar_y_next <= bar_y_reg;
	if refr_tick = '1' then 
		if btn(1)='1' and bar_y_b<(MAX_Y-1-BAR_V) then
			bar_y_next <= bar_y_reg + BAR_V;
		elsif btn(0)='1' and bar_y_t > BAR_V then
			bar_y_next <= bar_y_reg - BAR_V;
		end if;
	end if;
end process mouvement_barre1; 
-----------*-------------------------------------------	
-- Traitement Balle signal de sortie (rd_ball_on)
-----------*-------------------------------------------	
ball_x_l <= ball_x_reg;
ball_y_t <= ball_y_reg;
ball_x_r <= ball_x_l + BALL_SIZE - 1;
ball_y_b <= ball_y_t + BALL_SIZE - 1;
sq_ball_on <= '1' when (ball_x_l <= pixel_x_signal) and (pixel_x_signal <= ball_x_r) and
							  (ball_y_t <= pixel_y_signal) and (pixel_y_signal<=ball_y_b) else 
				  '0';
rom_addr <= pixel_y_signal(2 downto 0) - ball_y_t(2 downto 0);
rom_col <= pixel_x_signal(2 downto 0) - ball_x_l(2 downto 0);
rom_data <= BALL_ROM(CONV_INTEGER(rom_addr));
rom_bit <= rom_data(CONV_INTEGER(rom_col));
rd_ball_on <= '1' when (sq_ball_on='1') and (rom_bit='1')else '0';
ball_rgb <= "111";
ball_x_next <= ball_x_reg + x_delta_reg when refr_tick = '1' else ball_x_reg;
ball_y_next <= ball_y_reg + y_delta_reg when refr_tick = '1' else ball_y_reg;
-----------*-------------------------------------------	
--Process pour la gestion du mouvement et du choc de la balle entre les 2 barres et le contour de l'ecran
-----------*-------------------------------------------	
mouvement_Ball:process(x_delta_reg,y_delta_reg,ball_y_t,ball_x_l,ball_x_r,ball_y_t,ball_y_b,bar_y_t,bar_y_b)
begin
	x_delta_next <= x_delta_reg;
	y_delta_next <= y_delta_reg;
	if ball_y_t<1 then
		y_delta_next <= BALL_V_P;
	elsif ball_y_b > (MAX_Y -1) then 
		y_delta_next <= BALL_V_N;
	elsif(BAR_X_L <= ball_x_r) and (ball_x_r <= BAR_X_R) then 
		if (bar_y_t <= ball_y_b) and (ball_y_t <= bar_y_b) then
			x_delta_next <= BALL_V_N;
		end if;	 
	elsif(BAR2_X_L <= ball_x_r) and (ball_x_r <= BAR2_X_R) then 
		if (bar2_y_t <= ball_y_b) and (ball_y_t <= bar2_y_b) then
			x_delta_next <= BALL_V_P;
		end if;
	end if;
end process mouvement_Ball;  
-----------*-------------------------------------------	
--Process Global pour gérer l'affichage de chaque composant dans les coordonnées attribués et calculés
-----------*-------------------------------------------	
Glocal_process:process(video_on,wall_on,bar_on,rd_ball_on,wall_rgb,bar_rgb,ball_rgb)
begin
if (video_on='0') then 
	graph_rgb <= "000";

elsif bar2_on ='1' then
	    graph_rgb <=bar2_rgb;
	elsif bar_on ='1' then
		graph_rgb <=bar_rgb;
	elsif rd_ball_on ='1' then
		graph_rgb <=ball_rgb;
	else graph_rgb <= "000";
		
	end if;
end process Glocal_process; 
-----------------------------------------------------------------------
end architecture RTL;

