
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity MSA_init is
        port (clk_i               : in  std_logic;
              rst_i               : in  std_logic;
              init_done_o         : out std_logic;
              SPI_start_o         : out std_logic;
              SPI_ready_i         : in  std_logic;
              delay_i             : in  std_logic;
              timing_start_o      : out std_logic;
              timing_ready_i      : in  std_logic;
              ROM_oled_cmd_addr_o : out std_logic_vector(4 downto 0)
              );
end MSA_init;

architecture Behavioral of MSA_init is

-- A completer

begin

-- A remplacer
        init_done_o         <= '0';
        SPI_start_o         <= '0';
        timing_start_o      <= '0';
        ROM_oled_cmd_addr_o <= (others => '0');

end Behavioral;
