library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.fixed_pkg.all;
  use work.complex_pkg.all;
  use work.utilities_pkg.all;
  use work.input_data.all;

-- Top level test module
entity analyser_tb is
end entity;

architecture Behavioral of analyser_tb is
  constant FFT_SIZE   : integer := 2 ** 11;
  constant CLK_PERIOD : time    := 2 ns;

  signal clk : std_logic := '0';
  signal rst : std_logic := '0';
  signal ena : std_logic := '1';

  signal data_in  : complex;
  signal evm : real;

begin

  analyser: entity work.analyser
    generic map (FFT_SIZE)
    port map (clk => clk, rst => rst, ena => ena, data_in => data_in, evm => evm);

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
  begin
    if rising_edge(clk) then
      global_counter := global_counter + 1;

      -- stop the simulation after the last output symbol
      if global_counter > 2 * FFT_SIZE - 2 then
        ena <= '0';
        rst <= '1';
      end if;
      if global_counter > 2 * FFT_SIZE - 1 then
	rst <= '0';
      end if;
    end if;
  end process;

end architecture;

