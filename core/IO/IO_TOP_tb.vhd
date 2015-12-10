--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   05:09:03 12/04/2015
-- Design Name:   
-- Module Name:   /home/yukiimai/Sandbox/2015_winter/aquila/New_IO/IO_TOP_tb.vhd
-- Project Name:  IO
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: IO_top
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY IO_TOP_tb IS
END IO_TOP_tb;
 
ARCHITECTURE behavior OF IO_TOP_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT IO_top
    PORT(
         MCLK1 : IN  std_logic;
         RS_RX : IN  std_logic;
         RS_TX : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal MCLK1 : std_logic := '0';
   signal RS_RX : std_logic := '0';

 	--Outputs
   signal RS_TX : std_logic;
   -- No clocks detected in port list. Replace MCLK1 below with 
   -- appropriate port name 
 
   constant MCLK1_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: IO_top PORT MAP (
          MCLK1 => MCLK1,
          RS_RX => RS_RX,
          RS_TX => RS_TX
        );

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

      wait;
   end process;

END;
