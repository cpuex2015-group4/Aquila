--cache.vhd
--IS.S Imai Yuki
--Sun Feb 21 23:13:46 2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.global_types.all;

package cache_interface is
  constant Cache_way:integer:=4;
  constant Cache_line:integer:=1024;
  constant Cache_line_bits:integer:=10;--1024ライン

  type cache_in_type is record
    addr:sram_addr_type;
    data:word;
    data_from_mem:word;
    WE:boolean;
    RE:boolean;
  end record;
  constant cache_in_init:cache_in_type:=(
    addr=>(others=>'0'),
    data=>(others=>'-'),
    data_from_mem=>(others=>'-'),
    WE=>false,
    RE=>false
    );
  type cache_out_type is record
    hit:boolean;
    data:word;
  end record;
  constant cache_out_init:cache_out_type:=(
    hit=>false,
    data=>(others=>'-')
    );

end package;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.global_types.all;
use work.cache_interface.all;

entity cache is
  port(
    clk,rst:in  std_logic;
    port_in       :in  cache_in_type;
    port_out      :out cache_out_type
    );
end cache;

architecture twoproc of cache is
  --types and constants
  type way_type is record
    valid:boolean;
    addr:unsigned(SRAM_ADDR_SIZE-Cache_line_bits-1 downto 0);
    data:word;
  end record;
  constant way_init:way_type:=(
    valid=>false,
    addr=>(others=>'0'),
    data=>(others=>'-')
    );

  subtype order_type is integer range 0 to 3;
  type ways_type is array(0 to cache_way-1) of way_type;
  type orders_type is array(0 to 3) of order_type;
  type line_type is record
    ways:ways_type;
    orders:orders_type;
  end record;
  constant line_init:line_type:=(
    ways=>(others=>way_init),
    orders=>(0,1,2,3)
    );
  type Cache_type is array (0 to  cache_line-1) of line_type;
  constant cache_init:Cache_type:=(others=>line_init);

  type state_type is (free,wait1,wait2);
  type reg_type is record
    state:state_type;
    lower_addr:unsigned(9 downto 0);
    next_line:line_type;
    output:word;
    hit:boolean;
  end record;
  constant r_init:reg_type :=(
    state=>free,
    lower_addr=>(others=>'0'),
    next_line=>line_init,
    output=>(others=>'-'),
    hit=>false
    );
  signal r,rin:reg_type:=r_init;
  signal reg_cache:cache_type:=cache_init;

begin
  comb:process(r,port_in)
    variable v:reg_type;
    variable this_line:line_type;
    variable the_way:way_type;
    variable next_line:line_type;
  begin
    v:=r;
    this_line:=reg_cache(to_integer(port_in.addr(9 downto 0)));
    next_line:=this_line;
    --########################main logic########################

    case r.state is
      when free =>
        --hitの判定。順位の決定
        if port_in.we or port_in.re then
          if port_in.addr(19 downto 10) =
            this_line.ways(this_line.orders(0)).addr and this_line.ways(this_line.orders(0)).valid then
         elsif port_in.addr(19 downto 10) =
            this_line.ways(this_line.orders(1)).addr  and this_line.ways(this_line.orders(1)).valid then
              next_line.orders(0):=this_line.orders(1);
              next_line.orders(1):=this_line.orders(0);
              next_line.orders(2):=this_line.orders(2);
              next_line.orders(3):=this_line.orders(3);
         elsif port_in.addr(19 downto 10) =
            this_line.ways(this_line.orders(2)).addr  and this_line.ways(this_line.orders(2)).valid then
              next_line.orders(0):=this_line.orders(2);
              next_line.orders(1):=this_line.orders(0);
              next_line.orders(2):=this_line.orders(1);
              next_line.orders(3):=this_line.orders(3);
         elsif port_in.addr(19 downto 10) =
            this_line.ways(this_line.orders(3)).addr  and this_line.ways(this_line.orders(3)).valid then
              next_line.orders(0):=this_line.orders(3);
              next_line.orders(1):=this_line.orders(0);
              next_line.orders(2):=this_line.orders(1);
              next_line.orders(3):=this_line.orders(2);
         else
              next_line.orders(0):=this_line.orders(3);
              next_line.orders(1):=this_line.orders(0);
              next_line.orders(2):=this_line.orders(1);
              next_line.orders(3):=this_line.orders(2);
              next_line.ways(next_line.orders(0)).valid:=false;
          end if;
          the_way:=next_line.ways(next_line.orders(0));
          if port_in.we then
            the_way.valid:=true;
            the_way.addr:=port_in.addr(19 downto 10);
            the_way.data:=port_in.data;
          else--  port_in.reです
            if the_way.valid then
              v.output:=the_way.data;
            else
              v.state:=wait1;
              v.output:=(others=>'-');
            end if;
          end if;
          next_line.ways(next_line.orders(0)):=the_way;
        end if;
      when wait1=>
        v.state:=wait2;
      when wait2=>
        the_way:=next_line.ways(next_line.orders(0));
        the_way.valid:=true;
        the_way.addr:=port_in.addr(19 downto 10);
        the_way.data:=port_in.data_from_mem;
        next_line.ways(next_line.orders(0)):=the_way;
        v.state:=free;
    end case;
    v.next_line:=next_line;
    v.lower_addr:=port_in.addr(9 downto 0);
    v.hit:=port_in.re and the_way.valid;
    --######################## Out and rin######################
    rin<=v;
    port_out.data<=r.output;
    port_out.hit<=r.hit;
    reg_cache(to_integer(r.lower_addr))<=r.next_line;
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
