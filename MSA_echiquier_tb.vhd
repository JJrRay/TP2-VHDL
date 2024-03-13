LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY MSA_echiquier_tb IS
END MSA_echiquier_tb;

ARCHITECTURE behavior OF MSA_echiquier_tb IS 

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT MSA_echiquier
    PORT(
         clk_i : IN  std_logic;
         rst_i : IN  std_logic;
         timing_data_o : OUT std_logic_vector(7 downto 0);
         timing_start_o : OUT std_logic;
         timing_ready_i : IN  std_logic;
         row_i : IN  std_logic_vector(4 downto 0);
         column_i : IN  std_logic_vector(6 downto 0);
         pixel_o : OUT std_logic
        );
    END COMPONENT;

   --Inputs
   signal clk_i : std_logic := '0';
   signal rst_i : std_logic := '0';
   signal timing_ready_i : std_logic := '1';
   signal row_i : std_logic_vector(4 downto 0) := (others => '0');
   signal column_i : std_logic_vector(6 downto 0) := (others => '0');

   --Outputs
   signal timing_data_o : std_logic_vector(7 downto 0);
   signal timing_start_o : std_logic;
   signal pixel_o : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: COMPONENT MSA_echiquier
        PORT MAP (
          clk_i => clk_i,
          rst_i => rst_i,
          timing_data_o => timing_data_o,
          timing_start_o => timing_start_o,
          timing_ready_i => timing_ready_i,
          row_i => row_i,
          column_i => column_i,
          pixel_o => pixel_o
        );

    -- Clock process definitions
    clk_process :process
    begin
        clk_i <= '0';
        wait for clk_period/2;
        clk_i <= '1';
        wait for clk_period/2;
    end process;

    -- Process to simulate timing_ready_i behavior
--    timing_ready_process: process
--    begin
--        wait until timing_start_o = '1'; -- Wait for timing_start_o to be asserted
--        timing_ready_i <= '0'; -- Set timing_ready_i to '0'
--        wait for 1 ms; -- Wait for 1 ms
--        timing_ready_i <= '1'; -- Set timing_ready_i back to '1'
--    end process;
    
    
      -- Testbench statements with loop
   stim_proc: process
   begin		
      -- Hold reset state for 100 ns.
      rst_i <= '1';
      wait for 100 ns;	
      rst_i <= '0';
      

      -- Iterate over all row and column addresses
      for shifts in 0 to 128 loop
          for row in 0 to 31 loop -- Adjust the range according to your display's row address size
             for col in 0 to 127 loop -- Adjust the range according to your display's column address size
                row_i <= std_logic_vector(to_unsigned(row, row_i'length));
                column_i <= std_logic_vector(to_unsigned(col, column_i'length));
                wait for clk_period; 
             end loop;
          end loop;
          wait for 1 ms;
      end loop;

      -- Assert the end of simulation
      wait;
   end process;

END behavior;
