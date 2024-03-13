library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MSA_top_tb is

end MSA_top_tb;

architecture Behavioral of MSA_top_tb is
    component top
      port (clk_i         : in  std_logic;
        rst_n_i       : in  std_logic;
        oled_dc_n_o   : out std_logic;
        oled_res_n_o  : out std_logic;
        oled_sclk_o   : out std_logic;
        oled_sdo_o    : out std_logic;
        oled_vbat_n_o : out std_logic;
        oled_vdd_n_o  : out std_logic
        );
end component;


signal clk_i : std_logic := '0';
signal rst_n_i : std_logic := '0';
signal oled_dc_n_o : std_logic;
signal oled_res_n_o : std_logic; 
signal oled_sclk_o : std_logic; 
signal oled_sdo_o : std_logic; 
signal oled_vbat_n_o : std_logic; 
signal oled_vdd_n_o : std_logic; 

constant CLK_100MHZ_PERIOD : time := 10ns; 

begin

uut : top
    port map (
        rst_n_i => rst_n_i,
        clk_i=> clk_i,
        oled_dc_n_o => oled_dc_n_o,
        oled_res_n_o => oled_res_n_o,
        oled_sclk_o => oled_sclk_o,
        oled_sdo_o => oled_sdo_o,
        oled_vbat_n_o => oled_vbat_n_o,
        oled_vdd_n_o => oled_vdd_n_o
        );
       
     clk_i <= not clk_i after CLK_100MHZ_PERIOD/2;
     
--      rst_n_i<='1';
--      rst_n_i <= '0', '1' after CLK_100MHZ_PERIOD*420500;


end Behavioral;