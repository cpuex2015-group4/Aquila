   --fpu.vhd
   --IS.S Imai Yuki
   --Sat Dec 26 16:56:58 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.global_types.all;
use work.ISA.all;
package fpu_interface is
  type fpu_in_type is record
    ALU_control:ALU_control_type;
    operand1:word;
    operand2:word;
  end record;
  constant fpu_in_init:fpu_in_type:=(
    ALU_control=>ALU_nop,
    operand1=>(others=>'0'),
    operand2=>(others=>'0')
    );
  type fpu_out_type is record
    result:word;
    data_ready:boolean;
  end record;
  constant fpu_out_init:fpu_out_type:=(
    result=>(others=>'X'),
    data_ready=>false
    );
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.global_types.all;
use work.ISA.all;
use work.fpu_interface.all;

entity fpu is
  port(
    clk,rst:in  std_logic;
    port_in       :in  fpu_in_type;
    port_out      :out fpu_out_type
  );
end fpu;

architecture twoproc of fpu is
  --components
  component fadd
    Port (
      clk : in  std_logic;
      ina : in  STD_LOGIC_VECTOR (31 downto 0);
      inb : in  STD_LOGIC_VECTOR (31 downto 0);
      output : out STD_LOGIC_VECTOR (31  downto 0));
  end component;
  component fmul
    Port (
      inputA : in  std_logic_vector (31 downto 0);
      inputB : in  std_logic_vector (31 downto 0);
      output : out std_logic_vector (31 downto 0));
  end component;
  component finv
    port (
      clk    : in  std_logic;
      input  : in  std_logic_vector (31 downto 0);
      output : out std_logic_vector (31 downto 0));
  end component;
--  component ftoi
--    Port (
--      clk    : in  std_logic;
--      input  : in  STD_LOGIC_VECTOR (31 downto 0);
--      output : out STD_LOGIC_VECTOR (31 downto 0);
--      flag   : out STD_LOGIC_VECTOR ( 1 downto 0)); -- underflow / overflow
--  end component;


  --types and constants
  type state_type is (init,ready,hlt);
  type reg_type is record
    state:state_type;
    output:fpu_out_type;
    ex_input:fpu_in_type;
  end record;
  constant r_init:reg_type :=(
    state=>init,
    output=>fpu_out_init,
    ex_input=>fpu_in_init
    );
  signal r,rin:reg_type:=r_init;
  type result_type is record
    add:std_word;
    mul:std_word;
    inv:std_word;
    f2i:std_word;
    i2f:std_word;
  end record;
  constant result_init:result_type:=(
    add=>(others=>'X'),
    mul=>(others=>'X'),
    inv=>(others=>'X'),
    f2i=>(others=>'X'),
    i2f=>(others=>'X')
  );
  signal result:result_type:=result_init;
  signal fadd_operand:word:=(others=>'X');
  signal ftoiflag:STD_LOGIC_VECTOR(1 downto 0);
begin
  fadd_operand<=(not port_in.operand2(31)) &  port_in.operand2(30 downto 0) when port_in.ALU_control= alu_fsub else
                 port_in.operand2;
  FD:fadd port map(clk,std_logic_vector(port_in.operand1),std_logic_vector(fadd_operand),result.add);
  FM:fmul port map(std_logic_vector(port_in.operand1),std_logic_vector(port_in.operand2),result.mul);
  FI:finv port map(clk,std_logic_vector(port_in.operand1),result.inv);
--  F2I:ftoi port map(clk,std_logic_vector(port_in.operand1),result.f2i,ftoiflag);
--  I2F:itof port map(clk,std_logic_vector(port_in.operand1),result.i2f);

  with (port_in.ALU_control) select
  port_out.result<=unsigned(result.add)  when alu_fadd |alu_fsub,
                    unsigned(result.mul) when alu_fmul,
                    unsigned(result.inv) when alu_finv,
                    unsigned(result.f2i) when alu_ftoi,
                    unsigned(result.i2f) when alu_itof,
                    port_in.operand1 when others;

  proc:process(r,port_in)
  begin
    rin.ex_input<=port_in;
    port_out.data_ready<=(port_in=r.ex_input);
  end process;

  regs:process(clk,rst)
  begin
    if rising_edge(clk) then
      r<=rin;
    end if;
  end process;
end twoproc;
