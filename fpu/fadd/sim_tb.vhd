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
  signal dina      : std_logic_vector (31 downto 0) := (others => '0');
  signal dinb      : std_logic_vector (31 downto 0) := (others => '0');
  signal dout      : std_logic_vector (31 downto 0) := (others => '0');
  signal clk       : std_logic := '0';
  signal tb_output : std_logic_vector (31 downto 0) := (others => '0');
  file   infile    : TEXT open read_mode  is "sample.in";
  file   outfile   : TEXT open write_mode is "outfile.txt";
  component fadd port (
    ina : in  std_logic_vector (31 downto 0);
    inb : in  std_logic_vector (31 downto 0);
    output : out std_logic_vector (31 downto 0));
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
    variable vina    : std_logic_vector (31 downto 0) := (others => '0');
    variable vinb    : std_logic_vector (31 downto 0) := (others => '0');
    variable vout    : std_logic_vector (31 downto 0) := (others => '0');
  begin
      if rising_edge(clk) then
        readline(infile, vline);
        read(vline, vina);
        read(vline, vinb);
        read(vline, vout);
        dina <= vina;
        dinb <= vinb;
        dout <= vout;
      end if;
  end process;

  unit : fadd port map (
    ina => dina,
    inb => dinb,
    output => tb_output);

  writefile : process(clk)
    variable lo : line;
  begin
    if falling_edge(clk) then
      if not (tb_output = dout) then
        write(lo,dina,left,33);
        write(lo,dinb,left,33);
        write(lo,tb_output,left,33);
        write(lo,dout,left,32);
        writeline(outfile,lo);
      end if;
    end if;
  end process;
end;
