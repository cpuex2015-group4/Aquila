--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:28:15 12/08/2015
-- Design Name:   
-- Module Name:   /home/yukiimai/Sandbox/2015_winter/aquila/Mem_controller/memcon_tb.vhd
-- Project Name:  Mem_controller
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Memcon
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
use work.Memcon_interface.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY memcon_tb IS
END memcon_tb;
 
ARCHITECTURE behavior OF memcon_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Memcon
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         Memcon_in : IN  memcon_in_type;
         Memcon_out : out memcon_out_type;
         SRAM_ZD : INOUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;

    
    COMPONENT Mem
      port(
        ZD    : inout std_logic_vector(31 downto 0):=(others=>'Z');
        ZA    : in   std_logic_vector(19 downto 0);
        XWA   : in   std_logic;
        clk   : in   std_logic
        );
    END COMPONENT;    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal Memcon_in : memcon_in_type := memcon_in_init;

	--BiDirs
   signal SRAM_ZD : std_logic_vector(31 downto 0):=(others=>'Z');

 	--Outputs
   signal Memcon_out : memcon_out_type:=memcon_out_init;

   -- Clock period definitions
   constant clk_period : time := 15 ns;


    --memory
    signal za:std_logic_vector(19 downto 0);
    signal zd:std_logic_vector(31 downto 0);
    signal xwa:std_logic;
BEGIN
  xwa<= '1' when memcon_out.sram_xwa else
        '0';
  za<=std_logic_vector(memcon_out.sram_addr);

  memomry:Mem port map(
    zd=>std_logic_vector(sram_zd),
    za=>za,
    xwa=>xwa,
    clk=>clk);
  
	-- Instantiate the Unit Under Test (UUT)
   uut: Memcon PORT MAP (
          clk => clk,
          rst => rst,
          Memcon_in => Memcon_in,
          Memcon_out => Memcon_out,
          SRAM_ZD => SRAM_ZD
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

      wait for clk_period*10;

      -- insert stimulus here
      memcon_in.re<=true;
      wait for clk_period;
      for i in 0 to 10 loop
        memcon_in.addr<=to_unsigned(i,20);
        memcon_in.input<=to_unsigned(i+i,32);
        wait for clk_period;
      end loop;
        memcon_in.we<=not memcon_in.we;
        memcon_in.re<=not memcon_in.re;
      for i in 0 to 10 loop
        memcon_in.addr<=to_unsigned(i,20);
        memcon_in.input<=to_unsigned(i+i,32);
        wait for clk_period;
      end loop;
      wait;
   end process;

END;
