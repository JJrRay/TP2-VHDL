library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity MSA_Affichage is
        port (clk_i       : in  std_logic;
              rst_i       : in  std_logic;
              row_o       : out std_logic_vector(4 downto 0);
              column_o    : out std_logic_vector(6 downto 0);
              pixel_i     : in  std_logic;
              SPI_start_o : out std_logic;
              SPI_data_o  : out std_logic_vector (7 downto 0);
              SPI_ready_i : in  std_logic;
              init_done_i : in  std_logic);
end MSA_Affichage;

architecture Behavioral of MSA_Affichage is

-- A completer

begin

-- A remplacer
        row_o       <= (others => '0');
        column_o    <= (others => '0');
        SPI_start_o <= '0';
        SPI_data_o  <= (others => '0');

end Behavioral;
