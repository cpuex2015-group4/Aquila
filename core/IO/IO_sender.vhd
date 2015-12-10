   --IO_sender.vhd
   --情報科学科 05-151007 今井雄毅
   --Wed Dec  2 15:01:04 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library work;
use work.IO_inner_interface.all;
use work.global_types.all;

entity IO_sender is
  generic(
    section:std_logic_vector(15 downto 0)
    );
  port(
    clk,rst:in std_logic;
    IO_sender_in:in IO_sender_in_type;
    IO_sender_out:out IO_sender_out_type
  );
end IO_sender;

architecture ARCHITECTURE_NAME of IO_sender is
  type state_type is (IDLE,START_BIT,SENDING,STOP_BIT);

  type reg_type is record
    data:std_byte;
    FIFO_RE:std_logic;
    state:state_type;
    bit_count:std_logic_vector(2 downto 0);
    clk_count:std_logic_vector(15 downto 0);
    serial_out:std_logic;
  end record;
  --constants
  constant r_init:reg_type:=(
    data=>x"00",
    FIFO_RE=>'0',
    state=>IDLE,
    bit_count=>"000",
    clk_count=>x"0000",
    serial_out=>'1'
  );
  --initial_values

  --signals
  signal r,rin:reg_type:=r_init;
begin
  comb : process(r,io_sender_in)
    variable v:reg_type;
  begin
    v:=r;
    v.FIFO_RE:='0'; --RE resetted every clk 
    case r.state is
      when IDLE =>
        v.serial_out:='1';
        if io_sender_in.FIFO_empty='0' then    -- data fetching from FIFO
          v.data:=io_sender_in.data;
          v.FIFO_RE:='1';
          v.state:=START_BIT;
        end if;
      when START_BIT =>
        v.serial_out:='0';
        if r.clk_count>=section then
          v.clk_count:=x"0000";
          v.state:=SENDING;
        else
          v.clk_count:=r.clk_count+x"0001";
        end if;
      when SENDING =>
        v.serial_out:=r.data(CONV_INTEGER(r.bit_count));
        if r.clk_count>=section then --next state
          v.clk_count:=x"0000";
          if r.bit_count="111" then
            v.bit_count:="000";
            v.state:=STOP_BIT;
          else
            v.bit_count:=r.bit_count+"001";
          end if;
        else
          v.clk_count:=r.clk_count+x"0001";
        end if;
      when STOP_BIT =>
        v.serial_out:='1';
        if r.clk_count>=section then
          v.clk_count:=x"0000";
          v.state:=IDLE;
        else
          v.clk_count:=r.clk_count+x"0001";
        end if;
    end case;
    rin<=v;
    io_sender_out.serial_out<=r.serial_out;
    io_sender_out.FIFO_RE<=r.FIFO_RE;
  end process;

  regs : process(clk,rst)
  begin
    if rst='1' then
      r<=r_init;
    elsif rising_edge(clk) then
      r<=rin;
    end if;
  end process;
end ARCHITECTURE_NAME;
