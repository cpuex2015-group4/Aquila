   --main.vhd
   --IS.S Imai Yuki
   --Tue Dec 15 13:16:45 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.global_types.all;
use work.ISA.all;
use work.alu_package.all;

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
    output:main_out_type;
    regfile:reg_file_t;
    fregfile:reg_file_t;
    F:Fetch_reg_t;
    D:Decode_reg_t;
    EX:Exe_reg_t;
    WB:WB_reg_t;
  end record;
  constant r_init:reg_type :=(
    state=>init,
    output=>main_out_init,
    regfile=>reg_file_init,
    fregfile=>reg_file_init,
    F=>Fetch_reg_init,
    D=>Decode_reg_init,
    EX=>EXe_reg_init,
    WB=>WB_reg_init
    );
  signal r,rin:reg_type:=r_init;
begin
  comb:process(r,port_in)
    variable v:reg_type;
    variable vnextPC:word;
    variable inst_info:inst_info_type;
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
        v.output:=main_out_init;
        --F
--        v.F.PC:=r.F.PC+1;
        --D
        v.D.NOP:=r.f.nop;
        v.D.PC:=r.F.PC;
        if r.D.NOP then
          inst_info:=v.D.inst_info;
          v.d.instruction:=v.d.instruction;
        else
          inst_info:=Decode(port_in.instruction);
          v.d.instruction:=port_in.instruction;
        end if;
        v.d.hlt:=inst_info.hlt or r.d.hlt;
        v.D.inst_info:=inst_info;


        if v.d.inst_info.rd/=0 and v.d.inst_info.rd= r.ex.inst_info.rd and r.ex.inst_info.format/=B then
          v.d.compared:=r.ex.result;
        else
          v.d.compared:=r.regfile(to_integer(inst_info.rd));
        end if;
        if v.d.inst_info.rs/=0 and v.d.inst_info.rs= r.ex.inst_info.rd and r.ex.inst_info.format/=B  then
          v.d.operand1:=r.ex.result;
        else
          v.D.operand1:=r.regfile(to_integer(inst_info.rs));
        end if;

        if inst_info.isimmediate then
          v.D.operand2:=unsigned(resize(signed(inst_info.immediate),word_size));
        else
          if v.d.inst_info.rt/=0 and v.d.inst_info.rt= r.ex.inst_info.rd and r.ex.inst_info.format/=B  then
            v.D.operand2:=r.ex.result;
          else
            v.D.operand2:=r.regfile(to_integer(inst_info.rt));
          end if;
        end if;

        if inst_info.isJMP then
          v.f.pc:=v.d.operand2;
        elsif inst_info.format=B then
          case inst_info.Branch is
            when B_BEQ=>
              if v.d.compared=v.d.operand1 then
                v.f.pc:=unsigned(signed(r.f.pc)+resize(signed(inst_info.immediate),word_size));
              else
                v.f.pc:=r.f.pc+1;
              end if;
            when B_BLT=>
              if signed(v.d.compared)<signed(v.d.operand1) then
                v.f.pc:=unsigned(signed(r.f.pc)+resize(signed(inst_info.immediate),word_size));
              else
                v.f.pc:=r.f.pc+1;
              end if;
            when B_BLE=>
              if signed(v.d.compared)<=signed(v.d.operand1) then
                v.f.pc:=unsigned(signed(r.f.pc)+resize(signed(inst_info.immediate),word_size));
              else
                v.f.pc:=r.f.pc+1;
              end if;
            when B_NOBRANCH=>
              v.f.pc:=r.f.pc+1;
          end case;
        else
          v.f.pc:=r.f.pc+1;
        end if;
        if inst_info.isLNK then
          v.regfile(reg_ra):=r.f.PC+1;
        end if;
        if inst_info.IO_RE then
          if port_in.IO_empty then
            v.output.PC:=r.output.PC;
            v.F:=r.F;
            v.D.NOP:=true;
          else
            v.output.IO_RE:=true;
            v.D.IO_input:=port_in.IO_data;
          end if;
        end if;

        -----------Ex------------------------------------------
        --Forwading
        if  r.d.inst_info.rs=0 then
          v.ex.operand1:=to_unsigned(0,word_size);
        elsif r.d.inst_info.rs=r.ex.inst_info.rd then
          v.ex.operand1:=r.ex.result;
        else
          v.ex.operand1:=r.d.operand1;
        end if;
        if  r.d.inst_info.rt=0 and not r.d.inst_info.isimmediate then
          v.ex.operand2:=to_unsigned(0,word_size);
        elsif r.d.inst_info.rt=r.ex.inst_info.rd and not r.d.inst_info.isimmediate then
          v.ex.operand2:=r.ex.result;
        else
          v.ex.operand2:=r.d.operand2;
        end if;

        --main
        v.ex.hlt:=r.d.hlt;
        v.Ex.NOP:=r.D.NOP;
        v.Ex.PC:=r.D.PC;
        v.ex.inst_info:=r.d.inst_info;

        --main
        if r.d.inst_info.IO_RE then
          v.ex.result:=r.d.IO_input;
        else
          V.ex.result:=alu(v.ex.operand1,v.ex.operand2,v.ex.inst_info.alu);
        end if;
        ---------Wb------------------------------------------
        if r.ex.hlt then
          v.state:=hlt;
        end if;

        v.Wb.NOP:=r.Ex.NOP;
        if r.ex.nop then
          null;
        else
         if r.ex.inst_info.IO_WE then
           if port_in.IO_full then
             v.output.PC:=r.output.PC;
             v.F:=r.F;
             v.D.NOP:=true;
           else
             v.output.IO_WE:=true;
             v.output.IO_data:=r.Ex.result;
           end if;
         end if;

         if r.Ex.inst_info.format/=B then
           v.regfile(to_integer(r.Ex.inst_info.rd)):=r.Ex.result;
         end if;
        end if;
      when hlt=>
    end case;

    v.regfile(0):=to_unsigned(0,word_size);
    --######################## Out and rin######################
    rin<=v;
    port_out<=r.output;
    port_out.PC<=v.F.PC;
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
