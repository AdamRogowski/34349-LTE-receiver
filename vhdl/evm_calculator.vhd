library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.MATH_REAL.all;
  use work.utilities_pkg.all;
  use work.complex_pkg.all;

entity evm_calculator is
  generic (
    -- max number of symbols to calculate average EVM
    constant TOTAL_TO_AVG     : natural := 2048);
  port (clk            : in  std_logic;
        enable         : in  std_logic;
        input_symbol   : in  complex;
        evm            : out real;
        avg_evm        : out real);
end entity;

architecture Behavioral of evm_calculator is
  signal evm_sum : real    := 0.0;
  signal counter : integer := 0;
begin

  process (clk)
    variable ref_symbol   : complex := to_complex(1.0, 1.0);
    variable error_vector : complex := to_complex(0.0, 0.0);
    variable single_evm   : real := 0.0;
  begin
    if rising_edge(clk) then
      if enable = '1' then
        ref_symbol := find_closest_symbol_16_qam(input_symbol);
        error_vector := subtract_complex(input_symbol, ref_symbol);
        single_evm := magnitude(error_vector) / magnitude(ref_symbol) * 100.0;
	evm <= single_evm;
	
        evm_sum <= evm_sum + single_evm;
        counter <= counter + 1;
      end if;
	if counter /= 0 then
	  avg_evm <= evm_sum / real(counter);
	elsif counter = TOTAL_TO_AVG then
          evm_sum <= 0.0; -- reset the sum after calculating average
          counter <= 0; -- reset the counter
        end if;
    end if;
  end process;
end architecture;

