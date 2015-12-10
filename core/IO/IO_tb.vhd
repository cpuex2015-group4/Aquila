--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:43:18 12/04/2015
-- Design Name:   
-- Module Name:   /home/yukiimai/Sandbox/2015_winter/aquila/New_IO/IO_tb.vhd
-- Project Name:  IO
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: IO_module
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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library work;
use work.IO_interface.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY IO_tb IS
END IO_tb;



ARCHITECTURE behavior OF IO_tb IS 
  constant section:integer:=1000;
  -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT IO_module
      generic(section:std_logic_vector(15 downto 0):=CONV_STD_LOGIC_VECTOR(section,16));
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         IO_module_in : IN  IO_module_in_type;
         IO_module_out : OUT  IO_module_out_type
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal IO_module_in: IO_module_in_type:=IO_module_in_init;
    
 	--Outputs
   signal IO_module_out : IO_module_out_type:=IO_module_out_init;

   -- Clock period definitions
   constant clk_period : time := 15 ns; 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: IO_module PORT MAP (
          clk => clk,
          rst => rst,
          IO_module_in => IO_module_in,
          IO_module_out => IO_module_out
        );

   IO_module_in.serial_in<=IO_module_out.serial_out;
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
      wait for clk_period*10;

      for i in 10 to 3000 loop
        --if timing is correct
        --0,2,4,6,8,10... should be output serially
        if IO_module_out.full='1' then
          IO_module_in.we<='0';
          wait until IO_module_out.full='0';
        end if;
        wait until rising_edge(clk);
        IO_module_in.we<=not IO_module_in.we;
        IO_module_in.send_data<=CONV_STD_LOGIC_VECTOR(I,8);
        wait for clk_period;
      end loop;
      wait;
   end process;

   read_proc:process
   begin
     wait for 100*section*clk_period;
     wait for clk_period*10;
     for i in 0 to 100 loop
      if IO_module_out.empty='0' then
        IO_module_in.RE<='1';
      else
        IO_module_in.RE<='0';
      end if;
     end loop;
   end process;
END;



--check point
-- empty at first
-- send 10 12 14 16 18 ... 2000 (may be full on the half of the way)
-- recv 10 14 18 22. the value must change the next value when re become 1
