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

  type snapshot is record
    XWA:std_logic;
    ADDR:std_logic_vector(19 downto 0);
  end record;
  constant snapshot_init:snapshot:=(
    XWA=>'1',
    ADDR=>(others=>'U')
    );
  type snaps_type is array(0 to 1) of snapshot;
  type reg_type is record
    snap:snaps_type;
  end record;
  constant r_init:reg_type:=(
    snap=>(others=>snapshot_init)
    );
  signal r,rin:reg_type:=r_init;
  signal mem:memt:=(others=>x"FFFFFFFF");
begin

  comb:process(r,ZD,ZA,XWA)
    variable v:reg_type;
  begin
    v:=r;
    v.snap(0).XWA:=XWA;
    v.snap(0).ADDR:=ZA;
    v.snap(1):=r.snap(0);

    if r.snap(1).XWA='0' then --WE だったら
      mem(to_integer(unsigned(r.snap(1).addr)))<=ZD;
      ZD<=(others=>'Z');
    else
      ZD<=std_logic_vector(mem(to_integer(unsigned(r.snap(1).addr))));
    end if;


    rin<=v;
  end process;

  regs:process(clk)
  begin
    if rising_edge(clk) then
      r<=rin;
    end if;
  end process;

end behavior;
