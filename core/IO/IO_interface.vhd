   --IO_sender_interface.vhd
   --情報科学科 05-151007 今井雄毅
   --Wed Dec  2 15:03:46 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library work;
use work.global_types.all;
package IO_interface is
  type IO_module_in_type is record
    serial_in:          std_logic;
    send_data:          std_byte;
    WE,RE:              std_logic;
  end record;
  type IO_module_out_type is record
    serial_out:         std_logic;
    recv_data:          std_byte;
    full,empty,spilled: std_logic;
  end record;

  constant IO_module_in_init:IO_module_in_type:=(
    serial_in=>'1',
    send_data=>x"00",
    we=>'0',
    re=>'0'
  );
  constant IO_module_out_init:IO_module_out_type:=(
    serial_out=>'1',
    recv_data=>x"00",
    full=>'0',
    empty=>'0',
    spilled=>'0'
  );
end package;
