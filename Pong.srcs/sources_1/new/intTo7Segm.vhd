library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity intTo7Segm is
    generic (max : integer := 8);
    Port ( getal : in integer;
           segm_clk : in std_logic;
           segm_reset : in std_logic;
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
   signal BCD : std_logic_vector (3 downto 0);
   signal BCD1A : std_logic_vector (3 downto 0);
   signal BCD1B : std_logic_vector (3 downto 0);
   signal segm : std_logic_vector(6 downto 0);
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
   
p_int_to_dec: process(getal)
  begin
    
    --Loop geschreven om niet 10 if statements te gebruiken. Is niet getest geweest op FPGA bord dus weet niet of het werkt
    --for I in 0 to 9 loop
    --    if (getal - (I*10) < 10) then
    --        BCD1A <= std_logic_vector(to_unsigned((I), BCD1A'length));
    --        BCD1B <= std_logic_vector(to_unsigned((getal - (I*10)), BCD1B'length));
    --    else
    --        BCD1A <= "1010";
    --        BCD1B <= "1010";
    --    end if;
    --end loop;
    
    if (getal >= 0 and getal < 10) then
        BCD1A <= "0000";
        BCD1B <= std_logic_vector(to_unsigned((getal), BCD1B'length));
    elsif(getal >= 10 and getal < 20) then
        BCD1A <= "0001";
        BCD1B <= std_logic_vector(to_unsigned((getal - 10), BCD1B'length));
    elsif(getal >= 20 and getal < 30) then
        BCD1A <= "0010";
        BCD1B <= std_logic_vector(to_unsigned((getal - 20), BCD1B'length));
    elsif(getal >= 30 and getal < 40) then
        BCD1A <= "0011";
        BCD1B <= std_logic_vector(to_unsigned((getal - 30), BCD1B'length));
    elsif(getal >= 40 and getal < 50) then
        BCD1A <= "0100";
        BCD1B <= std_logic_vector(to_unsigned((getal - 40), BCD1B'length));
    elsif(getal >= 50 and getal < 60) then
        BCD1A <= "0101";
        BCD1B <= std_logic_vector(to_unsigned((getal - 50), BCD1B'length));
    elsif(getal >= 60 and getal < 70) then
        BCD1A <= "0110";
        BCD1B <= std_logic_vector(to_unsigned((getal - 60), BCD1B'length));
    elsif(getal >= 70 and getal < 80) then
        BCD1A <= "0111";
        BCD1B <= std_logic_vector(to_unsigned((getal - 70), BCD1B'length));
    elsif(getal >= 80 and getal < 90) then
        BCD1A <= "1000";
        BCD1B <= std_logic_vector(to_unsigned((getal - 80), BCD1B'length));
    elsif(getal >= 90 and getal < 100) then
        BCD1A <= "1001";
        BCD1B <= std_logic_vector(to_unsigned((getal - 90), BCD1B'length));
    else
        BCD1A <= "1010";
        BCD1B <= "1010";
    end if;
end process p_int_to_dec;

p_display_teller: process(segm_clk, segm_reset)
  begin
    if segm_reset='1' then
      display_cnt <= 0;
    elsif rising_edge(segm_clk) then
      if (display_cnt = max-1) then
          display_cnt <= 0;
      else
          display_cnt <= display_cnt+1;
      end if;
    end if;
  end process;
  
p_show_display: process(BCD1A, BCD1B, display_cnt)
  begin
    if(display_cnt = 0) then
      AN <= "01111111";                          
      BCD <= "1011";                   --Deze zal dus de display nergens laten oplichten (index 11 in array)
    elsif(display_cnt = 1) then
      AN <= "10111111";                          
      BCD <= "1011";
    elsif(display_cnt = 2) then
      AN <= "11011111";                          
      BCD <= "1011";
    elsif(display_cnt = 3) then
      AN <= "11101111";                          
      BCD <= "1011";
    elsif(display_cnt = 4) then
      AN <= "11110111";                          
      BCD <= "1011";
    elsif(display_cnt = 5) then
      AN <= "11111011";                          
      BCD <= "1011";
    elsif(display_cnt = 6) then
      AN <= "11111101";
      BCD <= BCD1A;
    elsif(display_cnt = 7) then
      AN <= "11111110";
      BCD <= BCD1B;
    else
      AN <= "01111111";                          
      BCD <= "1011";
    end if;
end process p_show_display;

    segm <= cSegm(to_integer(unsigned(BCD))); -- 7segment initialiseren
    CA <= segm(6);
    CB <= segm(5);
    CC <= segm(4);
    CD <= segm(3);
    CE <= segm(2);
    CF <= segm(1);
    CG <= segm(0);
end Behavioral;
