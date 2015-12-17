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
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
library work;
use work.global_types.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY aquila_tb IS
END aquila_tb;
 
ARCHITECTURE behavior OF aquila_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT aquila
    PORT(
         MCLK1 : IN  std_logic;
         RS_RX : IN  std_logic;
         RS_TX : OUT  std_logic;
         ZD : INOUT  std_logic_vector(31 downto 0);
         ZA : OUT  std_logic_vector(19 downto 0);
         XWA : OUT  std_logic;
         XE1 : OUT  std_logic;
         E2A : OUT  std_logic;
         XE3 : OUT  std_logic;
         XGA : OUT  std_logic;
         XZCKE : OUT  std_logic;
         ADVA : OUT  std_logic;
         XLBO : OUT  std_logic;
         ZZA : OUT  std_logic;
         XFT : OUT  std_logic;
         XZBE : OUT  std_logic_vector(3 downto 0);
         ZCLKMA : OUT  std_logic_vector(1 downto 0)
        );
    END COMPONENT;

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
   -- No clocks detected in port list. Replace MCLK1 below with 
   -- appropriate port name 
 
   constant MCLK1_period : time := CLK_LENGTH;
    constant ROMMAX:Integer:=6;
    type rom_t is array (0 to ROMMAX) of unsigned(31 downto 0);
    constant rom:rom_t:=(
	  to_unsigned(0,32),
	  to_unsigned(3,32),
  	  to_unsigned(0,32),
	  to_unsigned(0,32),
          B"0_00000_00001_00000_00000_0000000010_0",
          B"0_00000_00000_00001_00000_0000000011_0",
          B"0_00000_00000_00000_00000_0000000000_0" );    
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: aquila PORT MAP (
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
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for MCLK1_period*10;

      

      -- insert stimulus here 
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
      wait;
   end process;

END;
