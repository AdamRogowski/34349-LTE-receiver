library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.fixed_pkg.all;

package complex_pkg is

  -- Constants for fixed-point representation
  -- NOTE: 3 downto -12 gives the best quality for 16-qam modulation,
  --       assuming circa uniform distribution of symbols
  constant INT_PART   : integer := 3;
  constant FRACT_PART : integer := - 12;

  type complex is record
    real : sfixed(INT_PART downto FRACT_PART);
    imag : sfixed(INT_PART downto FRACT_PART);
  end record;

  type complex_array is array (natural range <>) of complex;

  function to_complex(c1, c2 : real) return complex;
  function add_complex(c1, c2 : complex) return complex;
  function subtract_complex(c1, c2 : complex) return complex;
  function multiply_complex(c1, c2 : complex) return complex;
end package;

package body complex_pkg is

  function to_complex(c1, c2 : real) return complex is
  begin
    return (to_sfixed(c1, INT_PART, FRACT_PART), to_sfixed(c2, INT_PART, FRACT_PART));
  end function;

  function add_complex(c1, c2 : complex) return complex is
    variable complex_sum : complex;
  begin
    complex_sum.real := resize(c1.real + c2.real, INT_PART, FRACT_PART);
    complex_sum.imag := resize(c1.imag + c2.imag, INT_PART, FRACT_PART);
    return complex_sum;
  end function;

  function subtract_complex(c1, c2 : complex) return complex is
    variable complex_diff : complex;
  begin
    complex_diff.real := resize(c1.real - c2.real, INT_PART, FRACT_PART);
    complex_diff.imag := resize(c1.imag - c2.imag, INT_PART, FRACT_PART);
    return complex_diff;
  end function;

  function multiply_complex(c1, c2 : complex) return complex is
    variable complex_product : complex;
  begin
    complex_product.real := resize((c1.real * c2.real) - (c1.imag * c2.imag), INT_PART, FRACT_PART);
    complex_product.imag := resize((c1.real * c2.imag) + (c1.imag * c2.real), INT_PART, FRACT_PART);
    return complex_product;
  end function;

end complex_pkg;

