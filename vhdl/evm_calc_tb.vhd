library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use work.complex_pkg.all;
  use work.utilities_pkg.all;

entity evm_calculator_tb is
end entity;

architecture Behavioral of evm_calculator_tb is
  constant TOTAL_TO_AVG : integer := 4;
  constant CLK_PERIOD : time      := 2 ns;
  signal clk          : std_logic := '0';
  signal rst          : std_logic := '0';
  signal enable       : std_logic := '0';
  signal input_sumbol : complex;
  signal EVM          : real;
  signal avg_EVM      : real;

  -- Test symbols
  constant test_symbols : complex_array(0 to 3) := (
    to_complex(1.500000000000, - 1.500000000000),
    to_complex(- 3.500000000000, - 3.500000000000),
    to_complex(1.500000000000, - 0.500000000000),
    to_complex(- 3.500000000000, - 3.500000000000));
begin
  -- Instantiate the unit under test
  uut: entity work.evm_calculator
    generic map (TOTAL_TO_AVG)
    port map (
      clk          => clk,
      reset        => rst,
      enable       => enable,
      input_symbol => input_sumbol,
      EVM          => EVM,
      avg_EVM      => avg_EVM
    );

  -- Clock process

  clk_process: process
  begin
    clk <= '0';
    wait for CLK_PERIOD / 2;
    clk <= '1';
    wait for CLK_PERIOD / 2;
  end process;

  -- Stimulus process

  stim_proc: process
  begin
    wait for CLK_PERIOD;
    enable <= '1';
    -- Apply test vectors
    for i in test_symbols'range loop
      input_sumbol <= test_symbols(i);
      wait for CLK_PERIOD;
    end loop;
    enable <= '0';
    rst <= '1';
    wait;
  end process;
end architecture;
