library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;


entity MSA_echiquier is
        port (clk_i          : in  std_logic;
              rst_i          : in  std_logic;
              timing_data_o  : out std_logic_vector(7 downto 0);
              timing_start_o : out std_logic;
              timing_ready_i : in  std_logic;
              row_i          : in  std_logic_vector(4 downto 0);
              column_i       : in  std_logic_vector(6 downto 0);
              pixel_o        : out std_logic);
end MSA_echiquier;

architecture Behavioral of MSA_echiquier is

-- A completer

begin

-- A remplacer
        timing_start_o <= '0';
        timing_data_o  <= (others => '0');
        pixel_o        <= '0';

end Behavioral;
