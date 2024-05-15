library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use work.complex_pkg.all;
  use work.twiddle_values.all;
  use work.test_constants.all;

entity stage is
  generic (
    -- Constant size of the 1st biggest stage in the r2sdf architecture = MAX_FFT_SIZE
    -- NOTE: MAX_STAGE_SIZE is used to retrieve correct twiddle factor address from  
    --       constant TWIDDLE_VALUES for the current stage size
    constant MAX_STAGE_SIZE     : natural := 2048;
    -- Constant size of the current stage in the r2sdf architecture
    constant CURRENT_STAGE_SIZE : natural := 512);
  port (clk            : in  std_logic;
        reset          : in  std_logic;
        enable         : in  std_logic;
        -- used to switch between stage phases 
        control_signal : in  std_logic;
        -- input data, for the first stage it is the input symbol
        -- for the rest of the stages it is the output of the previous stage
        data_in        : in  complex;
        -- output data, for the last stage it is the output symbol
        data_out       : out complex);
end entity;

architecture Behavioral of stage is
  -- Single Path Delay shift register signals
  signal shift_reg_in  : complex := to_complex(0.0, 0.0);
  signal shift_reg_out : complex := to_complex(0.0, 0.0);

  -- Butterfly signals
  signal bf_in_1           : complex := to_complex(0.0, 0.0);
  signal bf_in_2           : complex := to_complex(0.0, 0.0);
  signal bf_adder_out      : complex := to_complex(0.0, 0.0);
  signal bf_subtractor_out : complex := to_complex(0.0, 0.0);

  -- Twiddle factor multiplier signals
  signal multiplier_in  : complex := to_complex(0.0, 0.0);
  signal multiplier_out : complex := to_complex(0.0, 0.0);
  -- Twiddle factor index
  signal twiddle_index : natural := 0;
begin

  -- Twiddle counter logic 
  process (clk)
    variable twiddle_counter : natural := 0;
  begin
    if rising_edge(clk) then
      if reset = '1' then
        twiddle_counter := 0;
        twiddle_index <= 0;
      elsif enable = '1' then
        -- twiddle_index is incremented depending on the current stage size
        -- NOTE: For the first stage the twiddle_index is incremented by 1,
        --       For the second stage the twiddle_index is incremented by 2,
        --       For the third stage the twiddle_index is incremented by 4,
        --       and so on to to get correct twiddle factor index for smaller stages
        twiddle_counter := twiddle_index + 1 * MAX_STAGE_SIZE / CURRENT_STAGE_SIZE;
        -- reset twiddle_counter if it reaches half of the MAX_STAGE_SIZE
        if twiddle_counter = MAX_STAGE_SIZE / 2 then
          twiddle_counter := 0;
        end if;
        twiddle_index <= twiddle_counter;
      end if;
    end if;
  end process;

  -- Single Path Delay shift register logic
  process (clk)
    -- Shift register variable of a size of the half of the current stage
    variable shift_reg : complex_array(CURRENT_STAGE_SIZE / 2 - 1 downto 0) := (others => to_complex(0.0, 0.0));
  begin
    if rising_edge(clk) then
      if reset = '1' then
        shift_reg := (others => to_complex(0.0, 0.0));
        shift_reg_out <= to_complex(0.0, 0.0);
      elsif enable = '1' then
        -- fill the shift register with new input data
        shift_reg := shift_reg(CURRENT_STAGE_SIZE / 2 - 2 downto 0) & shift_reg_in;
        -- output the oldest data from the shift register
        shift_reg_out <= shift_reg(CURRENT_STAGE_SIZE / 2 - 1);
      end if;
    end if;
  end process;

  -- PHASE ONE of the stage (control_signal = '0'):
  -- Old CURRENT_STAGE_SIZE/2 data points from the shift register are multiplied with twiddle factor,
  --    the product is directly forwarded to the next stage
  -- Shift register is filled with new input data
  -- Outputs of the butterfly are ignored in this phase
  --
  -- PHASE TWO of the stage (control_signal = '1'):
  -- Butterfly is fed with new incoming CURRENT_STAGE_SIZE/2 data points 
  --    and output CURRENT_STAGE_SIZE/2 data points from the shift register.
  -- Adder output is directly forwarded to the next stage without any multiplication,
  -- Subtractor output is fed back into the shift register (delayed)
  shift_reg_in   <= data_in when control_signal = '0' else bf_subtractor_out;
  multiplier_in  <= shift_reg_out when control_signal = '0' else bf_adder_out;
  multiplier_out <= multiply_complex(multiplier_in, TWIDDLE_VALUES_2048(twiddle_index)) when control_signal = '0' else multiplier_in;

  bf_in_1 <= to_complex(0.0, 0.0) when control_signal = '0' else shift_reg_out;
  bf_in_2 <= to_complex(0.0, 0.0) when control_signal = '0' else data_in;

  bf_adder_out      <= to_complex(0.0, 0.0) when control_signal = '0' else add_complex(bf_in_1, bf_in_2);
  bf_subtractor_out <= to_complex(0.0, 0.0) when control_signal = '0' else subtract_complex(bf_in_1, bf_in_2);

  data_out <= multiplier_out;

end architecture;
