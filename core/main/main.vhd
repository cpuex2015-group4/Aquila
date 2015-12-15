   --main.vhd
   --IS.S Imai Yuki
   --Tue Dec 15 13:16:45 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.global_types.all;
use work.ISA.all;

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
    init_information:init_information_type;
  end record;
  constant main_in_init:main_in_type:=(
    activate=>false,
    Instruction=>(others=>'X'),
    IO_full=>false,
    IO_empty=>false,
    IO_spilled=>false,
	 IO_data=>(others=>'X'),
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
use work.ISA.all;

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

  type reg_file_t is array(0 to 31) of word;
  constant reg_file_init:reg_file_t:=(others=>(others=>'X'));

  type PC_reg_t is record
    PC:word;
  end record;
  constant PC_reg_init:PC_reg_t:=(
    PC=>(others=>'X')
  );

  type Fetch_reg_t is record
    PC:word;
    inst:word;
  end record;
  constant Fetch_reg_init:Fetch_reg_t:=(
    PC=>(others=>'X'),
    inst=>(others=>'X')
  );

  type Decode_reg_t is record
    PC:word;
  end record;
    constant Decode_reg_init:Decode_reg_t:=(
    PC=>(others=>'X')
  );
    type Exe_reg_t is record
      PC:word;
  end record;
    constant Exe_reg_init:Exe_reg_t:=(
    PC=>(others=>'X')
  );
  type WB_reg_t is record
    PC:word;
  end record;
    constant WB_reg_init:WB_reg_t:=(
    PC=>(others=>'X')
  );

  type reg_type is record
    state:state_type;
    output:main_out_type;
    regfile:reg_file_t;
    PC:PC_reg_t;
    F:Fetch_reg_t;
    D:Decode_reg_t;
    EX:Exe_reg_t;
    WB:WB_reg_t;
  end record;
  constant r_init:reg_type :=(
    state=>init,
    output=>main_out_init,
	 regfile=>reg_file_init,
    PC=>PC_reg_init,
    F=>Fetch_reg_init,
    D=>Decode_reg_init,
    EX=>EXe_reg_init,
    WB=>WB_reg_init
    );
  signal r,rin:reg_type:=r_init;
begin
  comb:process(r,port_in)
    variable v:reg_type;
  begin
    v:=r;
    --########################main logic########################
    case r.state is
      when init=>
        if port_in.activate then
          v.state:=ready;
        end if;
      when ready=>
        v.regfile(0):=(others=>'0');
        
        v.regfile(reg_heap):=port_in.init_information.init_hp;
        v.regfile(reg_stack):=RESIZE(SRAM_ADDR_MAX,32);
        v.PC.PC:=port_in.init_information.init_PC;
      when running=>
      when hlt=>
    end case;
    --######################## Out and rin######################
    rin<=v;
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
