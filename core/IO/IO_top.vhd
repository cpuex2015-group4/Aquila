--IO_top.vhd
--情報科学科 05-151007 今井雄毅
--Fri Dec  4 04:17:22 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.global_types.all;
use work.IO_interface.all;
entity IO_top is
  port(
    MCLK1:in std_logic;
    RS_RX:in std_logic;
    RS_TX:out std_logic
  );
end IO_top;

architecture ACTUAL_UNIT_TEST of IO_top is
  component IO_module
    generic(
      section:std_logic_vector(15 downto 0):=IO_section
      );
    port(
      clk:in std_logic;
      rst:in std_logic;
      IO_module_in:in IO_module_in_type;
      IO_module_out:out IO_module_out_type
      );
  end component;

--constants

  --initial_values

  --components

  --signals
--clk
  signal iclk,clk:std_logic;
--module
  signal IO_module_in:IO_module_in_type:=IO_module_in_init;
  signal IO_module_out:IO_module_out_type:=IO_module_out_init;
-- input latch
  signal serial_in_latch:std_logic;
begin
  process(clk)
  begin
    serial_in_latch<=RS_RX;
  end process;
  ib: IBUFG port map(i=>MCLK1,o=>iclk);
  bg: BUFG port map(i=>iclk,o=>clk);
  IO :IO_module port map(
    clk=>clk,
    rst=>'0',
    IO_module_in=>IO_module_in,
    IO_module_out=>IO_module_out
    );

  IO_module_in.serial_in<=serial_in_latch;
  IO_module_in.send_data<=IO_module_out.recv_data;
  IO_module_in.we<=not IO_module_out.empty;
  IO_module_in.re<=not IO_module_out.empty;
  RS_TX<=IO_module_out.serial_out;
end ACTUAL_UNIT_TEST;
