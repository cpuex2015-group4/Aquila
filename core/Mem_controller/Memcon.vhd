   --Memcon.vhd
   --IS.S 05-151007 Yuki Imai
   --Mon Dec  7 18:50:39 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.global_types.all;
use work.Memcon_interface.all;
entity Memcon is
  generic(wait_clks:integer:=2);
  port(
    clk,rst:            in      std_logic;
    Memcon_in:          in      Memcon_in_type;
    Memcon_out:         out     Memcon_out_type;
    SRAM_ZD:           inout    std_logic_vector(31 downto 0)
  );
end Memcon;

architecture twoproc of Memcon is
  --types and constants
  type snapshot is record
    WE:boolean;
    RE:boolean;
    ADDR:SRAM_addr_type;
    DATA:word;
  end record;
  constant snapshot_init:snapshot:=(
    WE=>false,
    RE=>false,
    ADDR=>(others=>'0'),
    DATA=>(others=>'0')
	 );

  type snaps_type is array(0 to wait_clks-1) of snapshot;
  constant snaps_init:snaps_type:=(others=>snapshot_init);

  type reg_type is record
    snaps:snaps_type;
    data_from_sram:word; -- sram kara no data ha ikkai kokoni uketekara tukau
    hit:boolean;
  end record;
  constant r_init:reg_type :=(
	snaps=>snaps_init,
	data_from_sram =>	(others=>'0'),
	hit =>false
	);

  signal r,rin:reg_type:=r_init;
begin
  comb:process(r,Memcon_in,SRAM_ZD)
   variable v:reg_type;
  begin
    v:=r;
    --########################main logic########################
    v.snaps(0).WE:=Memcon_in.WE;
    v.snaps(0).RE:=Memcon_in.RE;
    v.snaps(0).ADDR:=MEMCON_IN.ADDR;
    if memcon_in.we then
      v.snaps(0).DATA:=Memcon_in.input;
    else
      v.snaps(0).data:=(others=>'-');
    end if;
    for i in 0 to wait_clks-2 loop
      v.snaps(i+1):=r.snaps(i);
    end loop;

    v.hit:=r.snaps(wait_clks-1).re;
    if not r.snaps(wait_clks-1).we then
      v.data_from_sram:=unsigned(sram_zd);
      sram_zd<=(others=>'Z');
    else
      sram_zd<=std_logic_vector(r.snaps(wait_clks-1).data);
      v.data_from_sram:=(others=>'-');
    end if;
    rin<=v;
    memcon_out.sram_addr<=memcon_in.addr;
    memcon_out.sram_xwa<=not memcon_in.we;
    memcon_out.hit<=r.hit;
    memcon_out.output<=r.data_from_sram;

  end process;

  regs:process(clk,rst)
  begin
    if rst='1' then
      r<=r_init;
    elsif rising_edge(clk) then
      r<=rin;
    end if;
  end process;
end twoproc;
