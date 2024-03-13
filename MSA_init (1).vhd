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
              ROM_oled_cmd_addr_o : out std_logic_vector(4 downto 0):= (others=>'0')
              );
end MSA_init;
    
architecture Behavioral of MSA_init is
    signal count : integer := 0;
    type states is (READY, DELAY, SENDING, DONE);
    signal state: states := READY;
    
begin

    process(clk_i, rst_i) begin

        if rst_i ='1' then
            init_done_o         <= '0';
            SPI_start_o         <= '0';
            timing_start_o      <= '0';
            
            ROM_oled_cmd_addr_o <= (others => '0');
            count <= 0;
            state<=READY;
                
        elsif rising_edge (clk_i) then
        
            case state is
                when READY =>
                    if count<=23 then
                        ROM_oled_cmd_addr_o<= std_logic_vector(to_unsigned(count, 5));
                        state<= SENDING;
                    else
                        state<= DONE; 
                    end if;    
                                         
                                       
                when SENDING =>
                    if(delay_i= '1') then
                        timing_start_o<= '1';
                        state <= DELAY;
                                    
                    elsif (delay_i ='0') then
                        SPI_start_o<= '1';
                        state <= DELAY;
                    end if;
                        
                     
                when DELAY =>
                    if (timing_ready_i = '1' and delay_i = '1') then
                        timing_start_o<= '0';
                        count<= count+1;
                        state <= READY;
                    elsif (SPI_ready_i = '1' and delay_i = '0') then
                        SPI_start_o<= '0'; 
			            count<= count+1;
			            state <= READY;
                    end if ;
                          
                when DONE =>
                    init_done_o<='1'; 
                                     
            end case;
        
        end if;
    
    end process;

end Behavioral;
