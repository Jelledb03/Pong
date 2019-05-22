library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VGA is
    Port (
        vga_clk : in std_logic; 
        hva: in integer;
        hfp: in integer;
        hsp: in integer;
        hbp: in integer;            -- alle timings komen binnen
        vva: in integer;
        vfp: in integer;
        vsp: in integer;
        vbp: in integer;
        h_pos: in integer;          -- posities komen binnen
        v_pos: in integer;
        new_frame: in std_logic;
        BTNU,BTNL, BTNR, BTND: in std_logic;
        VGA_R, VGA_G, VGA_B: out std_logic_vector(3 downto 0);
        VGA_HS, VGA_VS, v_sync, h_sync: out std_logic;
        score_pad1 : out integer range 0 to 9 := 0;
        score_pad2 : out integer range 0 to 9 := 0
    );
end VGA;

architecture Behavioral of VGA is

--Scherm signalen
constant h_pos_mid : integer := hva/2; -- Geeft midden van veld terug (bij 640 => 320)
constant border_size: integer := 5;

--bal signalen
signal h_pos_ball: integer := hva/2;      --Bal laten beginnen in midden van scherm
signal v_pos_ball: integer := vva/2;
signal ball_on : std_logic;
constant ball_size: integer := 4;

--Movement
constant ball_speed: integer := 3;
signal ball_up: std_logic := '1'; --Laat de bal starten om naar rechts boven te gaan
signal ball_left: std_logic := '0';


--pad signalen
--mogen de horizontale posities constant zijn? Want die veranderen nooit
constant pad_width: integer := 10;
constant pad_length: integer := 50;
constant pad_speed: integer := 5;
signal h_leftPos_pad1: integer := 10; --Linkse positie van eerste pad (is de linkse)
signal v_topPos_pad1: integer := 200;     --Denk nog pad length of pad length /2 bij optellen om in het midden te komen
signal h_leftPos_pad2: integer := 639 - border_size - pad_width - 5; --Rechtse positie van tweede pad (is de rechtse) 
signal v_topPos_pad2: integer := 200;
signal pad1_on : std_logic;
signal pad2_on : std_logic;

--score signalen
signal score1 : integer range 0 to 20 := 0;
signal score2 : integer range 0 to 20 := 0;

begin

--Zet ball_on op 1 wanneer ball getekend moet worden
p_draw_ball: process(h_pos, v_pos, h_pos_ball, v_pos_ball)
begin
  if((h_pos_ball - ball_size <= h_pos) and (h_pos_ball + ball_size >= h_pos)
  and (v_pos_ball - ball_size <= v_pos) and (v_pos_ball + ball_size >= v_pos)) then      --Lange if statement om na te kijken of de v_pos en h_pos overlappen met de positie van de ball
    ball_on <= '1';   --ball moet getoond worden
  else
    ball_on <= '0';   --ball moet niet getoond worden
  end if;
end process;

--Zet pad1_on op 1 wanneer de pads getekend moeten worden
p_draw_pad1: process(h_pos, v_pos, h_leftPos_pad1, v_topPos_pad1)
begin
    if((h_leftPos_pad1 <= h_pos) and (h_leftPos_pad1 + pad_width >= h_pos)                  --Werken met links en top positie
    and (v_topPos_pad1 <= v_pos) and (v_topPos_pad1 + pad_length >= v_pos)) then
        pad1_on <= '1';   --ball moet getoond worden
  else
        pad1_on <= '0';   --ball moet niet getoond worden
  end if;
end process;

--Zet pad2_on op 1 wanneer de pads getekend moeten worden
p_draw_pad2: process(h_pos, v_pos, h_leftPos_pad2, v_topPos_pad2)
begin
    if((h_leftPos_pad2 <= h_pos) and (h_leftPos_pad2 + pad_width >= h_pos)                  --Werken met rechts en top positie
      and (v_topPos_pad2 <= v_pos) and (v_topPos_pad2 + pad_length >= v_pos)) then
        pad2_on <= '1';   --ball moet getoond worden
    else
        pad2_on <= '0';   --ball moet niet getoond worden
    end if;
end process;

p_sync: process(h_pos, v_pos, hva, hfp, hsp, vva, vfp, vsp)  --Zet sync bit stream juist (0 bij sync pulse)
begin
    if (h_pos >= (hva + hfp)) and h_pos < (hva + hfp + hsp) then
        VGA_HS <= '0';  -- VGA_HS is zero tijdens de sync pulse (sync pulse is na front porch tot back porch)
        h_sync <= '0';  -- Nodig voor moving objects up te daten
    else
        VGA_HS <= '1';
        h_sync <= '1';
    end if;
    if (v_pos >= (vva + vfp)) and v_pos < (vva + vfp + vsp) then
        VGA_VS <= '0';  -- VGA_VS is zero tijdens de sync pulse (sync pulse is na front porch tot back porch)
        v_sync <= '0';
    else
        VGA_VS <= '1';
        v_sync <= '1';
    end if;
end process;

