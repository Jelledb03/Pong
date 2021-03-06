library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Overkoepelend is
    Port ( 
       clk_in1: in std_logic;  --Is de 100MHz klok die binnenkomt van XDC file
       BTNU, BTNL, BTNR, BTND: in std_logic;
       VGA_R, VGA_G, VGA_B: out std_logic_vector(3 downto 0);
       VGA_HS, VGA_VS: out std_logic;
       AN : out std_logic_vector (7 downto 0);
       CA : out std_logic;
       CB : out std_logic;
       CC : out std_logic;
       CD : out std_logic;
       CE : out std_logic;
       CF : out std_logic;
       CG : out std_logic
    );
end Overkoepelend;

architecture Structural of Overkoepelend is
-- Signals

-- Horizontal
constant hva : integer := 640; -- Visible area   --constant hier ook gebruiken???
constant hfp : integer :=  16; -- Front porch
constant hsp : integer :=  96; -- Sync pulse
constant hbp : integer :=  48; -- Back porch
constant h_max : integer := hva + hfp + hsp + hbp; -- Horizontal Max Range 800
-- Vertical
constant vva : integer := 480; -- Visible area
constant vfp : integer :=  10; -- Front porch
constant vsp : integer :=   2; -- Sync pulse
constant vbp : integer :=  33; -- Back porch
constant v_max : integer := vva + vfp + vsp + vbp; -- Vertical Max Range 525

-- Out Signals
signal clk_out1 : std_logic;
signal new_frame : std_logic;
signal v_pos: integer range 0 to v_max;
signal h_pos: integer range 0 to h_max;
signal v_sync: std_logic;
signal h_sync: std_logic;
signal locked : std_logic := '0';

--clkdivider (100Hz pulse) Signals
signal pulseout100hz : std_logic;
constant div: integer := 50000; -- van 25MHz => 100Hz

--Score Signals
signal score_pad1, score_pad2 : integer range 0 to 9;
constant numberDisplays : integer := 8;
constant maxTientalScore : integer := 2; --Tot een maximale score van 20

   component clk_wiz_0
   port(
     clk_out1: out std_logic;                --25MHz klok output actual 25 MHz
     clk_in1: in std_logic
   );
   end component;
   
   component opteller is
   generic (
     v_max : integer := 525;
     h_max : integer := 800
     );  -- moet hier het maximale van de horizontale en verticale timings zijn
   Port ( 
     opteller_clk : in std_logic;
     h_pos : out integer range 0 to h_max;
     v_pos : out integer range 0 to v_max;
     new_frame : out std_logic
   );                 
   end component;
   
   component vga is
   Port (
     hva: in integer;
     hfp: in integer;
     hsp: in integer;
     hbp: in integer;            -- alle timings komen binnen
     vva: in integer;
     vfp: in integer;
     vsp: in integer;
     vbp: in integer;
     vga_clk : in std_logic;
     new_frame: in std_logic;
     BTNU,BTNL, BTNR, BTND: in std_logic;
     v_sync : out std_logic;
     h_sync : out std_logic;
     h_pos: in integer;          -- posities komen binnen
     v_pos: in integer;
     VGA_R, VGA_G, VGA_B: out std_logic_vector(3 downto 0);
     VGA_HS, VGA_VS: out std_logic;
     score_pad1, score_pad2: out integer range 0 to 9
   );
   end component;
   
   component clkdivider is
   generic (divideby : natural := 2);
   Port ( 
     clk_div : in std_logic;
     pulseout : out std_logic);
   end component;
   
   component intTo7Segm is
   generic (max : integer := 8;
            maxTiental: integer := 2);
   Port ( score1 : in integer range 0 to 9;
     score2 : in integer range 0 to 9;
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
   end component;

begin
    Klokje : clk_wiz_0 port map (
        clk_out1 => clk_out1,
        clk_in1 => clk_in1
    );
        
    teller : opteller generic map (
            v_max => v_max,
            h_max => h_max)
        port map(
            opteller_clk => clk_out1,
            h_pos => h_pos,
            v_pos => v_pos,
            new_frame => new_frame
    );
    
    divider: clkdivider 
    generic map (
        divideby => div
    )
    port map(
      clk_div => clk_out1,
      pulseout => pulseout100hz
    );
      
      
        
    vga_mapping : vga port map (
        hva => hva,
        hfp => hfp,
        hsp => hsp,
        hbp => hbp,
        vva => vva,
        vfp => vfp,
        vsp => vsp,
        vbp => vbp,
        vga_clk => clk_out1,
        new_frame => new_frame,
        BTNU => BTNU,
        BTNL => BTNL,
        BTNR => BTNR,
        BTND => BTND,
        v_sync => v_sync,
        h_sync => h_sync,
        h_pos => h_pos,
        v_pos => v_pos,
        VGA_R => VGA_R,
        VGA_G => VGA_G,
        VGA_B => VGA_B,
        VGA_HS => VGA_HS,
        VGA_VS => VGA_VS,
        score_pad1 => score_pad1,
        score_pad2 => score_pad2
    );
    
    intToSegm : intTo7Segm
    generic map(
       max => numberDisplays,
       maxTiental => maxTientalScore
    )    
    port map (
       score1 => score_pad1,
       score2 => score_pad2,
       segm_clk => clk_out1,
       pulse100hz => pulseout100hz,
       AN => AN,
       CA => CA,
       CB => CB,
       CC => CC,
       CD => CD,
       CE => CE,
       CF => CF,
       CG => CG
     );
             
end Structural;
