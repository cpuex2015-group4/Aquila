--main.vhd
--IS.S Imai Yuki
--Tue Dec 15 13:16:45 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.global_types.all;
use work.ISA.all;
use work.staller_interface.all;
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
use work.staller_interface.all;
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

  component staller
    port(
      clk,rst:in  std_logic;
      port_in       :in  staller_in_type;
      port_out      :out staller_out_type
      );
  end component;

  --types and constants
  type state_type is (init,ready,running,hlt);

  type reg_file_t is array(0 to 31) of word;
  constant reg_file_init:reg_file_t:=(others=>(others=>'X'));


  type Fetch_reg_t is record
    PC:word;
  end record;
  constant Fetch_reg_init:Fetch_reg_t:=(
    PC=>(others=>'X')
    );

  type Decode_reg_t is record
    PC:word;
    inst_info:inst_info_type;
    jmp_addr:word;
  end record;
  constant Decode_reg_init:Decode_reg_t:=(
    PC=>(others=>'X'),
    inst_info=>inst_info_init,
    JMP_ADDR=>(others=>'X')
    );
  type Exe_reg_t is record
    PC:word;
    inst_info:inst_info_type;
    BranchTaken:boolean;
    Branch_addr:word;
    operand1:word;
    operand2:word;
    Mem_addr:word;
    Mem_data:word;
    IO_data:word;
    result:word;
  end record;
  constant Exe_reg_init:Exe_reg_t:=(
    PC=>(others=>'X'),
    inst_info=>inst_info_init, 
    BranchTaken=>false,
    branch_addr=>(others=>'X'),
    result=>(others=>'X'),
    operand1=>(others=>'X'),
    operand2=>(others=>'X'),
    Mem_addr=>(others=>'0'),
    IO_data=>(others=>'X'),
    Mem_data=>(others=>'X')
    );
  type WB_reg_t is record
    PC:word;
    inst_info:inst_info_type;
    Is_Ex_Mem_data_saved:boolean;  --stallでタイミングが狂った時に必要。高々一つ確保しておけば問題なし。
    Ex_Mem_data:word;
    result:word;
  end record;
  constant WB_reg_init:WB_reg_t:=(
    PC=>(others=>'X'),
    inst_info=>inst_info_init,
    Is_Ex_Mem_data_saved=>false,
    Ex_Mem_data=>(others=>'X'),
    result=>(others=>'X')
    );

  type reg_type is record
    state:state_type;
    regfile:reg_file_t;
    fregfile:reg_file_t;
    F:Fetch_reg_t;
    D:Decode_reg_t;
    EX:Exe_reg_t;
    WB:WB_reg_t;
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
  signal stall_in:staller_in_type:=staller_in_init;
  signal stall_out:staller_out_type:=staller_out_init;
