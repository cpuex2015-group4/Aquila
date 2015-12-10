--IO_module.vhd
--情報科学科 05-151007 今井雄毅
--Wed Dec  2 17:13:16 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library work;
use work.global_types.all;
use work.IO_interface.all;
use work.IO_inner_interface.all;
entity IO_module is
  generic(
    section:std_logic_vector(15 downto 0)
    );
  port(
    clk:in std_logic;
    rst:in std_logic;
    IO_module_in:in IO_module_in_type;
    IO_module_out:out IO_module_out_type
    );
end IO_module;

architecture RTL of IO_module is
  --components
  component IO_FIFO
    port(
      clk     : in    std_logic;
      rst     : in    std_logic;
      wr_en   : in    std_logic;
      rd_en   : in    std_logic;
      din     : in    std_logic_vector( 7 downto 0);
      dout    : out   std_logic_vector( 7 downto 0);
      full    : out   std_logic;
      empty   : out   std_logic
      );
  end component;
  --signals
  component IO_sender
    generic(
      section:std_logic_vector(15 downto 0):=section
      );
    port(
      clk,rst:in std_logic;
      IO_sender_in:in IO_sender_in_type;
      IO_sender_out:out IO_sender_out_type
      );
  end component;

  component IO_receiver
    generic(
      section:std_logic_vector(15 downto 0):=section
      );
    port(
      clk,rst:in std_logic;
      IO_receiver_in:in IO_receiver_in_type;
      IO_receiver_out:out IO_receiver_out_type
      );
  end component;

  signal spilled,spilled_in:std_logic:='0';
  signal recv_full:std_logic:='0';
  signal IO_sender_in:IO_sender_in_type;
  signal IO_receiver_in:IO_receiver_in_type;
  signal IO_sender_out:IO_sender_out_type;
  signal IO_receiver_out:IO_receiver_out_type;

begin

  SND:IO_sender port map(
    clk=>clk,
    rst=>rst,
    IO_sender_in=>IO_sender_in,
    IO_sender_out=>IO_sender_out
    );

  RCV:IO_receiver port map(
    clk=>clk,
    rst=>rst,
    IO_receiver_in=>IO_receiver_in,
    IO_receiver_out=>IO_receiver_out
    );

  
  SEND_FIFO:IO_FIFO port map(
    clk         =>clk,
    rst         =>rst,
    wr_en       =>IO_module_in.WE,
    rd_en       =>IO_sender_out.FIFO_RE,
    din         =>IO_module_in.send_data,
    dout        =>IO_sender_in.data,
    full        =>IO_module_out.full,
    empty       =>IO_sender_in.FIFO_empty
    );

  RECV_FIFO:IO_FIFO port map(
    clk         =>clk,
    rst         =>rst,
    wr_en       =>IO_receiver_out.FIFO_WE,
    rd_en       =>IO_module_in.RE,
    din         =>IO_receiver_out.data,
    dout        =>IO_module_out.recv_data,
    full        =>recv_full,
    empty       =>IO_module_out.empty
    );

  IO_module_out.serial_out<=IO_sender_out.serial_out;
  IO_receiver_in.serial_in<=IO_module_in.serial_in;
  comb:process(recv_full,spilled)
  begin
    spilled_in<=spilled or recv_full;
  end process;
  regs:process(clk,rst)
  begin
    if rst='1' then
      spilled<='0';
    elsif rising_edge(clk) then
      spilled<=spilled_in;
    end if;
  end process;
end RTL;
