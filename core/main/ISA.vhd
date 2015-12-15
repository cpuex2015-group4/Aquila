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

  subtype ope_type is unsigned(opt_size-1 downto 0);
  subtype reg_addr_type is unsigned(reg_addr_size-1 downto 0);
  subtype fct_type is unsigned(fct_size-1 downto 0);
  subtype opt_type is unsigned(opt_size-1 downto 0);
  subtype bit_image_type is unsigned(BRI_bit_image_size-1 downto 0);

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
  constant opt_shift:opt_type:=to_unsigned(3,opt_size);
  constant opt_invsqrt:opt_type:=to_unsigned(3,opt_size);

--rf
  constant rf_r:std_logic:='0';
  constant rf_f:std_logic:='1';

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
end package;
