LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
library std;
use std.textio.all;

entity top is
end top;

architecture testbench of top is
  constant step    : time := 5 ns;
  signal web       : std_logic := '0';
  signal din      : std_logic_vector (31 downto 0) := (others => '0');
  signal dout      : std_logic_vector (31 downto 0) := (others => '0');
  signal doutB     : std_logic_vector (31 downto 0) := (others => '0');
  signal clk       : std_logic := '0';
  signal tb_output : std_logic_vector (31 downto 0) := (others => '0');
  file   infile    : TEXT open read_mode  is "sample.in";
  file   outfile   : TEXT open write_mode is "outfile.txt";
  component finv port (
    input  : in  std_logic_vector (31 downto 0);
    output : out std_logic_vector (31 downto 0);
		clk    : in  std_logic);
  end component;

begin
  process begin
    clk <= '0';
    wait for step;
    clk <= '1';
    wait for step;
  end process;

  readfile : process (clk)
    variable vline   : line;
    variable vin    : std_logic_vector (31 downto 0) := (others => '0');
    variable vout    : std_logic_vector (31 downto 0) := (others => '0');
  begin
      if rising_edge(clk) then
        readline(infile, vline);
        read(vline, vin);
        read(vline, vout);
        din <= vin;
        dout <= vout;
        doutB<= dout;
      end if;
  end process;

  unit : finv port map (
    input => din,
    output => tb_output,
    clk    => clk);

  writefile : process(clk)
    variable lo : line;
  begin
    if rising_edge(clk) then
      if not (tb_output = doutB) then
        write(lo,din,left,33);
        write(lo,tb_output,left,33);
        write(lo,doutB,left,32);
        writeline(outfile,lo);
      end if;
    end if;
  end process;
end;
