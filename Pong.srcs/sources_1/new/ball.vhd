----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.05.2019 12:54:18
-- Design Name: 
-- Module Name: ball - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ball is
    Port ( v_sync : in std_logic;           --Tijdens v_sync (sync pulse) de positie van de ball opmeten tegenover het scherm en de volgende positie bepalen
           h_sync : in std_logic;
           reset : in std_logic;
           h_pos : in integer;
           v_pos : in integer;
           hva: in integer;
           vva : in integer;
           ball_on : out std_logic);        --Geeft terug of de ball op het scherm getoond moet worden
end ball;

architecture Behavioral of ball is
signal h_pos_ball: integer := hva/2;      --Bal laten beginnen in midden van scherm
signal v_pos_ball: integer := vva/2;
signal h_move_ball: integer := 4; --beweging van vier pixels horizontaal per frame
signal v_move_ball: integer := 4; --beweging van vier pixels verticaal per frame
constant ball_size: integer := 4;
begin

p_draw_ball: process(h_pos, v_pos, h_pos_ball, v_pos_ball)
begin
  if((h_pos_ball - ball_size <= h_pos) and (h_pos_ball + ball_size >= h_pos)
  and (v_pos_ball - ball_size <= v_pos) and (v_pos_ball + ball_size >= v_pos)) then      --Lange if statement om na te kijken of de v_pos en h_pos overlappen met de positie van de ball
    ball_on <= '1';   --ball moet getoond worden
  else
    ball_on <= '0';   --ball moet niet getoond worden
  end if;
end process;

p_move_v_ball: process(v_sync, reset)       --Verandert de verticale richting van de ball per frame (v_sync)
begin
  --v_sync
  if reset = '1' then
    --v_pos_ball <= vva/2;                
    v_move_ball <= 4;
  elsif(rising_edge(v_sync)) then
    if(v_pos_ball + ball_size >= vva) then
      v_move_ball <= -4;   --wordt in de omgekeerde richting (naar beneden) gestuurd
    elsif(v_pos_ball <= ball_size) then
      v_move_ball <= 4;    --wordt in de originele richting (naar boven) gestuurd    
    end if;
  end if;        
end process;

p_move_h_ball: process(h_sync, reset)      --Verandert de horizontale richting van de ball per frame (h_sync)
begin
  --h_sync  
  if reset = '1' then
    --h_pos_ball <= hva/2;                
    h_move_ball <= 4;
  elsif(rising_edge(h_sync)) then
    if(h_pos_ball + ball_size >= hva) then
      h_move_ball <= -4;   --wordt in de omgekeerde richting (naar links) gestuurd
    elsif(h_pos_ball <= ball_size) then
      h_move_ball <= 4;    --wordt in de originele richting (naar rechts) gestuurd    
    end if;
  end if;      
end process;

v_pos_ball <= v_pos_ball + v_move_ball;
h_pos_ball <= h_pos_ball + h_move_ball;
end Behavioral;
