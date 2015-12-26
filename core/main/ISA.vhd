--ISA.vhd
--Yuki Imai
--Tue Dec 15 22:55:50 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.global_types.all;

package ISA is
  constant ope_size:integer:=5;
  constant reg_addr_size:integer:=5;
  constant fct_size:integer:=10;
  constant opt_size:integer:=2;
  constant BRI_bit_image_size:integer:=2;
  constant immediate_size:integer:=16;

  subtype ope_type is unsigned(ope_size-1 downto 0);
  subtype reg_addr_type is unsigned(reg_addr_size-1 downto 0);
  subtype fct_type is unsigned(fct_size-1 downto 0);
  subtype opt_type is unsigned(opt_size-1 downto 0);
  subtype bit_image_type is unsigned(BRI_bit_image_size-1 downto 0);
  subtype immediate_type is unsigned(immediate_size-1 downto 0);

--RI/XS
  constant RI_R:std_logic:='0';
  constant RI_I:std_logic:='1';
  constant XS_X:std_logic:='0';
  constant XS_R:std_logic:='1';

--options
  constant opt_normal:opt_type:=to_unsigned(0,opt_size);
  constant opt_abs:opt_type:=to_unsigned(1,opt_size);
  constant opt_neg:opt_type:=to_unsigned(2,opt_size);
  constant jopt_nonlink:opt_type:=to_unsigned(0,opt_size);
  constant jopt_link:opt_type:=to_unsigned(1,opt_size);
  constant opt_B:opt_type:=to_unsigned(3,opt_size);
  constant opt_mem:opt_type:=to_unsigned(3,opt_size);
  constant opt_shiftinvsqrt:opt_type:=to_unsigned(3,opt_size);

--opecode X
  constant OP_X:ope_type:=(others=>'0');
--funct X
  constant OP_HLT:fct_type:=to_unsigned(0,fct_size);
  constant OP_NOP:fct_type:=to_unsigned(1,fct_size);
  constant OP_IN:fct_type:=to_unsigned(2,fct_size);
  constant OP_OUT:fct_type:=to_unsigned(3,fct_size);
  constant OP_ITOF:fct_type:=to_unsigned(4,fct_size);
  constant OP_FTOI:fct_type:=to_unsigned(5,fct_size);

--B bit image
  constant BEQ:bit_image_type:=to_unsigned(0,BRI_bit_image_size);
  constant BLT:bit_image_type:=to_unsigned(1,BRI_bit_image_size);
  constant BLE:bit_image_type:=to_unsigned(2,BRI_bit_image_size);

--RI bit image
  constant OP_ADD:bit_image_type:=to_unsigned(0,BRI_bit_image_size);
  constant OP_SUB:bit_image_type:=to_unsigned(1,BRI_bit_image_size);
  constant OP_MUL:bit_image_type:=to_unsigned(2,BRI_bit_image_size);
  constant OP_DIV:bit_image_type:=to_unsigned(3,BRI_bit_image_size);
  constant OP_JJAL:bit_image_type:=to_unsigned(2,BRI_bit_image_size);
  constant OP_JRJRAL:bit_image_type:=to_unsigned(3,BRI_bit_image_size);
  constant OP_LD:bit_image_type:=to_unsigned(0,BRI_bit_image_size);
  constant OP_ST:bit_image_type:=to_unsigned(1,BRI_bit_image_size);
  constant OP_SLL:bit_image_type:=to_unsigned(2,BRI_bit_image_size);
  constant OP_SRL:bit_image_type:=to_unsigned(3,BRI_bit_image_size);
  constant OP_INV:bit_image_type:=to_unsigned(2,BRI_bit_image_size);
  constant OP_SQRT:bit_image_type:=to_unsigned(3,BRI_bit_image_size);

-----------------------registers------------------------
  constant reg_rv:integer:=3;
  constant reg_ra:integer:=4;
  constant reg_heap:integer:=5;
  constant reg_closure:integer:=6;
  constant reg_stack:integer:=7;

