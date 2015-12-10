   --global_types.vhd
   --IS.S 05-151007 Imai Yuki
   --Tue Dec  1 16:04:31 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package global_types is
--  constant IO_section:std_logic_vector(15 downto 0):=x"1b16";
--  constant IO_section:std_logic_vector(15 downto 0):=x"1b20";-- 9600 66MHz
  constant IO_section:std_logic_vector(15 downto 0):=x"0243";-- 115200 66MHz
--  constant IO_section:std_logic_vector(15 downto 0):=x"0121";-- 230400 66MHz
                                                             -- doesn't work
--  constant IO_section:std_logic_vector(15 downto 0):=x"0091";-- 460800 66MHz
                                                             -- doesn't work
  constant SRAM_ADDR_SIZE:integer:=20;
  subtype byte is unsigned(7 downto 0);
  subtype word is unsigned(31 downto 0);
  subtype std_byte is std_logic_vector(7 downto 0);
  subtype std_word is std_logic_vector(31 downto 0);
  subtype SRAM_ADDR_TYPE is unsigned(SRAM_ADDR_SIZE-1 downto 0);
end package;
