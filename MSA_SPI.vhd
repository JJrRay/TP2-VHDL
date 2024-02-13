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
    type states is (IDLE, READY);
    signal state: states := READY;
    signal sclk_temp: std_logic := '0';
    signal cs: std_logic := '1';
    
begin

    sclk_o <= sclk_temp or cs;
    process(clk_i, rst_i)
    begin
    
        if rising_edge(clk_i) then
        
            if rst_i = '1' then
                -- Reset logic
                ready_o <= '1';
                sdo_o <= '0';
                sclk_temp <= '0';
                state <= READY;
                index <= 7;
                clk_div <= (others => '0');
                cs <= '1';
                
            else
            
            --State Machine conditions
                case state is 
                    when IDLE =>
                        if unsigned(clk_div)>=4 then
                            sclk_temp <= not (sclk_temp);
                            clk_div <= (others => '0');
                            if (sclk_temp='1') then
                                sdo_o<=data_i(index);
                                index<=index-1;
                                if index <=0 then
                                    index<=7;
                                    state <= READY;
                                    cs<= '1';
                                    ready_o<= '1';
                                end if;
                            end if;
                        else
                            clk_div <= std_logic_vector(unsigned(clk_div) + 1);
                        end if;
                    when READY=>
                        ready_o<='1';
                        if start_i='1' then
                            state<= IDLE;
                            ready_o<='0';
                            cs <= '0';
                        end if;    
                end case;
            end if;
        end if;
    end process;
end Behavioral;
