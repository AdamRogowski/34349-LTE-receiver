library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use work.complex_pkg.all;
  use work.utilities_pkg.all;

entity evm_calculator_tb is
end entity;

architecture Behavioral of evm_calculator_tb is
  signal clk          : std_logic := '0';
  signal enable       : std_logic := '0';
  signal input_sumbol : complex;
  signal EVM          : real;

  -- Test symbols
  constant test_symbols : complex_array(0 to 63) := (
    to_complex(3.000000000000, - 3.000000000000),
    to_complex(- 1.000000000000, - 1.000000000000),
    to_complex(- 1.000000000000, - 1.000000000000),
    to_complex(- 1.000000000000, 1.000000000000),
    to_complex(- 1.000000000000, 1.000000000000),
    to_complex(1.000000000000, - 3.000000000000),
    to_complex(- 1.000000000000, - 1.000000000000),
    to_complex(3.000000000000, - 1.000000000000),
    to_complex(- 3.000000000000, - 3.000000000000),
    to_complex(- 3.000000000000, 1.000000000000),
    to_complex(- 3.000000000000, - 1.000000000000),
    to_complex(3.000000000000, 3.000000000000),
    to_complex(3.000000000000, - 3.000000000000),
    to_complex(1.000000000000, - 1.000000000000),
    to_complex(- 3.000000000000, 3.000000000000),
    to_complex(- 3.000000000000, - 3.000000000000),
    to_complex(- 1.000000000000, - 1.000000000000),
    to_complex(- 1.000000000000, 1.000000000000),
    to_complex(- 3.000000000000, 1.000000000000),
    to_complex(1.000000000000, 3.000000000000),
    to_complex(- 1.000000000000, - 3.000000000000),
    to_complex(3.000000000000, - 3.000000000000),
    to_complex(3.000000000000, 1.000000000000),
    to_complex(- 3.000000000000, 3.000000000000),
    to_complex(3.000000000000, - 3.000000000000),
    to_complex(- 1.000000000000, 1.000000000000),
    to_complex(- 1.000000000000, 3.000000000000),
    to_complex(- 1.000000000000, - 1.000000000000),
    to_complex(3.000000000000, 1.000000000000),
    to_complex(1.000000000000, 3.000000000000),
    to_complex(3.000000000000, 3.000000000000),
    to_complex(- 3.000000000000, 3.000000000000),
    to_complex(1.000000000000, 3.000000000000),
    to_complex(- 1.000000000000, 3.000000000000),
    to_complex(1.000000000000, 1.000000000000),
    to_complex(3.000000000000, - 1.000000000000),
    to_complex(3.000000000000, 1.000000000000),
    to_complex(- 1.000000000000, - 3.000000000000),
    to_complex(- 3.000000000000, 1.000000000000),
    to_complex(1.000000000000, - 1.000000000000),
    to_complex(3.000000000000, - 3.000000000000),
    to_complex(- 3.000000000000, - 1.000000000000),
    to_complex(- 3.000000000000, 1.000000000000),
    to_complex(- 3.000000000000, - 1.000000000000),
    to_complex(1.000000000000, - 3.000000000000),
    to_complex(- 3.000000000000, - 1.000000000000),
    to_complex(- 1.000000000000, - 1.000000000000),
    to_complex(1.000000000000, - 3.000000000000),
    to_complex(- 3.000000000000, - 1.000000000000),
    to_complex(- 1.000000000000, - 1.000000000000),
    to_complex(3.000000000000, 1.000000000000),
    to_complex(3.000000000000, 1.000000000000),
    to_complex(3.000000000000, - 3.000000000000),
    to_complex(- 1.000000000000, 3.000000000000),
    to_complex(- 1.000000000000, - 3.000000000000),
    to_complex(1.000000000000, 3.000000000000),
    to_complex(1.000000000000, - 3.000000000000),
    to_complex(- 1.000000000000, - 1.000000000000),
    to_complex(- 1.000000000000, 3.000000000000),
    to_complex(- 1.000000000000, - 1.000000000000),
    to_complex(- 1.000000000000, 3.000000000000),
    to_complex(- 1.000000000000, 3.000000000000),
    to_complex(- 3.000000000000, - 3.000000000000),
    to_complex(- 3.000000000000, - 3.000000000000));
begin
  -- Instantiate the unit under test
  uut: entity work.evm_calculator
    port map (
      clk          => clk,
      enable       => enable,
      input_symbol => input_sumbol,
      EVM          => EVM
    );

  -- Clock process

  clk_process: process
  begin
    clk <= '0';
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
  end process;

  -- Stimulus process

  stim_proc: process
  begin
    wait for 20 ns;
    enable <= '1';
    -- Apply test vectors
    for i in test_symbols'range loop
      input_sumbol <= test_symbols(i);
      wait for 20 ns;
    end loop;
    wait;
  end process;
end architecture;
