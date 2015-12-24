--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   04:18:45 12/13/2015
-- Design Name:   
-- Module Name:   /home/yukiimai/Sandbox/2015_winter/Aquila/core/aquila_tb.vhd
-- Project Name:  aquila
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: aquila
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.global_types.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
entity aquila_tb is
end aquila_tb;
 
architecture behavior of aquila_tb is 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component aquila
    port(
         MCLK1 : in  std_logic;
         RS_RX : in  std_logic;
         RS_TX : out  std_logic;
         ZD : inout  std_logic_vector(31 downto 0);
         ZA : out  std_logic_vector(19 downto 0);
         XWA : out  std_logic;
         XE1 : out  std_logic;
         E2A : out  std_logic;
         XE3 : out  std_logic;
         XGA : out  std_logic;
         XZCKE : out  std_logic;
         ADVA : out  std_logic;
         XLBO : out  std_logic;
         ZZA : out  std_logic;
         XFT : out  std_logic;
         XZBE : out  std_logic_vector(3 downto 0);
         ZCLKMA : out  std_logic_vector(1 downto 0)
        );
    end component;

    component mem
      port(
        ZD    : inout std_logic_vector(31 downto 0):=(others=>'Z');
        ZA    : in   std_logic_vector(19 downto 0);
        XWA   : in   std_logic;
        clk   : in   std_logic
        );
    end component;


   --Inputs
   signal MCLK1 : std_logic := '0';
   signal RS_RX : std_logic := '0';

	--BiDirs
   signal ZD : std_logic_vector(31 downto 0);

 	--Outputs
   signal RS_TX : std_logic;
   signal ZA : std_logic_vector(19 downto 0);
   signal XWA : std_logic;
   signal XE1 : std_logic;
   signal E2A : std_logic;
   signal XE3 : std_logic;
   signal XGA : std_logic;
   signal XZCKE : std_logic;
   signal ADVA : std_logic;
   signal XLBO : std_logic;
   signal ZZA : std_logic;
   signal XFT : std_logic;
   signal XZBE : std_logic_vector(3 downto 0);
   signal ZCLKMA : std_logic_vector(1 downto 0);
--FILEIO
  type    BIN is file of character;
  file    FILEPOINT   :   BIN open read_mode is "contest.sld";

   constant MCLK1_period : time := CLK_LENGTH;
   -- constant ROMMAX:Integer:=11;
   -- type rom_t is array (0 to ROMMAX) of unsigned(31 downto 0);
   -- constant rom:rom_t:=(
   --       to_unsigned(0,32),
   --       to_unsigned(5,32),
   --       to_unsigned(1,32),
   --       to_unsigned(1024,32),
   --       B"0_00000_00001_00000_00000_0000000011_0", -- in 1
   --       B"1_00000_00001_00001_0000000000000001",   --addi 1 1  1
   --       B"0_00000_00000_00001_00000_0000000010_0", -- out 1
   --       B"0_00010_00000_00000" &to_unsigned(1025,16),
   --       B"0_00000_00000_00000_00000_0000000000_0",
   --       x"50000000",
   --       x"00EFBEEF",
   --       x"C0FFEEEE");

    constant ROMMAX:Integer:=17;  --loop fib
    type rom_t is array (0 to ROMMAX) of unsigned(31 downto 0);
    constant rom:rom_t:=(
          to_unsigned(0,32),
          to_unsigned(11,32),
          to_unsigned(1,32),
          to_unsigned(1024,32),
          B"1_0_00_00_00100_00000" & to_unsigned(13,16), -- mov r4 0
          B"1_0_00_00_00001_00000" & to_unsigned(0,16), -- mov r1 0
          B"1_0_00_00_00010_00000" & to_unsigned(1,16), -- mov r2 1
          B"0_0_11_00_00000_00100" & unsigned(to_signed(6,16)),   --loop:beq 0 r4 loopend
          B"1_0_00_00_00011_00001" & to_unsigned(0,16), -- mov r3 r1
          B"1_0_00_00_00001_00010" & to_unsigned(0,16), -- mov r1 r2
          B"0_0_00_00_00010_00001_00011_0000000000_1", -- add r2 r1 r3
          B"1_0_00_01_00100_00100" & to_unsigned(1,16), --subi r4 r4 1
          B"0_0_00_10_00000_00000" &to_unsigned(1027,16), -- j loop
          B"0_0_00_00_00000_00001_00000_0000000011_0", --loop_end:out r1
          to_unsigned(0,32),--hlt
          x"50000000",
          x"00EFBEEF",
          x"C0FFEEEE");
begin

	-- Instantiate the Unit Under Test (UUT)
   uut: aquila port map (
          MCLK1 => MCLK1,
          RS_RX => RS_RX,
          RS_TX => RS_TX,
          ZD => ZD,
          ZA => ZA,
          XWA => XWA,
          XE1 => XE1,
          E2A => E2A,
          XE3 => XE3,
          XGA => XGA,
          XZCKE => XZCKE,
          ADVA => ADVA,
          XLBO => XLBO,
          ZZA => ZZA,
          XFT => XFT,
          XZBE => XZBE,
          ZCLKMA => ZCLKMA
        );


   m:mem port map (ZD=>ZD,ZA=>ZA,XWA=>XWA,clk=>MCLK1);
   -- Clock process definitions
   MCLK1_process :process
   begin
		MCLK1 <= '0';
		wait for MCLK1_period/2;
		MCLK1 <= '1';
		wait for MCLK1_period/2;
   end process;


   -- Stimulus process
   stim_proc: process
    variable FREAD_CHAR:character;
    variable data:word:=x"00000000";
   begin
     -- hold reset state for 100 ns.
      wait for 100 ns;

      wait for MCLK1_period*10;

      -- insert stimulus here
      if ISROM then
        for I in 0 to ROMMAX loop
          for k in 0 to 3 loop
            rs_rx<='0';
            wait for IO_section_time;
            for J in 0 to 7 loop
              rs_rx<=rom(I)(24-8*k+j);
              wait for IO_SECTION_TIME;
            end loop;
            rs_rx<='1';
            wait for IO_SECTION_TIME;
          end loop;
        end loop;
      else
        while(endfile(FILEPOINT)=false) loop
          read( FILEPOINT, FREAD_CHAR );
          data:=x"000000" &(conv_std_logic_vector(CHARacter'pos(FREAD_CHAR),8));
          rs_rx<='0';
          wait for IO_section_time;
          for J in 0 to 7 loop
            rs_rx<=rom(I)(24-8*k+j);
            wait for IO_SECTION_TIME;
          end loop;
          rs_rx<='1';
          wait for IO_SECTION_TIME;
        end loop;
      end if;
      wait;
   end process;
end;
