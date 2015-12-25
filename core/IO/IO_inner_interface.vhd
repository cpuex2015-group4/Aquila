   --IO_sender_interface.vhd
   --情報科学科 05-151007 今井雄毅
   --Wed Dec  2 15:03:46 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.global_types.all;
package IO_inner_interface is
  type IO_sender_in_type is record
    FIFO_empty:std_logic;
    data:std_byte;
  end record;
  type IO_sender_out_type is record
    serial_out:std_logic;
    FIFO_RE:std_logic;
  end record;

  type IO_receiver_in_type is record
    serial_in:std_logic;
  end record;
  type IO_receiver_out_type is record
    data:std_byte;
    FIFO_WE:std_logic;
  end record;
end package;
