library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clkdivider is
    generic (divideby : natural := 2);
    Port ( clk_div : in std_logic;
           pulseout : out std_logic);
end clkdivider;


architecture Behavioral of clkdivider is
signal cnt : natural range 0 to divideby-1;
begin

process
begin
    wait until (rising_edge(clk_div));
		if (cnt = divideby-1)  then
			cnt <= 0;
		else
			cnt <= cnt+1;
		end if;
end process;
pulseout <= '1' when cnt=divideby-1 else '0';
end Behavioral;


