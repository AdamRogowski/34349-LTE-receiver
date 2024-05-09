library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.STD_LOGIC_UNSIGNED.all; -- for std_logic_vector incrementation
  use work.complex_pkg.all;
  use work.utilities_pkg.all;

entity fft is
  generic (FFT_SIZE : positive := 2048);
  port (clk           : in  std_logic;
        reset         : in  std_logic;
        enable        : in  std_logic;
        input_symbol  : in  complex;
        output_symbol : out complex;
        -- indicates when output symbols are ready to read
        output_ready  : out std_logic);
end entity;

architecture Behavioral of fft is

  constant nr_of_stages : natural := log_2(FFT_SIZE);
  -- array representing the bus connecting interfaces of the stages
  type stages_bus_array is array (nr_of_stages downto 0) of complex;
  signal stages_bus : stages_bus_array := (others => to_complex(0.0, 0.0));

  -- control signal for simultaneous control of all stages
  -- NOTE: MSB of the vector controls the 1st stage
  --       with a stage phase swap frequency of FFT_SIZE/2 clock cycles (time to fill up the shift register)
  --       2nd MSB controls the 2nd stage with a stage phase swap frequency of FFT_SIZE/4 clock cycles,
  --       and so on...
  --       LSB controls the last stage with a stage phase swap frequency of 1 clock cycle for radix-2 FFT
  signal control_signal : std_logic_vector(nr_of_stages - 1 downto 0) := (others => '0');

begin

  -- Incrementing std_logic_vector has desired proprty
  -- Example for 3-bit vector, where frequencies 4*f1 = 2*f2 = f3:
  --       f1 f2 f3
  --       0  0  0
  --       0  0  1
  --       0  1  0
  --       0  1  1
  --       1  0  0
  --       1  0  1
  --       1  1  0
  --       1  1  1
  increment_CS: process (clk)
  begin
    if reset = '1' then
      control_signal <= (others => '0');
    elsif enable = '1' then
      if falling_edge(clk) then
        control_signal <= control_signal + 1;
      end if;
    end if;
  end process;

  output_ready_assignment: process (clk)
    variable global_cnt : natural := 0;
  begin
    if rising_edge(clk) then
      global_cnt := global_cnt + 1;
      -- first output symbol is ready after 2nd phase of the first stage
      if global_cnt > FFT_SIZE - 1 and global_cnt < 2 * FFT_SIZE - 1 then
        output_ready <= '1';
      else
        output_ready <= '0';
      end if;

    end if;
  end process;

  -- instantiate stages, where output of the previous stage is input of the next stage
  stage11: entity work.stage
    generic map (FFT_SIZE, 2 ** 11)
    port map (clk, reset, enable, control_signal(10), stages_bus(11), stages_bus(10));
  stage10: entity work.stage
    generic map (FFT_SIZE, 2 ** 10)
    port map (clk, reset, enable, control_signal(9), stages_bus(10), stages_bus(9));
  stage9: entity work.stage
    generic map (FFT_SIZE, 2 ** 9)
    port map (clk, reset, enable, control_signal(8), stages_bus(9), stages_bus(8));
  stage8: entity work.stage
    generic map (FFT_SIZE, 2 ** 8)
    port map (clk, reset, enable, control_signal(7), stages_bus(8), stages_bus(7));
  stage7: entity work.stage
    generic map (FFT_SIZE, 2 ** 7)
    port map (clk, reset, enable, control_signal(6), stages_bus(7), stages_bus(6));
  stage6: entity work.stage
    generic map (FFT_SIZE, 2 ** 6)
    port map (clk, reset, enable, control_signal(5), stages_bus(6), stages_bus(5));
  stage5: entity work.stage
    generic map (FFT_SIZE, 2 ** 5)
    port map (clk, reset, enable, control_signal(4), stages_bus(5), stages_bus(4));
  stage4: entity work.stage
    generic map (FFT_SIZE, 2 ** 4)
    port map (clk, reset, enable, control_signal(3), stages_bus(4), stages_bus(3));
  stage3: entity work.stage
    generic map (FFT_SIZE, 2 ** 3)
    port map (clk, reset, enable, control_signal(2), stages_bus(3), stages_bus(2));
  stage2: entity work.stage
    generic map (FFT_SIZE, 2 ** 2)
    port map (clk, reset, enable, control_signal(1), stages_bus(2), stages_bus(1));
  stage1: entity work.stage
    generic map (FFT_SIZE, 2 ** 1)
    port map (clk, reset, enable, control_signal(0), stages_bus(1), stages_bus(0));

  stages_bus(11) <= input_symbol;
  output_symbol  <= stages_bus(0);

end architecture;
