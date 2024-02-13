library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity top is
  port (clk_i         : in  std_logic;
        rst_n_i       : in  std_logic;
        oled_dc_n_o   : out std_logic;
        oled_res_n_o  : out std_logic;
        oled_sclk_o   : out std_logic;
        oled_sdo_o    : out std_logic;
        oled_vbat_n_o : out std_logic;
        oled_vdd_n_o  : out std_logic
        );
end top;

architecture Behavioral of top is

  component clk_wiz
    port (
      clk_out1 : out std_logic;
      resetn   : in  std_logic;
      locked   : out std_logic;
      clk_in1  : in  std_logic
      );
  end component;

  component MSA_SPI
    port (clk_i   : in  std_logic;
          rst_i   : in  std_logic;
          start_i : in  std_logic;
          data_i  : in  std_logic_vector (7 downto 0);
          ready_o : out std_logic;
          sdo_o   : out std_logic;
          sclk_o  : out std_logic);
  end component;

  component MSA_affichage
    port (clk_i       : in  std_logic;
          rst_i       : in  std_logic;
          row_o       : out std_logic_vector(4 downto 0);
          column_o    : out std_logic_vector(6 downto 0);
          pixel_i     : in  std_logic;
          SPI_start_o : out std_logic;
          SPI_data_o  : out std_logic_vector (7 downto 0);
          SPI_ready_i : in  std_logic;
          init_done_i : in  std_logic);
  end component;

  component MSA_init
    port (clk_i               : in  std_logic;
          rst_i               : in  std_logic;
          init_done_o         : out std_logic;
          SPI_start_o         : out std_logic;
          SPI_ready_i         : in  std_logic;
          delay_i             : in  std_logic;
          timing_start_o      : out std_logic;
          timing_ready_i      : in  std_logic;
          ROM_oled_cmd_addr_o : out std_logic_vector(4 downto 0));
  end component;

  component oled_cmd_ROM
    port (clk_i  : in  std_logic;
          rst_i  : in  std_logic;
          addr_i : in  std_logic_vector(4 downto 0);
          data_o : out std_logic_vector(11 downto 0));
  end component;

  component MSA_timing
    port (clk_i   : in  std_logic;
          rst_i   : in  std_logic;
          start_i : in  std_logic;
          data_i  : in  std_logic_vector (7 downto 0);
          ready_o : out std_logic);
  end component;

  component MSA_echiquier
    port (
      clk_i          : in  std_logic;
      rst_i          : in  std_logic;
      timing_data_o  : out std_logic_vector(7 downto 0);
      timing_start_o : out std_logic;
      timing_ready_i : in  std_logic;
      row_i          : in  std_logic_vector(4 downto 0);
      column_i       : in  std_logic_vector(6 downto 0);
      pixel_o        : out std_logic);
  end component;

  signal locked, rst_sys        : std_logic;
  signal clk_50mhz              : std_logic;
  signal SPI_start, SPI_ready   : std_logic;
  signal SPI_data               : std_logic_vector(7 downto 0);
  signal row                    : std_logic_vector(4 downto 0);
  signal column                 : std_logic_vector(6 downto 0);
  signal pixel                  : std_logic;
  signal echiquier_timing_start : std_logic;
  signal echiquier_timing_ready : std_logic;
  signal echiquier_timing_data  : std_logic_vector(7 downto 0);
  signal init_timing_start      : std_logic;
  signal init_timing_ready      : std_logic;
  signal init_SPI_start         : std_logic;
  signal init_done              : std_logic;
  signal affichage_SPI_start    : std_logic;
  signal affichage_SPI_data     : std_logic_vector(7 downto 0);
  signal ROM_oled_cmd_addr      : std_logic_vector(4 downto 0);
  signal ROM_oled_cmd_data      : std_logic_vector(11 downto 0);
begin

  inst_clk_wiz_50mhz : clk_wiz
    port map (
      clk_in1  => clk_i,
      resetn   => rst_n_i,
      locked   => locked,
      clk_out1 => clk_50mhz);

  rst_sys <= not(locked);

  inst_MSA_SPI : MSA_SPI
    port map(rst_i   => rst_sys,
             clk_i   => clk_50mhz,
             start_i => SPI_start,
             data_i  => SPI_data,
             ready_o => SPI_ready,
             sdo_o   => oled_sdo_o,
             sclk_o  => oled_sclk_o);

  inst_MSA_affichage : MSA_affichage
    port map(clk_i       => clk_50mhz,
             rst_i       => rst_sys,
             row_o       => row,
             column_o    => column,
             pixel_i     => pixel,
             SPI_start_o => affichage_SPI_start,
             SPI_data_o  => affichage_SPI_data,
             SPI_ready_i => SPI_ready,
             init_done_i => init_done);

  inst_MSA_init : MSA_init
    port map (clk_i               => clk_i,
              rst_i               => rst_sys,
              init_done_o         => init_done,
              SPI_start_o         => init_SPI_start,
              SPI_ready_i         => SPI_ready,
              delay_i             => ROM_oled_cmd_data(11),
              timing_start_o      => init_timing_start,
              timing_ready_i      => init_timing_ready,
              ROM_oled_cmd_addr_o => ROM_oled_cmd_addr);

  inst_oled_cmd_ROM : oled_cmd_ROM
    port map (clk_i  => clk_i,
              rst_i  => rst_sys,
              addr_i => ROM_oled_cmd_addr,
              data_o => ROM_oled_cmd_data);

  inst_MSA_timing_init : MSA_timing
    port map (clk_i   => clk_i,
              rst_i   => rst_sys,
              start_i => init_timing_start,
              data_i  => ROM_oled_cmd_data(7 downto 0),
              ready_o => init_timing_ready);

  inst_MSA_echiquier : MSA_echiquier
    port map(
      clk_i          => clk_50mhz,
      rst_i          => rst_sys,
      timing_data_o  => echiquier_timing_data,
      timing_start_o => echiquier_timing_start,
      timing_ready_i => echiquier_timing_ready,
      row_i          => row,
      column_i       => column,
      pixel_o        => pixel
      );

  inst_MSA_timing_echiquier : MSA_timing
    port map(
      clk_i   => clk_50mhz,
      rst_i   => rst_sys,
      start_i => echiquier_timing_start,
      data_i  => echiquier_timing_data,
      ready_o => echiquier_timing_ready);

  SPI_start     <= affichage_SPI_start or init_SPI_start;
  SPI_data      <= affichage_SPI_data when init_done = '1' else ROM_oled_cmd_data(7 downto 0);
  oled_dc_n_o   <= init_done;
  oled_vdd_n_o  <= ROM_oled_cmd_data(10);
  oled_vbat_n_o <= ROM_oled_cmd_data(9);
  oled_res_n_o  <= ROM_oled_cmd_data(8);

end Behavioral;
