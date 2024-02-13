library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity oled_cmd_ROM is
  port (
    clk_i  : in  std_logic;
    rst_i  : in  std_logic;
    addr_i : in  std_logic_vector(4 downto 0);
    data_o : out std_logic_vector(11 downto 0)
    );

end oled_cmd_ROM;
architecture arch_oled_cmd_ROM of oled_cmd_ROM is
  type ROM_T is array (0 to 31) of std_logic_vector (11 downto 0);
  -- Chaque commande contient 12 bits definits comme suit (MSB vers LSB):
  -- bit 11: selection delay ou commande SPI (0:commande, 1:delay)
  -- bit 10: signal VDD (0:VDD actif, 1:VDD inactif)
  -- bit 9:  signal VBAT (0:VBAT actif, 1:VBAT inactif)
  -- bit 8:  signal RES (0:RES actif, 1:RES inactif)
  -- bits 7-0: commande SPI, donnee SPI ou delay d'attente (dependant des bits 12 et 11)
  constant ROM_cst : ROM_T := (
    --Sequence d'initialisation
    "1011" & X"01",  -- Addr 0x00 : Mise sous tension VDD, attente 1ms
    "0011" & X"AE",  -- Addr 0x01 : Envoi commande Display Off 0xAE
    "1010" & X"01",  -- Addr 0x02 : Reinitialisation, attente 1ms
    "1011" & X"01",  -- Addr 0x03 : Fin reinitialisation, attente 1ms
    "0011" & X"8D",  -- Addr 0x04 : Envoi commande Enable Charge Pump 0x8D14
    "0011" & X"14",  -- Addr 0x05 : suite
    "0011" & X"D9",  -- Addr 0x06 : Envoi commande Set Pre-Charge Period 0xD9F1
    "0011" & X"F1",  -- Addr 0x07 : suite
    "1001" & X"64",  -- Addr 0x08 : Mise sous tension VBAT, attente 100ms
    "0001" & X"81",  -- Addr 0x09 : Envoi commande Set Contrast Control 0x810F
    "0001" & X"0F",  -- Addr 0x0A : suite
    "0001" & X"A0",  -- Addr 0x0B : Envoi commande Set Segment Remap 0xA0
    "0001" & X"C0",  -- Addr 0x0C : Envoi commande Set COM Output Scan Direction 0xC0
    "0001" & X"DA",  -- Addr 0x0D : Envoi commande Set COM Pins Hardware Configuration 0xDA
    "0001" & X"00",  -- Addr 0x0E : Envoi commande Set Lower Column Start Address 0x00
    "0001" & X"AF",  -- Addr 0x0F : Envoi commande Set Display On 0xAF
    -- Configuration
    "0001" & X"20",  -- Addr 0x10 : Envoi commande Set Memory Addressing Mode 0x20
    "0001" & X"00",  -- Addr 0x11 : suite: selection du mode horizontal
    "0001" & X"21",  -- Addr 0x12 : Envoi commande Set Column Address 0x21
    "0001" & X"00",  -- Addr 0x13 : suite: selection colonne de depart
    "0001" & X"7F",  -- Addr 0x14 : suite: selection colonne d'arret
    "0001" & X"22",  -- Addr 0x15 : Envoi commande Set Page Address 0x22
    "0001" & X"00",  -- Addr 0x16 : suite: selection page de depart
    "0001" & X"03",  -- Addr 0x17 : suite: selection page d'arret

    -- Activation de tous les pixels de l'ecran
    --"0001" & X"A5",                     -- screen Entire display on
    "1111" & X"00", -- Mettre en commentaire cette ligne pour conserver la
                    -- taille de la ROM

    -- Espace ROM extra
    "1111" & X"00", "1111" & X"00", "1111" & X"00", "1111" & X"00", "1111" & X"00", "1111" & X"00",
    "1111" & X"00"
    );

begin

  p_sync : process (clk_i, rst_i)
  begin
    if (rst_i = '1') then
      data_o <= "1111" & X"00";
    elsif rising_edge(clk_i) then
      data_o <= ROM_cst (to_integer (unsigned (addr_i)));
    end if;
  end process;

end arch_oled_cmd_ROM;