begin
  FPU_UNIT:fpu port map(clk,rst,fpu_input,fpu_output);
  STALLER_unit:staller port map(clk,rst,stall_in,stall_out);
  comb:process(r,port_in,fpu_output,stall_out)
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
        v.fregfile(0):=(others=>'0');
        v.regfile(reg_heap):=port_in.init_information.init_hp;
        v.regfile(reg_stack):=RESIZE(SRAM_ADDR_MAX,32);
        v.F.PC:=port_in.init_information.init_PC-1;
        v.state:=running;
      when running=>
        v.clk_count:=r.clk_count+1;
        --************************WB**********************
        if r.ex.inst_info.hlt then
          v.state:=hlt;
        end if;

        --hazard chcek
        if (port_in.IO_empty and r.ex.inst_info.IO_RE) or
          (r.ex.inst_info.Mem_RE and not(port_in.Mem_hit)) then
          stall_in.wb_hazzard<=true;
          v.wb.inst_info:=inst_nop;
        else
          stall_in.wb_hazzard<=false;
          v.wb.inst_info:=r.ex.inst_info;
        end if;
        --/hazzard check 終わり

        --resultを決定する
        case v.wb.inst_info.data_src is
          when from_alu|from_fpu=>
            v.wb.result:=r.ex.result;
          when from_mem=>
            v.wb.result:=port_in.mem_data;
          when from_IO=>
            v.wb.result:=port_in.IO_data;
        end case;

        if r.ex.inst_info.reg_we then
          v.regfile(to_integer(r.ex.inst_info.rd)):=v.wb.result;
        end if;

        if r.ex.inst_info.isLNK then
          v.regfile(reg_link):=r.ex.PC+1;
        end if;
        --************************Ex**********************

        --hazzard check
        stall_in.ex_hazzard<=(r.d.inst_info.data_src=from_fpu)and
                              not fpu_output.data_ready;
        --/hazzard check 終わり
        v.Ex.PC:=r.D.PC;
        v.EX.inst_info:=r.d.inst_info;
        v.ex.operand1:=v.regfile(to_integer(r.d.inst_info.rs)); --ココらへんはそのうちforwarderに投げる
        if r.d.inst_info.isImmediate then
          v.ex.operand2:=resize(r.d.inst_info.immediate,32);
        else
          v.ex.operand2:=v.regfile(to_integer(r.d.inst_info.rt));
        end if;
        case r.d.inst_info.data_src is
          when from_alu=>
            v.ex.result:=alu(v.ex.operand1,v.ex.operand2,r.d.inst_info.alu);
          when from_fpu=>
            v.ex.result:=fpu_output.result;
          when others=>
            v.ex.result:=(others=>'-');
        end case;

        --分岐方向を確定させる
        v.ex.BranchTaken:=IsBranch(v.regfile(to_integer(r.d.inst_info.rd)),v.ex.operand1,r.d.inst_info.branch);
        if v.ex.BranchTaken then
          v.ex.branch_addr:=unsigned(
            signed(v.ex.PC)+
            resize(signed(v.ex.inst_info.immediate),32)
            );
        else
          v.ex.branch_addr:=(others=>'X');
        end if;

        if v.ex.inst_info.mem_re or v.ex.inst_info.mem_we then  --memory 入出力
          v.ex.mem_addr:=unsigned(
            signed(v.regfile(to_integer(r.d.inst_info.rs)))+
            resize(signed(r.d.inst_info.immediate),32));
        else
          v.ex.mem_addr:=(others=>'0');
        end if;

        if v.ex.inst_info.IO_we then
          v.ex.io_data:=v.ex.operand1;
        end if;
        --************************D***********************
        --この stage は分岐予測の失敗で潰れうる
        if v.ex.BranchTaken then
          --分岐が成立時
          --予測失敗しているのでこのステージをNOPに差し替える。
          v.D.PC:=(others=>'X');
          v.D.inst_info:=inst_nop;
        else--非分岐。予測成功。
          v.D.PC:=r.F.PC;
          v.D.inst_info:=Decode(port_in.instruction);
        end if;
        if v.d.inst_info.isImmediate then
          v.d.jmp_addr:=resize(v.d.inst_info.immediate,32);
        else
          v.d.jmp_addr:=v.regfile(to_integer(v.d.inst_info.rt));
        end if;
        --************************F***********************
        --decide next F

        if v.D.inst_info.isJMP then
          v.F.PC:=v.d.jmp_addr;
        elsif v.Ex.BranchTaken then
          v.F.PC:=v.ex.branch_addr;
        else
          v.F.PC:=r.F.PC+1;
        end if;

        --************************************************
        v.regfile(0):=(others=>'0');
        v.fregfile(0):=(others=>'0');
      when hlt=>
    end case;

    --######################## Out and rin######################

    --output and update
    rin.state<=v.state;
    rin.clk_count<=v.clk_count;
    --from stage-F
    if stall_out.f_stall then
      rin.F<=r.F;
      port_out.PC<=r.F.PC;
    else
      rin.F<=v.F;
      port_out.PC<=v.F.PC;
    end if;
    --from stage-D
    if stall_out.d_stall then
      rin.D<=r.D;
    else
      rin.D<=v.D;
    end if;
    --from stage-Ex
    if stall_out.ex_stall then
      rin.Ex<=r.Ex;
      port_out.Mem_addr<=(others=>'1');
      port_out.Mem_data<=(others=>'X');
      port_out.Mem_we<=false;
      port_out.Mem_re<=false;
      port_out.IO_data<=(others=>'X');
      port_out.IO_RE<=false;
      port_out.IO_WE<=false;
    else
      rin.Ex<=v.Ex;
      port_out.Mem_addr<=resize(v.ex.mem_addr,20);
      port_out.Mem_data<=v.ex.mem_data;
      port_out.Mem_we<=v.ex.inst_info.mem_we;
      port_out.Mem_re<=v.ex.inst_info.mem_re;
      port_out.IO_data<=v.ex.IO_data;
      port_out.IO_RE<=v.ex.inst_info.IO_re;
      port_out.IO_WE<=v.ex.inst_info.IO_we;

      fpu_input.alu_control<=v.ex.inst_info.alu;
      if v.ex.inst_info.data_src=from_fpu then
        fpu_input.operand1<=v.ex.operand1;
        fpu_input.operand2<=v.ex.operand2;
      else
        fpu_input.operand1<=(others=>'0');
        fpu_input.operand2<=(others=>'0');
      end if;
    end if;
    --from stage-Wb
    if stall_out.wb_stall then
      rin.Wb<=r.Wb;
      rin.regfile<=r.regfile;
    else
      rin.Wb<=v.Wb;
      rin.regfile<=v.regfile;
    end if;
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
