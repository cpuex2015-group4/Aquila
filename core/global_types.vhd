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

  constant ISROM:boolean:=false;
  constant CLK_LENGTH:time:=15ns;
  constant WORD_SIZE:integer:=32;
  constant BYTE_SIZE:integer:=8;
  constant DOUBLE_WORD_SIZE:integer:=64;
  constant SRAM_ADDR_SIZE:integer:=20;
  constant INST_ADDR_SIZE:integer:=15;
  subtype INST_ADDR_TYPE is unsigned(INST_ADDR_SIZE-1 downto 0);
  subtype byte is unsigned(7 downto 0);
  subtype word is unsigned(31 downto 0);
  subtype dword is unsigned(DOUBLE_WORD_SIZE-1 downto 0);
  subtype std_byte is std_logic_vector(BYTE_SIZE-1 downto 0);
  subtype std_word is std_logic_vector(WORD_SIZE-1 downto 0);
  subtype SRAM_ADDR_TYPE is unsigned(SRAM_ADDR_SIZE-1 downto 0);

  constant INST_ADDR_MAX:INST_ADDR_TYPE:=(others=>'1');
  constant SRAM_ADDR_MAX:SRAM_ADDR_TYPE:=(others=>'1');
  constant USER_SECTION_OFFSET:SRAM_ADDR_TYPE:=x"00400";
  constant IO_section_time:time:=to_integer(unsigned(IO_section))*CLK_LENGTH;

  type init_information_type is record
    init_PC:word;
    init_hp:word;
  end record;
  constant init_information_init:init_information_type:=(
    init_PC=>(others=>'X'),
    init_hp=>(others=>'X')
    );

  function to_boolean(A:std_logic) return boolean;
  function to_std_logic(A:boolean) return std_logic;
end package;

package body global_types is
  function to_boolean(A:std_logic) return boolean is
  begin
    return A='1';
  end function;

  function to_std_logic(A:boolean) return std_logic is
	variable v:std_logic;
  begin
    if A then 
		v:='1';
	else 
		v:='0';
	end if;
	return v;
  end function;
end global_types;
