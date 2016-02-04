   --main.vhd
   --IS.S Imai Yuki
   --Tue Dec 15 13:16:45 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.global_types.all;
use work.ISA.all;
use work.staller.all;
use work.alu_package.all;
use work.fpu_interface.all;

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
    Mem_addr:SRAM_ADDR_TYPE;
    Mem_data:word;
    Mem_WE:boolean;
    Mem_RE:boolean;
    IO_data:word;
    IO_RE:boolean;
    IO_WE:boolean;
  end record;
  constant main_out_init:main_out_type:=(
    PC=>(others=>'1'),
    Mem_addr=>(others=>'1'),
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
use work.alu_package.all;
use work.fpu_interface.all;

entity main is
  port(
    clk,rst:in  std_logic;
    port_in       :in  main_in_type;
    port_out      :out main_out_type
  );
end main;

architecture twoproc of main is
  --component
  component fpu
  port(
    clk,rst:in  std_logic;
    port_in       :in  fpu_in_type;
    port_out      :out fpu_out_type
  );
  end component;

  --types and constants
  type state_type is (init,ready,running,hlt);

  type reg_file_t is array(0 to 31) of word;
  constant reg_file_init:reg_file_t:=(others=>(others=>'X'));


  type Fetch_reg_t is record
    PC:word;
    NOP:boolean;
  end record;
  constant Fetch_reg_init:Fetch_reg_t:=(
    PC=>(others=>'X'),
    NOP=>true
  );

  type Decode_reg_t is record
    PC:word;
    instruction:word;
    inst_info:inst_info_type;
    compared:word;
    operand1:word;
    operand2:word;
    Mem_addr:SRAM_ADDR_TYPE;
    IO_input:word;
    NOP:boolean;
    HLT:boolean;
  end record;
    constant Decode_reg_init:Decode_reg_t:=(
      PC=>(others=>'X'),
      instruction=>(others=>'X'),
      inst_info=>inst_info_init,
      compared=>(others=>'X'),
      operand1=>(others=>'X'),
      operand2=>(others=>'X'),
      Mem_addr=>(others=>'0'),
      IO_input=>(others=>'X'),
      NOP=>true,
      HLT=>false
  );
    type Exe_reg_t is record
      PC:word;
      inst_info:inst_info_type;
      instruction:word;
      compared:word;
      operand1:word;
      operand2:word;
      result:word;
      NOP:boolean;
      HLT:boolean;
  end record;
    constant Exe_reg_init:Exe_reg_t:=(
    PC=>(others=>'X'),
    instruction=>(others=>'X'),
    inst_info=>inst_info_init,
    compared=>(others=>'X'),
    result=>(others=>'X'),
    operand1=>(others=>'X'),
    operand2=>(others=>'X'),
    NOP=>true,
    HLT=>false
  );
  type WB_reg_t is record
    PC:word;
    NOP:boolean;
  end record;
    constant WB_reg_init:WB_reg_t:=(
    PC=>(others=>'X'),
    NOP=>true
  );

  type reg_type is record
    state:state_type;
    regfile:reg_file_t;
    fregfile:reg_file_t;
    F:Fetch_reg_t;
    D:Decode_reg_t;
    EX:Exe_reg_t;
    WB:WB_reg_t;
    --to debug
    clk_count:dword;
  end record;
  constant r_init:reg_type :=(
    state=>init,
    regfile=>reg_file_init,
    fregfile=>reg_file_init,
    F=>Fetch_reg_init,
    D=>Decode_reg_init,
    EX=>EXe_reg_init,
    WB=>WB_reg_init,
    clk_count=>(others=>'0')
    );
  signal r,rin:reg_type:=r_init;
  signal fpu_input:fpu_in_type:=fpu_in_init;
  signal fpu_output:fpu_out_type:=fpu_out_init;
begin
  FPU_UNIT:fpu port map(clk,rst,fpu_input,fpu_output);
  comb:process(r,port_in,fpu_output)
    variable v:reg_type;
    variable vnextPC:word;
    variable inst_info:inst_info_type;
    variable result:word;
  begin
    v:=r;
    vnextPC:=(others=>'X');
    inst_info:=inst_info_init;
    --########################main logic########################
    case r.state is
      when init=>
        if port_in.activate then
          v.state:=ready;
        end if;
      when ready=>
        v.regfile(0):=(others=>'0');
        v.fregfile(0):=(others=>'0');
        v.regfile(reg_heap):=port_in.init_information.init_hp;
        v.regfile(reg_stack):=RESIZE(SRAM_ADDR_MAX,32);
        v.F.PC:=port_in.init_information.init_PC-1;
        v.F.Nop:=false;
        v.state:=running;
      when running=>

        v.regfile(0):=(others=>'0');
        v.fregfile(0):=(others=>'0');
      when hlt=>
    end case;

   --######################## Out and rin######################
    --update
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
