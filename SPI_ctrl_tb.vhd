library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity spi_ctrl_tb is
end;

architecture bench of spi_ctrl_tb is

  -- "Component" du module a verifier
  component msa_spi
    port(
      -- Input
      clk_i   : in  std_logic;
      rst_i   : in  std_logic;
      start_i : in  std_logic;
      data_i  : in  std_logic_vector(7 downto 0);
      -- Output
      ready_o : out std_logic;
      sclk_o  : out std_logic;
      sdo_o   : out std_logic
      );
  end component;


  -- Declaration des signaux pour instancier le module a verifier
  signal clk_tb     : std_logic := '1';
  signal rst_i_tb   : std_logic := '1';
  signal valid_i_tb : std_logic;
  signal data_i_tb  : std_logic_vector(7 downto 0);
  signal ready_o_tb : std_logic;
  signal sclk_o_tb  : std_logic;
  signal sdo_o_tb   : std_logic;
  signal cnt        : integer   := 0;

  -- Signaux pour la verification
  signal clk_en       : boolean := true;
  constant clk_period : time    := 20 ns;

begin
  -- Instancier le module a verifier
  uut : msa_spi
    port map (
      clk_i   => clk_tb,
      rst_i   => rst_i_tb,
      start_i => valid_i_tb,
      data_i  => data_i_tb,
      ready_o => ready_o_tb,
      sclk_o  => sclk_o_tb,
      sdo_o   => sdo_o_tb
      );

  rst_i_tb <= '1', '0' after 5*clk_period;

  -- Driver - Processus pour donner des valeurs
  -- aux entrees du module a verifier
  -- Les entrees changent sur le front descendant de l'horloge
  driver : process
  begin
    -- donnees initiales
    data_i_tb  <= "10101010";
    valid_i_tb <= '0';

    wait for 10* clk_period;            --attendre le reset

    -- Verification de l'etat des sorties apres un changement de data et un valide_i a 0
    wait for 1ps;
    assert (sclk_o_tb = '1' and ready_o_tb = '1')
      report "Test1 Error: SCLK not HIGH or ready not HIGH before start of transaction"
      severity error;

    -- Verification de l'etat des sorties apres une remise a 1 de valide_i   
    valid_i_tb <= '1';
    wait for 1*clk_period;
    assert (sclk_o_tb = '0' and ready_o_tb = '0' and sdo_o_tb = data_i_tb(7))
      report "Test2 Error: SCLK not LOW or ready not LOw or wrong first bit at 1 clk cycle after start"
      severity error;

    -- Verification de l'etat des sorties apres une remise a 0 de valide_i               
    valid_i_tb <= '0';
    for i in 0 to 7 loop
      wait until rising_edge(sclk_o_tb);
      assert (ready_o_tb = '0' and sdo_o_tb = data_i_tb(7-i))
        report "Test3 Error: Wrong data on SDO check data value. Data should be sent MSB first"
        severity error;
    end loop;

    -- Verification de l'etat des sorties a la fin de la transaction SPI
    wait for 20*clk_period;
    assert (sclk_o_tb = '1' and ready_o_tb = '1')
      report "Test4 Error: SCLK not HIGH or ready not HIGH at end of transaction"
      severity error;

    wait for 100*clk_period;

    -- deuxieme transaction
    data_i_tb  <= "01010101";
    valid_i_tb <= '1';
    wait for 1*clk_period;
    valid_i_tb <= '0';
    for i in 0 to 7 loop
      wait until rising_edge(sclk_o_tb);
      assert (ready_o_tb = '0' and sdo_o_tb = data_i_tb(7-i))
        report "Test5 Error: Wrong data on SDO check data value. Data should be sent MSB first"
        severity error;
    end loop;

    -- Fin de la simulation
    clk_en <= false;
    wait;
  end process;

  -- Horloge
  clk_tb <= not clk_tb after clk_period/2 when clk_en else '0';

end bench;
