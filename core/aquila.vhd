library ieee;
use ieee.std_logic_1164.all;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.global_types.all;

entity top is
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
--  DEBUG :out top_debug_out
    );
end top;

architecture RTL of top is

  component IO32 
    port(
      clk,WE,RE:in                std_logic;
      send_data:in                std_logic_vector(31 downto 0);
      recv_data:out               std_logic_vector(31 downto 0);
      full,empty:out              std_logic;
      serial_send:out             std_logic;
      serial_recv:in              std_logic;
      word_access:in 				 std_logic
      );
  end component;
  component cpu 
    port (
      clk,IO_empty,IO_full: in std_logic;
      IO_recv_data: in std_logic_vector(31 downto 0);
      IO_WE,IO_RE: out std_logic;
      IO_send_data:out std_logic_vector(31 downto 0);
      word_access:out std_logic;
      SRAM_ADDR:out std_logic_vector(19 downto 0);
      SRAM_DATA:inout datat;
      SRAM_WE:out std_logic;
      DEBUG :out top_debug_out
      );
  end component;

--clk
  signal iclk:std_logic:='0';
  signal clk:std_logic:='0';

--core
  signal DEBUG_inner:top_debug_out;

begin
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
  --DEBUG<=DEBUG_inner;
  ib: IBUFG port map(
    i=>MCLK1,
    o=>iclk
    );
  bg:  BUFG port map(
    i=>iclk,
    o=>clk
    );


end RTL;
