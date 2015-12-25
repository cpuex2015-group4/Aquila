--IO_receiver.vhd
--情報科学科 05-151007 今井雄毅
--Fri Dec  4 02:37:12 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library work;
use work.IO_inner_interface.all;
use work.global_types.all;

entity IO_receiver is
  generic(section:std_logic_vector(15 downto 0));
  port(
    clk,rst:in std_logic;
    IO_receiver_in:in IO_receiver_in_type;
    IO_receiver_out:out IO_receiver_out_type
    );
end IO_receiver;

architecture twoproc of IO_receiver is
  type state_type is(IDLE,START_BIT,RECEIVING,STOP_BIT);
  constant half_section:std_logic_vector(15 downto 0):='0' & section(15 downto 1);
  type reg_type is record
    data:std_byte;
    state:state_type;
    bit_count:std_logic_vector(2 downto 0);
    clk_count:std_logic_vector(15 downto 0);
    FIFO_WE:std_logic;
  end record;

  constant r_init: reg_type :=(
    data=>x"00",
    state=>IDLE,
    bit_count=>"000",
    clk_count=>x"0000",
    FIFO_WE=>'0'
    );

  signal r,rin:reg_type:=r_init;
begin
  comb : process(r,IO_receiver_in)
    variable v:reg_type;
  begin
    v:=r;
    v.FIFO_WE:='0';
    case (r.state) is
      when IDLE =>
        if IO_receiver_in.serial_in='0' then
          v.state:=START_BIT;
        end if;
      when START_BIT =>
        if r.clk_count>=section then
          v.clk_count:=x"0000";
          v.state:=RECEIVING;
        else
          v.clk_count:=r.clk_count+x"0001";
        end if;
      when RECEIVING =>
        if r.clk_count>=section then
          v.clk_count:=x"0000";
          if r.bit_count="111" then
            v.bit_count:="000";
            v.state:=STOP_BIT;
          else
            v.bit_count:=r.bit_count+"001";
          end if;
        else
          v.clk_count:=r.clk_count+x"0001";
          if r.clk_count=half_section then
            v.data(CONV_INTEGER(r.bit_count)):=IO_receiver_in.serial_in;
          end if;
        end if;
      when STOP_BIT =>
        if r.clk_count=half_section then
          v.state:=IDLE;
          v.FIFO_WE:='1';
          v.clk_count:=x"0000";
        else
          v.clk_count:=r.clk_count+x"0001";
        end IF;
    end case;

    rin<=v;
    IO_receiver_out.data<=r.data;
    IO_receiver_out.FIFO_WE<=r.FIFO_WE;
  end process;

  regs : process(clk,rst)
  begin
    if rst='1' then
      r<=r_init;
    elsif rising_edge(clk) then
      r<=rin;
    end if;
  end process;
end twoproc;
