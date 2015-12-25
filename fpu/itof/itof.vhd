library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity itof is
  Port (
    clk    : in  std_logic;
    input  : in  STD_LOGIC_VECTOR (31 downto 0);
    output : out STD_LOGIC_VECTOR (31 downto 0));
end fadd;

architecture struct of itof is
	signal sign : std_logic;
	signal expo : std_logic_vector ( 7 downto 0);
  signal mant : std_logic_vector (25 downto 0);
	signal mano : std_logic_vector (22 downto 0);
	signal flag : std_logic;
	signal flag2: std_logic;
begin
  sign   <= '0'
							when input(30 downto 0) = "0000000000000000000000000000000"
						input(31);

-- shift
  mant   <= input(29 downto 5) & "1"
							when input(30) = '1' and input(4 downto 0) /= "00000" else
						input(28 downto 4) & "1"
							when input(29) = '1' and input(3 downto 0) /=  "0000" else
						input(27 downto 3) & "1"
							when input(28) = '1' and input(2 downto 0) /=   "000" else
						input(26 downto 2) & "1"
							when input(27) = '1' and input(1 downto 0) /=    "00" else
						input(29 downto 4)
							when input(30) = '1' else
						input(28 downto 3)
							when input(29) = '1' else
						input(27 downto 2)
							when input(28) = '1' else
						input(26 downto 1)
							when input(27) = '1' else
						input(25 downto 0)
							when input(26) = '1' else
						input(24 downto 0) & "0"
							when input(25) = '1' else
						input(23 downto 0) & "00"
							when input(24) = '1' else
						input(22 downto 0) & "000"
							when input(23) = '1' else
						input(21 downto 0) & "0000"
							when input(22) = '1' else
						input(20 downto 0) & "00000"
							when input(21) = '1' else
						input(19 downto 0) & "000000"
							when input(20) = '1' else
						input(18 downto 0) & "0000000"
							when input(19) = '1' else
						input(17 downto 0) & "00000000"
							when input(18) = '1' else
						input(16 downto 0) & "000000000"
							when input(17) = '1' else
						input(15 downto 0) & "0000000000"
							when input(16) = '1' else
						input(14 downto 0) & "00000000000"
							when input(15) = '1' else
						input(13 downto 0) & "000000000000"
							when input(14) = '1' else
						input(12 downto 0) & "0000000000000"
							when input(13) = '1' else
						input(11 downto 0) & "00000000000000"
							when input(12) = '1' else
						input(10 downto 0) & "000000000000000"
							when input(11) = '1' else
						input( 9 downto 0) & "0000000000000000"
							when input(10) = '1' else
						input( 8 downto 0) & "00000000000000000"
							when input( 9) = '1' else
						input( 7 downto 0) & "000000000000000000"
							when input( 8) = '1' else
						input( 6 downto 0) & "0000000000000000000"
							when input( 7) = '1' else
						input( 5 downto 0) & "00000000000000000000"
							when input( 6) = '1' else
						input( 4 downto 0) & "000000000000000000000"
							when input( 5) = '1' else
						input( 3 downto 0) & "0000000000000000000000"
							when input( 4) = '1' else
						input( 2 downto 0) & "00000000000000000000000"
							when input( 3) = '1' else
						input( 1 downto 0) & "000000000000000000000000"
							when input( 2) = '1' else
						input( 0) & "0000000000000000000000000"
							when input( 1) = '1' else
						"00000000000000000000000000";

	-- round nearest even
	flag   <= '0'
							when mant(2) = '0' or (mant(3) = '0' and mant(1) = '0' and mant(0) = '0') else
						'1';

  -- kuriagari
	flag2  <= '1'
							when flag = '1' and mant(25 downto 3) = "11111111111111111111111" else
						'0';

	mano   <= mant
							when flag  = '0' else
						"00000000000000000000000"
							when flag2 = '1' else
						mant + 1;

	expo   <= "10011101"
							when input(30) = '1' or (input(29) = '1' and flag2 = '1') else
						"10011100"
							when input(29) = '1' or (input(28) = '1' and flag2 = '1') else
						"10011011"
							when input(28) = '1' or (input(27) = '1' and flag2 = '1') else
						"10011010"
							when input(27) = '1' or (input(26) = '1' and flag2 = '1') else
						"10011001"
							when input(26) = '1' or (input(25) = '1' and flag2 = '1') else
						"10011000"
							when input(25) = '1' or (input(24) = '1' and flag2 = '1') else
						"10010111"
							when input(24) = '1' else
						"10010110"
							when input(23) = '1' else
						"10010101"
							when input(22) = '1' else
						"10010100"
							when input(21) = '1' else
						"10010011"
							when input(20) = '1' else
						"10010010"
							when input(19) = '1' else
						"10010001"
							when input(18) = '1' else
						"10010000"
							when input(17) = '1' else
						"10001111"
							when input(16) = '1' else
						"10001110"
							when input(15) = '1' else
						"10001101"
							when input(14) = '1' else
						"10001100"
							when input(13) = '1' else
						"10001011"
							when input(12) = '1' else
						"10001010"
							when input(11) = '1' else
						"10001001"
							when input(10) = '1' else
						"10001000"
							when input( 9) = '1' else
						"10000111"
							when input( 8) = '1' else
						"10000110"
							when input( 7) = '1' else
						"10000101"
							when input( 6) = '1' else
						"10000100"
							when input( 5) = '1' else
						"10000011"
							when input( 4) = '1' else
						"10000010"
							when input( 3) = '1' else
						"10000001"
							when input( 2) = '1' else
						"10000000"
							when input( 1) = '1' else
						"01111111"
							when input( 0) = '1' else
						"00000000";
	
	output <= sign & expo & mano;
end struct;
