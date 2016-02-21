--Memcon.vhd
--IS.S 05-151007 Yuki Imai
--Mon Dec  7 18:50:39 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.global_types.all;
use work.Memcon_interface.all;
use work.cache_interface.all;
entity Memcon is
  generic(wait_clks:integer:=2);
  port(
    clk,rst:            in      std_logic;
    Memcon_in:          in      Memcon_in_type;
    Memcon_out:         out     Memcon_out_type;
    SRAM_ZD:           inout    std_logic_vector(31 downto 0)
    );
end Memcon;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.global_types.all;
use work.Memcon_interface.all;
use work.cache_interface.all;
architecture twoproc of Memcon is
  --types and constants
  component cache is
    port(
      clk,rst:in  std_logic;
      port_in       :in  cache_in_type;
      port_out      :out cache_out_type
      );
  end component;


  type snap_type is record
    input:word;
    re:boolean;
    we:boolean;
  end record;
  constant snap_init:snap_type:=(
    input=>(others=>'X'),
    re=>false,
    we=>false
    );

  type snaps_type is array(0 to 2) of snap_type;
  type reg_type is record
    snaps:snaps_type;
    data_from_sram:word; -- sram kara no data ha ikkai kokoni uketekara tukau
    hit:boolean;
  end record;
  constant r_init:reg_type :=(
    snaps=>(others=>snap_init),
    data_from_sram =>	(others=>'0'),
    hit =>false
    );

  signal r,rin:reg_type:=r_init;
  signal cache_in:cache_in_type:=cache_in_init;
  signal cache_out:cache_out_type:=cache_out_init;
begin
  CH:cache port map(clk=>clk,rst=>rst,port_in=>cache_in,port_out=>cache_out);
  cache_in.addr<=memcon_in.addr;
  cache_in.data<=memcon_in.input;
  cache_in.we<=memcon_in.we;
  cache_in.re<=memcon_in.re;
  comb:process(r,Memcon_in,SRAM_ZD,cache_out)
    variable v:reg_type;
  begin
    v:=r;
    v.snaps(0).input:=memcon_in.input;
    v.snaps(0).re:=memcon_in.re;
    v.snaps(0).we:=memcon_in.we;
    v.snaps(1):=r.snaps(0);
    v.snaps(2):=r.snaps(1);

    if r.snaps(1).re then
      cache_in.data_from_mem<=unsigned(sram_zd);
      v.data_from_sram:=unsigned(sram_zd);
    else
      cache_in.data_from_mem<=(others=>'0');
      v.data_from_sram:=(others=>'X');
    end if;
    --###################outputs
    if cache_out.hit then
      v.snaps(1).re:=false;
      memcon_out.output<=cache_out.data;
      memcon_out.hit<=true;
    else
      memcon_out.output<=r.data_from_sram;
      memcon_out.hit<=r.snaps(2).re;
    end if;
    if memcon_in.re or memcon_in.we then
      memcon_out.sram_addr<=memcon_in.addr;
    else
      memcon_out.sram_addr<=(others=>'0');
    end if;
    if r.snaps(1).we then
      sram_zd<=std_logic_vector(r.snaps(1).input);
    else
      sram_zd<=(others=>'Z');
    end if;
    memcon_out.sram_xwa<=not memcon_in.we;
    rin<=v;
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
