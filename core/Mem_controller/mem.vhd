   --mem.vhd
   --IS.S 05-151007 Imai Yuki
   --Tue Dec  8 22:00:10 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.global_types.all;

entity mem is
  port(
    ZD    : inout std_logic_vector(31 downto 0):=(others=>'Z');
    ZA    : in   std_logic_vector(19 downto 0);
    XWA   : in   std_logic;
    clk   : in   std_logic
  );
end mem;

architecture behavior of mem is
  --types and constants
  subtype mem_data_t is std_logic_vector(31 downto 0);
  type memt is array(0 to to_integer(SRAM_ADDR_MAX)) of mem_data_t;
  signal test_mem:memt:=(others=>x"FFFFFFFF");
  type snapshot is record
    XWA:std_logic;
    ADDR:std_logic_vector(19 downto 0);
  end record;
  constant snapshot_init:snapshot:=(
    XWA=>'1',
    ADDR=>(others=>'U')
  );

  type snaps_type is array(0 to 1) of snapshot;
  signal snaps:snaps_type:=(others=>snapshot_init);
begin
  process(clk)
  begin
    if rising_edge(clk) then
      snaps(0).xwa<=xwa;
      snaps(0).addr<=za;
      snaps(1)<=snaps(0);
      if snaps(0).xwa='1' then -- read from the mem mode
        zd<=test_mem(to_integer(unsigned(snaps(0).addr)));
      else
        zd<=(others=>'Z');
      end if;
      if snaps(1).xwa='0' then
        test_mem(to_integer(unsigned(snaps(1).addr)))<=zd;
      end if;
    end if;
  end process;
end behavior;
