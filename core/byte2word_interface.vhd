   --byte2word.vhd
   --IS.S Imai Yuki
   --Sun Dec 13 02:04:45 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use global_types.all;

package byte2word_interface is
  type byte2word_in_type is record
    activate:boolean;
    byte_data:byte;
    ready:boolean;
    RE:boolean;
  end record;
  constant byte2word_in_init:byte2word_in_type:=(
    activate=>false,
    byte_data=>(others=>'X'),
    ready=>false,
    RE=>false
    );
  type byte2word_out_type is record
    word_data:word;
    ready:boolean;
    IO_RE:boolean;
  end record;
  constant byte2word_out_init:byte2word_out_type:=(
    word_data=>(others=>'X'),
    ready=>false,
    IO_RE=>false
    );
end package;
