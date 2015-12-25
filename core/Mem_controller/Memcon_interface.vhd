   --Memcon_interface.vhd
   --情報科学科 05-151007 Yuki Imai
   --Mon Dec  7 18:51:47 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.global_types.all;

package Memcon_interface is
  type Memcon_in_type is record
    addr                : sram_addr_type;
    input               : word;
    WE                  : boolean;
    RE                  : boolean;
  end record;
  type Memcon_out_type is record
    output              : word;
    hit                 : boolean;
    SRAM_addr           : sram_addr_type;
    SRAM_XWA            : boolean;
  end record;
  constant Memcon_in_init:Memcon_in_type:=(
    addr=>(others=>'U'),
    input=>(others=>'U'),
    WE=>false,
    RE=>false
  );
  constant Memcon_out_init:Memcon_out_type:=(
    output=>(others=>'U'),
    hit=>false,
    SRAM_addr=>(others=>'U'),
    SRAM_XWA=>true
  );
end package;
