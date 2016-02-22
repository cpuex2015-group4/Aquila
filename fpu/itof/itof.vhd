library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity itof is
  Port (
    input  : in  STD_LOGIC_VECTOR (31 downto 0);
    output : out STD_LOGIC_VECTOR (31 downto 0));
end itof;

architecture struct of itof is
	signal sign : std_logic;
	signal sint : std_logic_vector (31 downto 0);
	signal expo : std_logic_vector ( 7 downto 0);
  signal mant : std_logic_vector (25 downto 0);
	signal mano : std_logic_vector (22 downto 0);
	signal flag : std_logic;
	signal flag2: std_logic;
	signal zflag: std_logic;
begin
  sign   <= '0'
							when input(30 downto 0) = "0000000000000000000000000000000" else
						input(31);
	zflag  <= '1'
							when input(30 downto 0) = "0000000000000000000000000000000" else
						'0';

	sint	 <= input(31 downto 0)
							when input(31) = '0' else
						"0" & ((input(30 downto 0) xor "1111111111111111111111111111111") + 1);

-- shift
  mant   <= sint(29 downto 5) & "1"
							when sint(30) = '1' and sint(4 downto 0) /= "00000" else
						sint(28 downto 4) & "1"
							when sint(29) = '1' and sint(3 downto 0) /=  "0000" else
						sint(27 downto 3) & "1"
							when sint(28) = '1' and sint(2 downto 0) /=   "000" else
						sint(26 downto 2) & "1"
							when sint(27) = '1' and sint(1 downto 0) /=    "00" else
						sint(29 downto 4)
							when sint(30) = '1' else
						sint(28 downto 3)
							when sint(29) = '1' else
						sint(27 downto 2)
							when sint(28) = '1' else
						sint(26 downto 1)
							when sint(27) = '1' else
						sint(25 downto 0)
							when sint(26) = '1' else
						sint(24 downto 0) & "0"
							when sint(25) = '1' else
						sint(23 downto 0) & "00"
							when sint(24) = '1' else
						sint(22 downto 0) & "000"
							when sint(23) = '1' else
						sint(21 downto 0) & "0000"
							when sint(22) = '1' else
						sint(20 downto 0) & "00000"
							when sint(21) = '1' else
						sint(19 downto 0) & "000000"
							when sint(20) = '1' else
						sint(18 downto 0) & "0000000"
							when sint(19) = '1' else
						sint(17 downto 0) & "00000000"
							when sint(18) = '1' else
						sint(16 downto 0) & "000000000"
							when sint(17) = '1' else
						sint(15 downto 0) & "0000000000"
							when sint(16) = '1' else
						sint(14 downto 0) & "00000000000"
							when sint(15) = '1' else
						sint(13 downto 0) & "000000000000"
							when sint(14) = '1' else
						sint(12 downto 0) & "0000000000000"
							when sint(13) = '1' else
						sint(11 downto 0) & "00000000000000"
							when sint(12) = '1' else
						sint(10 downto 0) & "000000000000000"
							when sint(11) = '1' else
						sint( 9 downto 0) & "0000000000000000"
							when sint(10) = '1' else
						sint( 8 downto 0) & "00000000000000000"
							when sint( 9) = '1' else
						sint( 7 downto 0) & "000000000000000000"
							when sint( 8) = '1' else
						sint( 6 downto 0) & "0000000000000000000"
							when sint( 7) = '1' else
						sint( 5 downto 0) & "00000000000000000000"
							when sint( 6) = '1' else
						sint( 4 downto 0) & "000000000000000000000"
							when sint( 5) = '1' else
						sint( 3 downto 0) & "0000000000000000000000"
							when sint( 4) = '1' else
						sint( 2 downto 0) & "00000000000000000000000"
							when sint( 3) = '1' else
						sint( 1 downto 0) & "000000000000000000000000"
							when sint( 2) = '1' else
						sint( 0) & "0000000000000000000000000"
							when sint( 1) = '1' else
						"00000000000000000000000000";

	-- round nearest even
	flag   <= '0'
							when mant(2) = '0' or mant(3 downto 0) = "0100" else
						'1';

  -- kuriagari
	flag2  <= '1'
							when flag = '1' and mant(25 downto 3) = "11111111111111111111111" else
						'0';

	mano   <= mant(25 downto 3)
							when flag  = '0' else
						"00000000000000000000000"
							when flag2 = '1' else
						mant(25 downto 3) + 1;

	expo   <= "10011101"
							when sint(30) = '1' or (sint(29) = '1' and flag2 = '1') else
						"10011100"
							when sint(29) = '1' or (sint(28) = '1' and flag2 = '1') else
						"10011011"
							when sint(28) = '1' or (sint(27) = '1' and flag2 = '1') else
						"10011010"
							when sint(27) = '1' or (sint(26) = '1' and flag2 = '1') else
						"10011001"
							when sint(26) = '1' or (sint(25) = '1' and flag2 = '1') else
						"10011000"
							when sint(25) = '1' or (sint(24) = '1' and flag2 = '1') else
						"10010111"
							when sint(24) = '1' else
						"10010110"
							when sint(23) = '1' else
						"10010101"
							when sint(22) = '1' else
						"10010100"
							when sint(21) = '1' else
						"10010011"
							when sint(20) = '1' else
						"10010010"
							when sint(19) = '1' else
						"10010001"
							when sint(18) = '1' else
						"10010000"
							when sint(17) = '1' else
						"10001111"
							when sint(16) = '1' else
						"10001110"
							when sint(15) = '1' else
						"10001101"
							when sint(14) = '1' else
						"10001100"
							when sint(13) = '1' else
						"10001011"
							when sint(12) = '1' else
						"10001010"
							when sint(11) = '1' else
						"10001001"
							when sint(10) = '1' else
						"10001000"
							when sint( 9) = '1' else
						"10000111"
							when sint( 8) = '1' else
						"10000110"
							when sint( 7) = '1' else
						"10000101"
							when sint( 6) = '1' else
						"10000100"
							when sint( 5) = '1' else
						"10000011"
							when sint( 4) = '1' else
						"10000010"
							when sint( 3) = '1' else
						"10000001"
							when sint( 2) = '1' else
						"10000000"
							when sint( 1) = '1' else
						"01111111"
							when sint( 0) = '1' else
						"00000000";
	
	output <= sign & expo & mano
							when zflag = '0' else
						x"00000000";
end struct;
