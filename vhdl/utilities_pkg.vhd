library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.NUMERIC_STD.all;
  use IEEE.MATH_REAL.all;
  use IEEE.fixed_pkg.all;
  use work.complex_pkg.all;

package utilities_pkg is
  function log_2(val : natural) return integer;
  function magnitude(c : complex) return real;
  function find_closest_symbol_qpsk(symbol : complex) return complex;
  function find_closest_symbol_qpsk1(symbol : complex) return complex;
  function find_closest_symbol_16_qam(symbol : complex) return complex;
end package;

package body utilities_pkg is

  -- Function to calculate log base 2 of a val
  function log_2(val : natural) return integer is
    variable temp   : integer := val;
    variable result : integer := 0;
  begin
    while temp > 1 loop
      result := result + 1;
      temp := temp / 2;
    end loop;
    return result;
  end function;

  function magnitude(c : complex) return real is
  begin
    return sqrt(to_real(c.real) * to_real(c.real) + to_real(c.imag) * to_real(c.imag));
  end function;

  -- Function to find the closest symbol in QPSK modulation, using LUT
  -- NOTE: Standard Gray coding for QPSK
  --       Precalculated fixed(3,-12) values of sqrt(2)/2
  function find_closest_symbol_qpsk(symbol : complex) return complex is
  begin
    if symbol.real >= 0.0 and symbol.imag >= 0.0 then
      return to_complex(0.707031250000, 0.707031250000);
    elsif symbol.real >= 0.0 and symbol.imag < 0.0 then
      return to_complex(0.707031250000, - 0.707031250000);
    elsif symbol.real < 0.0 and symbol.imag >= 0.0 then
      return to_complex(- 0.707031250000, 0.707031250000);
    else
      return to_complex(- 0.707031250000, - 0.707031250000);
    end if;
  end function;

  -- Function to find the closest symbol in QPSK modulation, using LUT
  -- NOTE: Variant for {-1, 1} constellation
  function find_closest_symbol_qpsk1(symbol : complex) return complex is
  begin
    if symbol.real >= 0.0 and symbol.imag >= 0.0 then
      return to_complex(1.0, 1.0);
    elsif symbol.real >= 0.0 and symbol.imag < 0.0 then
      return to_complex(1.0, - 1.0);
    elsif symbol.real < 0.0 and symbol.imag >= 0.0 then
      return to_complex(- 1.0, 1.0);
    else
      return to_complex(- 1.0, - 1.0);
    end if;
  end function;

  -- Function to find the closest symbol in 16-QAM modulation, using LUT
  function find_closest_symbol_16_qam(symbol : complex) return complex is
  begin
    if symbol.real <= - 2.0 then
      if symbol.imag <= - 2.0 then
        return to_complex(- 3.0, - 3.0);
      elsif symbol.imag <= 0.0 then
        return to_complex(- 3.0, - 1.0);
      elsif symbol.imag <= 2.0 then
        return to_complex(- 3.0, 1.0);
      else
        return to_complex(- 3.0, 3.0);
      end if;
    elsif symbol.real <= 0.0 then
      if symbol.imag <= - 2.0 then
        return to_complex(- 1.0, - 3.0);
      elsif symbol.imag <= 0.0 then
        return to_complex(- 1.0, - 1.0);
      elsif symbol.imag <= 2.0 then
        return to_complex(- 1.0, 1.0);
      else
        return to_complex(- 1.0, 3.0);
      end if;
    elsif symbol.real <= 2.0 then
      if symbol.imag <= - 2.0 then
        return to_complex(1.0, - 3.0);
      elsif symbol.imag <= 0.0 then
        return to_complex(1.0, - 1.0);
      elsif symbol.imag <= 2.0 then
        return to_complex(1.0, 1.0);
      else
        return to_complex(1.0, 3.0);
      end if;
    else
      if symbol.imag <= - 2.0 then
        return to_complex(3.0, - 3.0);
      elsif symbol.imag <= 0.0 then
        return to_complex(3.0, - 1.0);
      elsif symbol.imag <= 2.0 then
        return to_complex(3.0, 1.0);
      else
        return to_complex(3.0, 3.0);
      end if;
    end if;
  end function;

end utilities_pkg;