----------------------functions--------------------------
  type format_type is (X,B,RI);
  type ALU_control_type is
    (alu_nop,alu_itof,alu_ftoi,
     alu_add,alu_fadd,alu_sub,alu_fsub,alu_fmul,alu_fdiv,alu_sll,alu_srl,alu_finv,alu_fsqrt);
  type data_src_type is (from_alu,from_fpu,from_MEM);
  type B_type is (B_BEQ,B_BLT,B_BLE,B_NOBRANCH);
  type inst_info_type is record
    format:format_type;
    OPecode:ope_type;
    opt:opt_type;
    isImmediate:boolean;
    isFPR:boolean;
    isJMP:boolean;
    isLNK:boolean;
    Branch:B_type;
    MEM_WE:boolean;
    MEM_RE:boolean;
    IO_WE:boolean;
    IO_RE:boolean;
    rd:reg_addr_type;
    rs:reg_addr_type;
    rt:reg_addr_type;
    reg_we:boolean;
    data_src:data_src_type;
    immediate:immediate_type;
    funct:fct_type;
    ALU:ALU_control_type;
    HLT:boolean;
  end record;

  constant inst_info_init:inst_info_type:=(
    format=>RI,
    OPecode=>(others=>'X'),
    opt=>(others=>'X'),
    isImmediate=>false,
    isFPR=>false,
    isJMP=>false,
    isLNK=>false,
    Branch=>B_NOBRANCH,
    MEM_WE=>false,
    MEM_RE=>false,
    IO_WE=>false,
    IO_RE=>false,
    rd=>(others=>'0'),
    rs=>(others=>'0'),
    rt=>(others=>'0'),
    reg_we=>false,
    data_src=>from_alu,
    immediate=>(others=>'X'),
    funct=>(others=>'0'),
    ALU=>ALU_NOP,
    HLT=>false
    );

  function Decode(inst:word) return inst_info_type;
end package;

package body ISA is
  function Decode(inst:word) return inst_info_type is
    variable info:inst_info_type;
    variable opt:opt_type;
    variable bit_image:bit_image_type;
  begin
    opt:=(others=>'X');
    info:=inst_info_init;
    info.HLT:=(inst=0);
    info.Opecode:=(inst(30 downto 26));
    bit_image:=inst(27 downto 26);
    info.rd:=inst(25 downto 21);
    info.rs:=inst(20 downto 16);
    info.rt:=inst(15 downto 11);
    info.funct:=inst(10 downto 1);
    info.immediate:=inst(15 downto 0);
    opt:=inst(29 downto 28);
    info.isImmediate:=to_boolean(inst(31));
    info.isFPR:=to_boolean(inst(30));
    if inst(31)='1' then
      info.format:=RI;
    elsif info.Opecode=0 and inst(0)='0' then
      info.format:=X;
    elsif opt=opt_b then
      case bit_image is
        when BEQ|BLT|BLE =>
          info.format:=B;
        when others=>
          info.format:=RI;
      end case;
    else
      info.format:=RI;
    end if;
    if info.format=B then
      case bit_image is
        when BEQ=>
          info.Branch:=B_BEQ;
        when BLT=>
          info.branch:=B_BLT;
        when BLE=>
          info.branch:=B_BLE;
        when others=>
          info.branch:=B_NOBRANCH;
      end case;
    end if;
    info.Mem_WE:=(info.format=RI) and opt=opt_mem and bit_image=OP_ST;
    info.Mem_RE:=(info.format=RI) and opt=opt_mem and bit_image=OP_LD;
    if info.Mem_RE then
      info.data_src:=from_Mem;
    end if;
    info.IO_WE:=(info.format=X) and info.funct= OP_OUT;
    info.IO_RE:=(info.format=X) and info.funct=OP_IN;

    case info.format is
      when X=>
        case info.funct is
          when OP_ITOF=>
            info.ALU:=ALU_itof;
            info.data_src:=from_fpu;
          when OP_FTOI=>
            info.ALU:=ALU_ftoi;
            info.data_src:=from_fpu;
          when others=>
            info.ALU:=ALU_NOP;
        end case;
      when B=>
        info.ALU:=ALU_NOP;
      when RI=>
        if opt=opt_shiftinvsqrt and not(info.isFPR) then
          case bit_image is
            when OP_SLL =>
              info.ALU:=ALU_SLL;
            when OP_SRL =>
              info.ALU:=ALU_SRL;
            when others=>
              info.ALU:=ALU_NOP;
          end case;
        else
          if info.isFPR then
            info.data_src:=from_fpu;
            case bit_image is
              when OP_ADD =>
                info.ALU:=ALU_FADD;
              when OP_SUB =>
                info.ALU:=ALU_FSUB;
              when OP_MUL =>
                info.ALU:=ALU_FMUL;
              when OP_DIV =>
                info.ALU:=ALU_FDIV;
              when others=>
                info.ALU:=ALU_NOP;
            end case;
          else
            case bit_image is
              when OP_ADD=>
                info.ALU:=ALU_ADD;
              when OP_SUB =>
                info.ALU:=ALU_SUB;
             when OP_JJAL =>
                info.isJMP:=true;
                info.isImmediate:=true;
                info.isLNK:=(opt=jopt_link);
              when OP_JRJRAL=>
                info.isJMP:=true;
                info.islnk:=(opt=jopt_link);					 
              when others=>
                info.ALU:=ALU_NOP;
            end case;
          end if;
        end if;
    end case;

    return info;
  end function;
end ISA;
