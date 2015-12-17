   --byte2word.vhd
   --IS.S Imai Yuki
   --Sun Dec 13 02:04:45 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.global_types.all;

package byte2word_interface is
  type byte2word_in_type is record
    activate:boolean;
    byte_data:byte;
    ready:boolean;
  end record;
  constant byte2word_in_init:byte2word_in_type:=(
    activate=>false,
    byte_data=>(others=>'X'),
    ready=>false
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.global_types.all;
use work.byte2word_interface.all;

entity byte2word is
  port(
    clk,rst:in  std_logic;
    byte2word_in       :in  byte2word_in_type;
    byte2word_out      :out byte2word_out_type
    );
end byte2word;

architecture twoproc of byte2word is
  --types and constants

  type reg_type is record
    word_data:word;
    ready:boolean;
    has_read_count:unsigned(1 downto 0);
    port_out:byte2word_out_type;
  end record;
  constant r_init:reg_type :=(
    word_data=>(others=>'-'),
    ready=>false,
    has_read_count=>"00",
    port_out=>byte2word_out_init
    );
  signal r,rin:reg_type:=r_init;
begin
  comb:process(r,byte2word_in)
    variable v:reg_type;
  begin
    if byte2word_in.activate then
      v:=r;
      --########################main logic########################
      if r.ready then
        v.port_out.IO_RE:=false;
        v.port_out.word_data:=(others=>'X');
        v.port_out.ready:=false;
        v.ready:=false;
      else
        if byte2word_in.ready and not(r.port_out.IO_RE) then
          v.port_out.IO_RE:=true;
          v.word_data(31-8*to_integer(r.has_read_count)
                      downto 24-8*to_integer(r.has_read_count))
            :=byte2word_in.byte_data;

          if r.has_read_count=3 then
            v.has_read_count:=(others=>'0');
            v.ready:=true;
            v.port_out.ready:=true;
            v.port_out.word_data:=v.word_data;
          else
            v.has_read_count:=r.has_read_count+"01";
          end if;
        else
          v.port_out.IO_RE:=false;
        end if;
      end if;
      --######################## Out and rin######################
      rin<=v;
      byte2word_out<=r.port_out;
    else
      byte2word_out<=byte2word_out_init;
    end if;
  end process;

  regs:process(clk,rst)
  begin
    if rst='1' then
      r<=r_init;
    elsif rising_edge(clk) then
      r<=rin;
    end if;
  end process;
end twoproc;
