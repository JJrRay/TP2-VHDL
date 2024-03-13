library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity MSA_SPI is
    port (
        rst_i   : in  std_logic;
        clk_i   : in  std_logic;
        start_i : in  std_logic;
        data_i  : in  std_logic_vector(7 downto 0);
        ready_o : out std_logic:= '1';
        sdo_o   : out std_logic:= '0';
        sclk_o  : out std_logic := '0'
        
    );
end MSA_SPI;

architecture Behavioral of MSA_SPI is
    signal clk_div: std_logic_vector(2 downto 0) := (others => '0');
    signal index: natural := 7;
    signal counter: natural := 0;
    signal data_buff: std_logic_vector(7 downto 0);

    type states is (ATTENTE, ECRITURE);
    signal state: states := ATTENTE;
    signal sclk_temp: std_logic := '1';
    signal cs: std_logic := '1';
begin

    process(clk_i, rst_i)
    begin
        if rising_edge(clk_i) then
            if rst_i = '1' then
                ready_o <= '1';
                sdo_o <= '0';
                sclk_temp <= '0';
                state <= ATTENTE;
                index <= 7;
                clk_div <= (others => '0');

            else

                case state is 
                    when ATTENTE =>
                        ready_o <= '1';
                        sclk_o <= '1';
                        if unsigned(clk_div)>=4 then
                            clk_div <= (others => '0');
			            else
                            clk_div <= std_logic_vector(unsigned(clk_div)+ 1);
                        end if;
            
                        if start_i = '1' then
                            data_buff <= data_i;
                            state <= ECRITURE;
                            sclk_temp <= '0';
                            index<=7;
                        end if;
                       	
                        sdo_o <= '0';
            		
                   when ECRITURE =>
                        ready_o <= '0';
                        sclk_o <= sclk_temp;
                        if unsigned(clk_div)>=4 then
                           clk_div <= (others => '0');
                           sclk_temp <= not(sclk_temp);
			               if sclk_temp = '1' then
                           	  if index = 0 then
                           		index <= 7;
                           		state <= ATTENTE;
                           	  else
                           		index <= index - 1;
                       	   	  end if;
			               end if;
                        else
                           clk_div <= std_logic_vector(unsigned(clk_div)+ 1);
                        end if;
         
                        sdo_o <= data_buff(index);

                end case;
            end if;
        end if;
    end process;
end Behavioral;



