library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity opteller is
    generic ( h_max : integer := 800;
              v_max : integer := 525);
    Port ( opteller_clk : in STD_LOGIC;
           h_pos : out integer range 0 to h_max;
           v_pos : out integer range 0 to v_max;
           new_frame : out std_logic);
end opteller;

architecture Behavioral of opteller is

signal h_cnt: integer range 0 to h_max := 0;
signal v_cnt: integer range 0 to v_max := 0;
signal frame_cnt: std_logic;

begin
p_teller: process
begin
  wait until(rising_edge(opteller_clk));
    if (h_cnt < h_max) then   --Bij deze opteller wel tot de max tellen (800 voor horizontal bv.)
        h_cnt <= h_cnt + 1;
        new_frame <= '0';
    else
        h_cnt <= 0;
        if (v_cnt < v_max) then
            v_cnt <= v_cnt + 1;
            new_frame <= '0';
        else
            v_cnt <= 0;
            new_frame <= '1';
        end if;
    end if;
end process;

h_pos <= h_cnt;
v_pos <= v_cnt;
end Behavioral;