--Dit zou voldoende moeten zijn om de bal rond het speelveld te laten botsen en een punt aan te rekenen wanneer deze de linker of recht rand aanraakt
--Ook het botsen met de paddles zou geimplementeerd moeten zijn
p_update_ball: process       --Verandert de verticale richting van de ball per frame (new_frame = '1')
begin
  wait until(rising_edge(vga_clk));
    if(new_frame = '1') then
        --Kijken of ball boven of onder raakt
        if((v_pos_ball <= ball_size + border_size) and ball_up = '1') then
            ball_up <= '0';
            ball_left <= ball_left;
        elsif((v_pos_ball + ball_size >= vva - border_size) and ball_up = '0') then
            ball_up <= '1';
        end if;
        --Kijken of hij links of rechts de rand raakt + punten geven
        if((h_pos_ball <= ball_size + border_size) and ball_left = '1') then   --Punt gescoord door speler2
          if(score2 >= 9) then
            score2 <= 0;
            score1 <= 0;
          else
            score2 <= score2 + 1;
          end if;
          ball_left <= '0';  --Nog aanpassen om terug op start positie te zetten
          
        elsif((h_pos_ball + ball_size >= hva - border_size) and ball_left = '0') then  --Punt gescoord door speler1
          if(score1 >= 9) then
            score2 <= 0;
            score1 <= 0;
          else
            score1 <= score1 + 1;
          end if;
            ball_left <= '1';
        end if;
        
        --update score_pads hier (zijn de output signalen voor score)
          score_pad1 <= score1;
          score_pad2 <= score2;
          
        --Hier eerst nog code schrijven voor het detecteren van pad_on + ball_on?
        if((h_pos_ball + ball_size = h_leftPos_pad2) and (v_pos_ball - ball_size <= v_topPos_pad2 + pad_length) and (v_pos_ball + ball_size >= v_topPos_pad2) and ball_left = '0') then
            ball_left <= '1';
        elsif((h_pos_ball - ball_size = h_leftPos_pad1 + pad_width) and (v_pos_ball - ball_size <= v_topPos_pad1 + pad_length) and (v_pos_ball + ball_size >= v_topPos_pad1) and ball_left = '1') then
            ball_left <= '0';
        end if;
    end if;
end process;

p_move_ball: process
begin
  wait until(rising_edge(vga_clk));
  if(new_frame = '1') then
    --update de movement van de ball: eerst verticaal, dan horizontaal
    --Hierin nog beide kanten vergelijken en ball resetten 
    if(ball_up = '1') then
      v_pos_ball <= v_pos_ball - ball_speed; --gaat naar boven
    else
      v_pos_ball <= v_pos_ball + ball_speed; --gaat naar beneden
    end if;
    if(ball_left = '1') then
      h_pos_ball <= h_pos_ball - ball_speed; --gaat naar links
    else
      h_pos_ball <= h_pos_ball + ball_speed; --gaat naar rechts
    end if;
  end if;
end process;

p_move_pad1: process       --Verandert de positie van pad1
begin
  wait until(rising_edge(vga_clk) and new_frame = '1');
    if(BTNU = '1' and (v_topPos_pad1 > border_size)) then       --Kijkt ook na of hij tegen de top van het veld zit
      v_topPos_pad1 <= v_topPos_pad1 - pad_speed;
    elsif(BTNL = '1' and (v_topPos_pad1 + pad_length < vva - border_size - 1)) then        --Kijkt ook na of hij tegen de onderkant van het veld zit
      v_topPos_pad1 <= v_topPos_pad1 + pad_speed;
    else
      v_topPos_pad1 <= v_topPos_pad1;  --Verandert er niet
    end if;
end process;

p_move_pad2: process       --Verandert de positie van pad2
begin
  wait until(rising_edge(vga_clk) and new_frame = '1');
    if(BTNR = '1' and (v_topPos_pad2 > border_size)) then       --Kijkt ook na of hij tegen de top van het veld zit
      v_topPos_pad2 <= v_topPos_pad2 - pad_speed;
    elsif(BTND = '1' and (v_topPos_pad2 + pad_length < vva - border_size - 1)) then        --Kijkt ook na of hij tegen de onderkant van het veld zit
      v_topPos_pad2 <= v_topPos_pad2 + pad_speed;
    else
      v_topPos_pad2 <= v_topPos_pad2;  --Verandert er niet
    end if;
end process;

p_kleur: process(h_pos, v_pos, hva, vva, ball_on, pad1_on, pad2_on)  --Kleurt het scherm tijdens visible area (Constanten niet in sensitivity list)
begin                   
    if (h_pos >= hva or v_pos >= vva) then
        VGA_R <= "0000"; 
        VGA_G <= "0000";  --Voorbij Visible Area (In front porch, sync pulse of back porch)
        VGA_B <= "0000";
    elsif(ball_on = '1') then
        VGA_R <= "0000"; 
        VGA_G <= "0000";  --Kleurt blauw balletje op scherm
        VGA_B <= "1111";
    elsif(pad1_on = '1' or pad2_on = '1') then
        VGA_R <= "0000"; 
        VGA_G <= "0000";  --Kleurt blauw balletje op scherm
        VGA_B <= "1111";
    else
        --Dikte van lijnen is 5 pixels
        if((h_pos >= 0 and h_pos <= 4) or (h_pos <= (hva - 1) and h_pos >= (hva - 5)) 
        or (v_pos >= 0 and v_pos <= 4) or (v_pos <= (vva - 1) and v_pos >= (vva - 5))) then  --met ranges werken om een "dikkere" lijn te tekenen
            VGA_R <= "1111";
            VGA_G <= "1111";      --Creert een witte lijn rondom het scherm
            VGA_B <= "1111";
        elsif((h_pos >= h_pos_mid - 2) and (h_pos <= h_pos_mid + 2)) then
            VGA_R <= "1111";
            VGA_G <= "1111";      --Creert een verticale witte lijn in het midden van het scherm
            VGA_B <= "1111";
        else
            VGA_R <= "0001";
            VGA_G <= "1101";        --Maakt een groen veld
            VGA_B <= "0001";
        end if;
    end if;
end process;

end Behavioral;
