library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity MSA_timing is
  port (clk_i   : in  std_logic;
        rst_i   : in  std_logic;
        start_i : in  std_logic;
        data_i  : in  std_logic_vector (7 downto 0);
        ready_o : out std_logic);
end MSA_timing;

architecture Behavioral of MSA_timing is
  constant INPUT_CLOCK_FREQUENCY                    : integer := 50_000_000;
  type state is (ready, counting, increment);
  signal state_r, state_f                           : state;
  signal ms_threshold_r, ms_counter_r, ms_counter_f : integer range 0 to 255;
  signal ms_tick_r                                  : std_logic;
  signal ms_tick_counter_r                          : integer range 0 to (INPUT_CLOCK_FREQUENCY / 1_000) - 1;
  signal ms_count_en                                : std_logic;
begin

  p_ms_tick : process(rst_i, clk_i)
  begin
    if(rst_i = '1') then
      ms_tick_counter_r <= 0;
      ms_tick_r         <= '0';
    elsif rising_edge(clk_i) then
      if ms_count_en = '0' then
        ms_tick_counter_r <= 0;
        ms_tick_r         <= '0';
      elsif ms_tick_counter_r >= (INPUT_CLOCK_FREQUENCY / 1_000) - 1 then
        ms_tick_counter_r <= 0;
        ms_tick_r         <= '1';
      else
        ms_tick_counter_r <= ms_tick_counter_r + 1;
        ms_tick_r         <= '0';
      end if;
    end if;
  end process;

  p_sync : process(rst_i, clk_i)
  begin
    if(rst_i = '1') then
      state_r      <= ready;
      ms_counter_r <= 0;
    elsif rising_edge(clk_i) then
      state_r      <= state_f;
      ms_counter_r <= ms_counter_f;
      if ms_count_en = '0' then
        ms_threshold_r <= to_integer(unsigned(data_i));
      else
        ms_threshold_r <= ms_threshold_r;
      end if;
    end if;
  end process;

  p_msa_timing : process(state_r, start_i, ms_tick_r, ms_counter_r, ms_threshold_r)
  begin
    -- default assignments
    state_f      <= state_r;
    ms_counter_f <= ms_counter_r;

    case state_r is
      when ready =>
        ms_counter_f <= 0;
        ms_count_en  <= '0';
        if (start_i = '1') then
          state_f <= counting;
        end if;
      when counting =>
        ms_count_en <= '1';
        if ms_threshold_r = 0 then      -- handle threshold = 0 case
          state_f <= ready;
        elsif ms_tick_r = '1' then
          state_f <= increment;
        end if;
      when others =>                    -- increment
        ms_count_en  <= '1';
        ms_counter_f <= ms_counter_r +1;
        if ms_counter_f +1 >= ms_threshold_r then
          state_f <= ready;
        else
          state_f <= counting;
        end if;
    end case;
  end process;

  ready_o <= not(ms_count_en);
end Behavioral;
