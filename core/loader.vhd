   --loader.vhd
   --IS.S Imai Yuki
   --Sat Dec 12 19:28:35 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.global_types.all;

package loader_interface is
  type loader_in_type is record
   activate:boolean;
   ready:boolean;
   IO_data:word;
  end record;
  constant loader_in_init:loader_in_type:=(
    activate=>false,
    ready=>true,
    IO_data=>(others=>'0')
    );
  type loader_out_type is record
    data:word;
    mem_we:boolean;
    mem_addr:SRAM_ADDR_TYPE;
    inst_mem_we:boolean;
    inst_addr:inst_addr_type;
    loaded:boolean;
    init_information:init_information_type;
  end record;
  constant loader_out_init:loader_out_type:=(
    data=>(others=>'0'),
    mem_we=>false,
    inst_mem_we=>false,
    mem_addr=>(others=>'1'),
    inst_addr=>(others=>'1'),
    loaded=>false,
    init_information=>init_information_init
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
  subtype counter_type is unsigned(1 downto 0);
  type reg_type is record
    count:counter_type;
    PC:word;
    text_size:word;
    data_size:word;
    entry_point:word;
    state:state_type;
    port_out:loader_out_type;
  end record;
  constant r_init:reg_type :=(
    count=>(others=>'0'),
    PC=>RESIZE(USER_SECTION_OFFSET,WORD_SIZE),
    text_size=>(others=>'X'),
    data_size=>(others=>'X'),
    entry_point=>(others=>'X'),
    state=>init,
    port_out=>loader_out_init
    );
  signal r,rin:reg_type:=r_init;
begin
  comb:process(r,loader_in)
    variable v:reg_type;
  begin
    v:=r;
    --########################main logic########################
    case r.state is
      when init=>
        if loader_in.activate then
          v.state:=header;
        end if;
      when header=>
        if loader_in.ready then
          case r.count is
            when "00"=>
              v.count:=r.count+1;
            when "01"=>
              v.text_size:=loader_in.IO_data;
              v.count:=r.count+1;
            when "10"=>
              v.data_size:=loader_in.IO_data;
              v.count:=r.count+1;
            when "11"=>
              v.entry_point:=loader_in.IO_data;
              v.count:=(others=>'0');
              v.state:=text_recv;
            when others=>
              null;
          end case;
        else
        end if;
      when text_recv=>
        if loader_in.ready then
          v.port_out.inst_mem_we:=true;
          v.port_out.data:=loader_in.IO_data;
          v.port_out.inst_addr:=r.PC(INST_ADDR_SIZE-1 downto 0);
          v.PC:=r.PC+1;
          if r.PC=USER_SECTION_OFFSET+r.text_size-1 then
            v.state:=data_recv;
          end if;
        else
          v.port_out.inst_mem_we:=false;
        end if;
      when data_recv=>
        v.port_out.inst_mem_we:=false;
        if loader_in.ready then
          v.port_out.mem_we:=true;
          v.port_out.data:=loader_in.IO_data;
          v.port_out.mem_addr:=r.PC(SRAM_ADDR_SIZE-1 downto 0);
          v.PC:=r.PC+1;
          if r.PC=USER_SECTION_OFFSET+r.text_size+r.data_size-1 then
            v.state:=hlt;
          end if;
        else
          v.port_out.mem_we:=false;
        end if;
      when hlt=>
        v.port_out.mem_we:=false;
        v.port_out.inst_mem_we:=false;
        v.port_out.loaded:=true;
        v.port_out.init_information:=(
        init_PC=>r.entry_point,
        init_hp=>USER_SECTION_OFFSET+r.text_size+r.data_size
      );
    end case;
    rin<=v;
    loader_out<=r.port_out;
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
