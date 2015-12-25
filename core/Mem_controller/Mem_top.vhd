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
use work.Memcon_interface.all;
use work.IO_interface.all;
entity Mem_top is
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
end Mem_top;

architecture ACTUAL_UNIT_TEST of Mem_top is
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

  component Memcon
    port(
      clk:in std_logic;
      rst:in std_logic;
      Memcon_in: in Memcon_in_type;
      Memcon_out: out Memcon_out_type;
      SRAM_ZD: inout std_logic_vector(31 downto 0)
    );
  end component;
--clk
  signal iclk,clk:std_logic;
--module
  signal IO_module_in:IO_module_in_type:=IO_module_in_init;
  signal IO_module_out:IO_module_out_type:=IO_module_out_init;
  signal Memcon_in:Memcon_in_type:=Memcon_in_init;
  signal Memcon_out:Memcon_out_type:=Memcon_out_init;

  signal serial_in_latch:std_logic;
  
-- make stimulate
  signal mem_addr:std_logic_vector(19 downto 0):=(others=>'0');
  type state_t is (ready,write_mem,send_mem,hlt);
  signal addr_phase : boolean:=true;
  signal state:state_t:=ready;
  constant addr_max:std_logic_vector(19 downto 0):=x"0000A";
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

--mem
  ZA<=std_logic_vector(Memcon_out.SRAM_addr);
  XWA<='1' when Memcon_out.SRAM_XWA else
        '0';

  RS_TX<=IO_module_out.serial_out;
  IO_module_in.serial_in<=serial_in_latch;
  process(clk)
  begin
    if falling_edge(clk) then
      serial_in_latch<=RS_RX;
      case state is
        when ready=>
          if mem_addr= x"00010" then
            mem_addr<=(others=>'0');
            state<=write_mem;
          else
            mem_addr<=std_logic_vector(unsigned(mem_addr)+x"00001");
          end if;
        when write_mem=>
--          IO_module_in.WE<='1';
          if mem_addr=addr_max then
            state<=send_mem;
            mem_addr<=(others=>'0');
          else
            mem_addr<=std_logic_vector(unsigned(mem_addr)+x"00001");
          end if;
          memcon_in.addr<=unsigned(mem_addr);
          memcon_in.input<=unsigned("000000000000" & mem_addr(19 downto 0));
          memcon_in.we<=true;
          memcon_in.re<=false;
        when send_mem=>
          memcon_in.we<=false;
          if addr_phase then
            IO_module_in.we<='0';
            memcon_in.addr<=unsigned(mem_addr);
            memcon_in.re<=true;
            addr_phase<=false;
          else
            memcon_in.re<=false;
            if memcon_out.hit then
              addr_phase<=true;
              IO_module_in.send_data<=std_logic_vector(memcon_out.output(7 downto 0));
              IO_module_in.we<='1';
              if mem_addr=addr_max then
                state<=hlt;
                mem_addr<=(others=>'0');
              else
                mem_addr<=std_logic_vector(unsigned(mem_addr)+x"00001");
              end if;
            end if;
          end if;
        when hlt=>
          IO_module_in.we<='0';
      --null;
      end case;
    end if;
  end process;
  ib: IBUFG port map(i=>MCLK1,o=>iclk);
  bg: BUFG port map(i=>iclk,o=>clk);
  IO :IO_module port map(
    clk=>clk,
    rst=>'0',
    IO_module_in=>IO_module_in,
    IO_module_out=>IO_module_out
    );

  MEM: Memcon port map(
      clk=>clk,
      rst=>'0',
      Memcon_in=>Memcon_in,
      Memcon_out=>Memcon_out,
      SRAM_ZD=>ZD
    );
  
end ACTUAL_UNIT_TEST;
