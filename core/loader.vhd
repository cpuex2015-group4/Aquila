   --loader.vhd
   --IS.S Imai Yuki
   --Sat Dec 12 19:28:35 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use global_types.all;

package loader_interface is
  type loader_in_type is record
   activate:boolean;
   IO_empty:boolean;
   IO_data:word;
   PC:word;
  end record;
  constant loader_in_init:loader_in_type:=(
    activate=>false,
    IO_empty=>true,
    IO_data=>(others=>'0'),
    PC=>(others=>'0')
    );
  type loader_out_type is record
    data:word;
    IO_RE:boolean;
    mem_we:boolean;
    mem_addr:SRAM_ADDR_TYPE;
    inst_mem_we:boolean;
    inst_addr:inst_addr_type;
    loaded:boolean;
  end record;
  constant loader_out_init:loader_out_type:=(
    data=>(others=>'0'),
    IO_RE=>false,
    mem_we=>false,
    inst_mem_we=>false,
    mem_addr=>(others=>'1'),
    inst_addr=>(others=>'1'),
    loaded=>false
    );
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.global_types.all;
use work.loader_interface.all;

entity loader is
  port(
    clk,rst:in  std_logic;
    loader_in       :in  loader_in_type;
    loader_out      :out loader_out_type
  );
end loader;

architecture twoproc of loader is
  --types and constants
  type state_type is (init,header,text_recv,data_recv,hlt);
  constant counter_size:integer:= 10;
  subtype counter_type is unsigned(counter_size-1 downto 0);
  constant count_1:counter_type:=unsigned(counter_size-2 downto 0) & '1';
  type reg_type is record
    text_size:word;
    data_size:word;
    entry_point:word;
    state:state_type;
  end record;
  constant r_init:reg_type :=(
    text_size=>(others=>'X'),
    data_size=>(others=>'X'),
    entry_point=>(others=>'X'),
    state=>init
    );
  signal r,rin:reg_type:=r_init;
begin
  comb:process(r,loader_in)
    variable v:reg_type;
  begin
    v:=r;
    --########################main logic########################
    case state is
      when init=>
        if activate then
          v.state:=header;
        end if;
      when header=>
        if not loader_in.IO_empty then
          loader_out.IO_RE<=true;
          case count is
            when 0=>
              v.count<=r.count+count_1;
            when 1=>
              v.text_size:=loader_in.IO_data;
              v.count<=r.count+count_1;
            when 2=>
              v.data_size:=loader_in.IO_data;
              v.count<=r.count+count_1;
            when 3=>
              v.entry_point:=loader_in.IO_data;
              v.count<=(others=>'0');
              v.state<=text_recv;
          end case;
        else
          loader_out.IO_RE<=false;
        end if;
      when text_recv=>
        if not loader_in.IO_empty then
          loader_out.IO_RE<=true;
          loader_out.inst_mem_we<=true;
          loader_out.data<=loader_in.IO_data;
          loader_out.inst_addr<=r.PC(INST_ADDR_SIZE-1 downto 0);
          v.PC<=r.PC+1;
          if r.PC=r.text_size-1 then
            v.state<=data_recv;
          end if;
        else
          loader_out.IO_RE<=false;
          loader_out.inst_mem_we<=false;
        end if;
      when data_recv=>
        if not loader_in.IO_empty then
          loader_out.IO_RE<=true;
          loader_out.mem_we<=true;
          loader_out.data<=loader_in.IO_data;
          loader_out.inst_addr<=r.PC(SRAM_ADDR_SIZE-1 downto 0);
          v.PC<=r.PC+1;
          if r.PC=r.text_size+r.data_zise-1 then
            v.state<=hlt;
          end if;
        else
          loader_out.IO_RE<=false;
          loader_out.inst_mem_we<=false;
        end if;
      when hlt=>
        loader_out.IO_RE<=false;
        loader_out.mem_we<=false;
        loader_pit.inst_mem_we<=false;
        loader_out.loaded<=true;
    end case;
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
