
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;


entity MSA_echiquier is
        port (clk_i          : in  std_logic;
              rst_i          : in  std_logic;
              timing_data_o  : out std_logic_vector(7 downto 0):= X"01";
              timing_start_o : out std_logic:=  '0';
              timing_ready_i : in  std_logic;
              row_i          : in  std_logic_vector(4 downto 0);
              column_i       : in  std_logic_vector(6 downto 0);
              pixel_o        : out std_logic:=  '0');
end MSA_echiquier;

architecture Behavioral of MSA_echiquier is
    signal shift_count: natural:= 0 ;
    signal time_count: natural:= 0 ;
    signal row_offset, column_offset: integer;

    

begin


    process(clk_i, rst_i) begin

        if rst_i ='1' then
            timing_data_o         <= X"01";
            timing_start_o        <= '0';
            pixel_o               <= '0';
    
            time_count           <= 0;
            shift_count           <=0;


        elsif rising_edge(clk_i) then
           if time_count < 5000000 then
               time_count <= time_count + 1;
	       else
		      time_count <= 0;
		      if shift_count < 7 then
		          shift_count <= (shift_count + 1);
		      else shift_count <= 0;    
		      end if;     
           end if;
                
		   row_offset <= (to_integer(unsigned(row_i)) - shift_count) mod 16;
      	   column_offset <= (to_integer(unsigned(column_i)) - shift_count) mod 16;
      
           if ((row_offset / 8)  + (column_offset / 8) ) mod 2 = 0 then
              pixel_o <= '1';
           else
			  pixel_o <= '0';
           end if;
    
        end if;
      end process;
 end Behavioral;
