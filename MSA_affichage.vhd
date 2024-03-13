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

    type etat is (IDLE, ECHEQUIER, UPDATE);
    signal etat_actuel : etat := IDLE;
    
    signal cnt_colonne     : integer    := 0;
    signal cnt_ligne     : integer    := 7;
    signal cnt_delai   : integer    := 0;
    signal parity     : std_logic  := '0';

begin
    process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            cnt_colonne <= 0;
            cnt_ligne <= 7;
        elsif rising_edge(clk_i) and init_done_i = '1' then
            case etat_actuel is
                
                when ECHEQUIER =>
                    if parity = '0' then
                        SPI_data_o(cnt_ligne) <= pixel_i;
                    else
                        SPI_data_o(cnt_ligne) <= not pixel_i;
                    end if;
                    if cnt_ligne = 7 then
                        if SPI_ready_i = '1' then
                            SPI_start_o <= '1';
                            etat_actuel <= UPDATE;
                        end if;
                    else
                        etat_actuel <= UPDATE;
                    end if;
                    
                    
                when UPDATE =>
                    SPI_start_o <= '0';
                    cnt_ligne <= cnt_ligne - 1;
                    if cnt_ligne = 0 then
                        cnt_ligne <= 7;
                        cnt_colonne <= cnt_colonne + 1;
                        if cnt_colonne = 127 then
                            cnt_colonne <= 0;
                            parity <= not parity;
                        end if;
                    end if;
                    etat_actuel <= IDLE;
                    
                when IDLE => 
                    row_o <= std_logic_vector(to_unsigned(cnt_ligne, 5));
                    column_o <= std_logic_vector(to_unsigned(cnt_colonne, 7));
                    if cnt_ligne = 7 then
                        if  cnt_delai = 6 then
                            cnt_delai <= 0;
                            etat_actuel <= ECHEQUIER;
                        else
                            cnt_delai <= cnt_delai + 1;
                        end if;
                    else
                        etat_actuel <= ECHEQUIER;
                    end if;

            end case;
        end if;
    end process;
end Behavioral;
