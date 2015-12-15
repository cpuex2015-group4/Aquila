   --main.vhd
   --IS.S Imai Yuki
   --Tue Dec 15 13:16:45 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use global_types.all;

package main_interface is
  type main_in_type is record
    activate:boolean;
    Instruction:word;
    IO_full:boolean;
    IO_empty:boolean;
    IO_spilled:boolean;
    IO_data:word;
    Mem_data:word;
    Mem_hit:boolean;
    init_information;
  end record;
  constant main_in_init:main_in_type:=(
    activate=>false,
    Instruction=>(others=>'X'),
    IO_full=>false,
    IO_empty=>false,
    IO_spilled=>false,
    Mem_data=>(others=>'X'),
    Mem_hit=>false,
    init_information=>init_information_init
    );
  type main_out_type is record
    PC:word;
    Mem_addr:word;
    Mem_data:word;
    Mem_WE:boolean;
    Mem_RE:boolean;
    IO_data:word;
    IO_RE:boolean;
    IO_WE:boolean;
  end record;
  constant main_out_init:main_out_type:=(
    PC=>(others=>'X'),
    Mem_addr=>(others=>'X'),
    Mem_data=>(others=>'X'),
    Mem_WE=>false,
    Mem_RE=>false,
    IO_data=>(others=>'X'),
    IO_RE=>false,
    IO_WE=>false
    );
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.global_types.all;
use work.main_interface.all;

entity main is
  port(
    clk,rst:in  std_logic;
    port_in       :in  main_in_type;
    port_out      :out main_out_type
  );
end main;

architecture twoproc of main is
  --types and constants
  type state_type is (init,ready,running,hlt);
  type reg_type is record
    state:state_type;
    output:main_out_type;
    clk_count:unsigned(63 downto 0);
  end record;
  constant r_init:reg_type :=(
    state=>init,
    output=>main_out_init,
    clk_count=>0
    );
  signal r,rin:reg_type:=r_init;
begin
  comb:process(r,main_in)
    variable v:reg_type;
  begin
    v:=r;
    v.clk_count<=r.clk_count+to_unsigned(1,64);
    --########################main logic########################
    case r.state is
      when init=>
        if port_in.activate then
          v.state:=ready;
        end if;
      when ready=>
      when running=>
      when hlt=>
    end case;
    --######################## Out and rin######################
    r<=rin;
    port_out<=r.output;
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
