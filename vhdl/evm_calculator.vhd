library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.MATH_REAL.all;
  use work.utilities_pkg.all;
  use work.complex_pkg.all;

entity evm_calculator is
  port (clk          : in  std_logic;
        enable       : in  std_logic;
        input_symbol : in  complex;
        evm          : out real);
end entity;

architecture Behavioral of evm_calculator is

begin

  process (clk)
    variable ref_symbol   : complex := to_complex(1.0, 1.0);
    variable error_vector : complex := to_complex(0.0, 0.0);
  begin
    if rising_edge(clk) then
      if enable = '1' then
        ref_symbol := find_closest_symbol_16_qam(input_symbol);
        error_vector := subtract_complex(input_symbol, ref_symbol);
        evm <= magnitude(error_vector) / magnitude(ref_symbol);
      end if;
    end if;
  end process;
end architecture;
