--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:46:42 10/22/2015
-- Design Name:   
-- Module Name:   /home/kentaro/Xilinx/fpu/top_fmul.vhd
-- Project Name:  fpu
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: fmul
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
 
ENTITY top_fmul IS
END top_fmul;
 
ARCHITECTURE behavior OF top_fmul IS 
    signal clk : std_logic := '0';
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT fmul
    PORT(
         inputA : IN  std_logic_vector(31 downto 0);
         inputB : IN  std_logic_vector(31 downto 0);
         output : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
   

   --Inputs
  signal inputA    : std_logic_vector (31 downto 0);
  signal inputB    : std_logic_vector (31 downto 0);
 	--Outputs
   signal output : std_logic_vector(31 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant clk_period : time := 15 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: fmul PORT MAP (
          inputA => inputA,
          inputB => inputB,
          output => output
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
        inputA <= x"7f800000";
        inputB <= x"7f800000";
      wait for clk_period;	
--        inputA <= "00000000000000000000000000000000";
--        inputB <= "00000000000000000000000000000000";
      wait for clk_period;
      -- insert stimulus here 
   end process;

END;
