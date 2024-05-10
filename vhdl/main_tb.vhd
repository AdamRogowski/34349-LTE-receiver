library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.fixed_pkg.all;
  use work.complex_pkg.all;
  use work.utilities_pkg.all;
  use work.input_data.all;

-- Test interaction between r2sdf module and EVM calculator
-- Generate EVM for 16QAM input data
entity main_tb is
end entity;

architecture Behavioral of main_tb is
  constant FFT_SIZE   : integer := 2 ** 11;
  constant CLK_PERIOD : time    := 2 ns;

  signal clk : std_logic := '0';
  signal rst : std_logic := '0';
  signal ena : std_logic := '1';

  signal data_in  : complex;
  signal data_out : complex;

  --output_ready signal from fft enabling the evm calculation
  signal out_rdy : std_logic := '0';

  -- register with the output symbols in reverse order
  signal out_arr : complex_array(0 to FFT_SIZE - 1);

  signal evm : real;
  signal avr_evm : real;

begin

  r2sdf: entity work.fft
    generic map (FFT_SIZE)
    port map (clk => clk, reset => rst, enable => ena, input_symbol => data_in, output_symbol => data_out, output_ready => out_rdy);

  evm_calc: entity work.evm_calculator
    generic map (FFT_SIZE)
    port map (clk => clk, enable => out_rdy, input_symbol => data_out, evm => evm, avg_EVM => avr_evm);

  clock_process: process
  begin
    clk <= '0';
    wait for CLK_PERIOD / 2;
    clk <= '1';
    wait for CLK_PERIOD / 2;
  end process;

  -- Input symbol once every clock cycle
  stimulus: process
  begin
    for i in 0 to FFT_SIZE - 1 loop
      data_in <= INPUT_DATA_2048_16QAM_NOISY(i);
      wait for CLK_PERIOD;
    end loop;
    wait;
  end process;

  output: process (clk)
    variable global_counter : natural := 0;
    variable index          : natural := 0;
  begin
    if rising_edge(clk) then
      global_counter := global_counter + 1;

      -- store the output symbols in reverse order
      if global_counter > FFT_SIZE - 1 and global_counter < 2 * FFT_SIZE then
        index := global_counter - FFT_SIZE;
        out_arr(index) <= data_out;
      end if;

      -- stop the simulation after the last output symbol
      if global_counter > 2 * FFT_SIZE - 2 then
        ena <= '0';
        rst <= '1';
      end if;

    end if;
  end process;

end architecture;

