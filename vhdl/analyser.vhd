library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.fixed_pkg.all;
  use work.complex_pkg.all;
  use work.utilities_pkg.all;
  use work.input_data.all;

entity analyser is
  generic (
    FFT_SIZE : integer := 2 ** 11
  );
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    ena     : in  std_logic;
    data_in : in  complex;
    evm     : out real
  );
end entity;

architecture Behavioral of analyser is
  signal data_out : complex;
  signal out_rdy  : std_logic := '0';
  signal avg_evm  : real;

begin

  r2sdf: entity work.r2sdf
    generic map (FFT_SIZE)
    port map (clk => clk, reset => rst, enable => ena, input_symbol => data_in, output_symbol => data_out, output_ready => out_rdy);

  evm_calc: entity work.evm_calculator
    generic map (FFT_SIZE)
    port map (clk => clk, reset => rst, enable => out_rdy, input_symbol => data_out, evm => evm, avg_EVM => avg_evm);

end architecture;


