--IO_top.vhd
--情報科学科 05-151007 今井雄毅
--Fri Dec  4 04:17:22 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.global_types.all;
use work.IO_interface.all;
use work.byte2word_interface.all;
--use work.loader_interface.all;

entity aquila is
  port (
    MCLK1 : in    std_logic;
    RS_RX : in    std_logic;
    RS_TX : out   std_logic;
    ZD    : inout std_logic_vector(31 downto 0);
    ZA    : out   std_logic_vector(19 downto 0);
    XWA   : out   std_logic;
    XE1   : out   std_logic;
    E2A   : out   std_logic;
    XE3   : out   std_logic;
    XGA   : out   std_logic;
    XZCKE : out   std_logic;
    ADVA  : out   std_logic;
    XLBO  : out   std_logic;
    ZZA   : out   std_logic;
    XFT   : out   std_logic;
    XZBE  : out   std_logic_vector(3 downto 0);
    ZCLKMA : out std_logic_vector(1 downto 0)
  );
end aquila;

architecture ACTUAL_UNIT_TEST of aquila is
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
--  component loader
--    port(
--      clk,rst:in  std_logic;
--      loader_in       :in  loader_in_type;
--      loader_out      :out loader_out_type
--      );
--  end component;

  component byte2word
    port(
      clk,rst :in std_logic;
      byte2word_in: in byte2word_in_type;
      byte2word_out:out byte2word_out_type
      );
  end component;
--clk
  signal iclk,clk:std_logic;
--module
  signal IO_module_in:IO_module_in_type:=IO_module_in_init;
  signal IO_module_out:IO_module_out_type:=IO_module_out_init;
--  signal loader_in:loader_in_type:=loader_in_init;
--  signal loader_out:loader_out_type:=loader_out_init;
   signal byte2word_in:byte2word_in_type:=byte2word_in_init;
  signal byte2word_out:byte2word_out_type:=byte2word_out_init;
-- input latch
  signal serial_in_latch:std_logic;
begin
--templates
  XE1<='0';
  E2A<='1';
  XE3<='0';
  XGA<='0';
  XZCKE<='0';
  ADVA<='0';
  XLBO<='1';
  ZZA<='0';
  XFT<='1';
  XZBE<="0000";
  ZCLKMA <=clk & clk;

--ignores
  ZD<=(others=>'Z');
  ZA<=(others=>'0');
  XWA<='1';



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
--  LD:loader port map(
--    clk=>clk,
--    rst=>'0',
--    loader_in=>loader_in,
--    loader_out=>loader_out
--    );
  B2W:byte2word port map(
    clk=>clk,
    rst=>'0',
    byte2word_in=>byte2word_in,
    byte2word_out=>byte2word_out
    );
  byte2word_in.activate<=true;
  byte2word_in.byte_data<=unsigned(IO_module_out.recv_data);
  byte2word_in.ready<= false when IO_module_out.empty='1' else
                    true;
  byte2word_in.RE<=true;
  IO_module_in.serial_in<=serial_in_latch;
  IO_module_in.send_data<=IO_module_out.recv_data;
  IO_module_in.we<=not IO_module_out.empty;
  IO_module_in.re<=not IO_module_out.empty;
  RS_TX<=IO_module_out.serial_out;
end ACTUAL_UNIT_TEST;
