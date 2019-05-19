library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity intTo7Segm is
    generic (max : integer := 8;
             maxTiental: integer := 2);
    Port ( score1 : in integer range 0 to 20;
           score2 : in integer range 0 to 20;
           segm_clk : in std_logic;
           pulse100hz : in std_logic;
           AN : out std_logic_vector (7 downto 0);
           CA : out std_logic;
           CB : out std_logic;
           CC : out std_logic;
           CD : out std_logic;
           CE : out std_logic;
           CF : out std_logic;
           CG : out std_logic
           );
           
end intTo7Segm;

architecture Behavioral of intTo7Segm is
   signal display_cnt : integer range 0 to max-1 := 0;
   signal segm : std_logic_vector(6 downto 0);
   signal tientalScore1: integer range 0 to 11;
   signal eentalScore1: integer range 0 to 11;
   signal tientalScore2: integer range 0 to 11;
   signal eentalScore2: integer range 0 to 11;
   signal BCD: integer range 0 to 11;
   type tSegm is array(0 to 11) of std_logic_vector(6 downto 0);
   constant cSegm : tSegm := ("0000001", --0
                              "1001111", --1
                              "0010010", --2
                              "0000110", --3
                              "1001100", --4
                              "0100100", --5
                              "0100000", --6
                              "0001111", --7
                              "0000000", --8
                              "0000100", --9
                              "0110000",  --E
                              "1111111"   --GEEN OPLICHTING
                              );
begin 

p_display_teller: process
  begin
    wait until(rising_edge(segm_clk));
      if(pulse100hz = '1') then
        if (display_cnt = max) then
            display_cnt <= 0;
        else
            display_cnt <= display_cnt+1;
        end if;
      end if;
end process;

p_int_to_bcd: process(score1, score2)
  begin
    --Score1 omzetten naar tientallen en eenheden
    for I in 0 to maxTiental loop
      if (score1 - (I*10) < 10) then
        tientalScore1 <= I;
        eentalScore1 <= score1 - I*10;
      else
        tientalScore1 <= 11;
        eentalScore1 <= 11;
      end if;
      --Score1 omzetten naar tientallen en eenheden
      if (score2 - (I*10) < 10) then
        tientalScore2 <= I;
        eentalScore2 <= score2 - I*10;
      else
        tientalScore2 <= 11;
        eentalScore2 <= 11;
      end if;
    end loop;
end process;
  
p_show_display: process(BCD, display_cnt, eentalScore1, eentalScore2, tientalScore1, tientalScore2)
  begin
    if(display_cnt = 6) then
      AN <= "10111111";                          
      BCD <= 11;                   --Deze zal dus de display nergens laten oplichten (index 11 in array)
    elsif(display_cnt = 5) then
      AN <= "11011111";                          
      BCD <= tientalScore1;
    elsif(display_cnt = 4) then
      AN <= "11101111";                          
      BCD <= eentalScore1;            --Vierde display van links te tellen toont score 1
    elsif(display_cnt = 3) then
      AN <= "11110111";                          
      BCD <= 11;
    elsif(display_cnt = 2) then
      AN <= "11111011";                          
      BCD <= 11;
    elsif(display_cnt = 1) then
      AN <= "11111101";                          
      BCD <= tientalScore1;
    elsif(display_cnt = 0) then
      AN <= "11111110";
      BCD <= eentalScore2;            --Achtste display van links te tellen toont score 2
    else
      AN <= "01111111";    --meest linkse display laten zien                      
      BCD <= 11;
    end if;
end process p_show_display;

    segm <= cSegm(BCD); -- 7segment initialiseren
    CA <= segm(6);
    CB <= segm(5);
    CC <= segm(4);
    CD <= segm(3);
    CE <= segm(2);
    CF <= segm(1);
    CG <= segm(0);
end Behavioral;
