   --alu.vhd
   --IS.S Imai Yuki
   --Mon Dec 21 01:42:25 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.global_types.all;
use work.isa.all;

package alu_package is
  function ALU(operand1:word;operand2:word;control:alu_control_type) return word;
  --0 clk
end package;

package body alu_package is
  function ALU(operand1:word;operand2:word;control:alu_control_type) return word is
    variable result:word;
  begin
    result:=(others=>'-');
    case control is
      when alu_nop=>
        result:=operand1;
      when alu_add=>
        result:=operand1+operand2;
      when alu_sub=>
        result:=operand1-operand2;
      when alu_sll=>
        result:=operand1 sll to_integer(operand2);
      when alu_srl=>
        result:=operand1 srl to_integer(operand2);
      when others =>
        result:=(others=>'-');
    end case;
    return result;
  end function;
end alu_package;
