library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ftoi is
  Port (
    clk    : in  std_logic;
    input  : in  STD_LOGIC_VECTOR (31 downto 0);
    output : out STD_LOGIC_VECTOR (31 downto 0);
		flag   : out STD_LOGIC_VECTOR ( 1 downto 0)); -- underflow / overflow
end fadd;

architecture struct of ftoi is
	signal sign : std_logic;
	signal expo : std_logic_vector ( 7 downto 0);
  signal mant : std_logic_vector (22 downto 0);
	signal into : std_logic_vector (33 downto 0); -- 0(overflow) 000 0000 0000 0000 0000 0000 0000 0000 0(round) 0(guard)
	signal stic : std_logic;
begin
  sign   <= input(31);
	expo   <= input(30 downto 23);
	mant   <= input(22 downto  0);

-- shift
  into   <= "0000000000000000000000000000000000"
							when expo < "01111101" else
						"0000000000000000000000000000000001"
							when expo = "01111101" else
            "000000000000000000000000000000001" & mant(22)
              when expo = "01111110" else
						"00000000000000000000000000000001"  & mant(22 downto 21)
						  when expo = "01111111" else
						"0000000000000000000000000000001"   & mant(22 downto 20)
						  when expo = "10000000" else
						"000000000000000000000000000001"    & mant(22 downto 19)
						  when expo = "10000001" else
						"00000000000000000000000000001"     & mant(22 downto 18)
						  when expo = "10000010" else
						"0000000000000000000000000001"      & mant(22 downto 17)
						  when expo = "10000011" else
						"000000000000000000000000001"       & mant(22 downto 16)
						  when expo = "10000100" else
						"00000000000000000000000001"        & mant(22 downto 15)
						  when expo = "10000101" else
						"0000000000000000000000001"         & mant(22 downto 14)
						  when expo = "10000110" else
						"000000000000000000000001"          & mant(22 downto 13)
						  when expo = "10000111" else
						"00000000000000000000001"           & mant(22 downto 12)
						  when expo = "10001000" else
						"0000000000000000000001"            & mant(22 downto 11)
						  when expo = "10001001" else
						"000000000000000000001"             & mant(22 downto 10)
						  when expo = "10001010" else
						"00000000000000000001"              & mant(22 downto  9)
						  when expo = "10001011" else
						"0000000000000000001"               & mant(22 downto  8)
						  when expo = "10001100" else
						"000000000000000001"                & mant(22 downto  7)
						  when expo = "10001101" else
						"00000000000000001"                 & mant(22 downto  6)
						  when expo = "10001110" else
						"0000000000000001"                  & mant(22 downto  5)
						  when expo = "10001111" else
						"000000000000001"                   & mant(22 downto  4)
						  when expo = "10010000" else
						"00000000000001"                    & mant(22 downto  3)
						  when expo = "10010001" else
						"0000000000001"                     & mant(22 downto  2)
						  when expo = "10010010" else
						"000000000001"                      & mant(22 downto  1)
						  when expo = "10010011" else
						"00000000001"                       & mant(22 downto  0)
						  when expo = "10010100" else
						"0000000001"                        & mant(22 downto  0) & "0"
						  when expo = "10010101" else
						"000000001"                         & mant(22 downto  0) & "00"
						  when expo = "10010110" else
						"00000001"                          & mant(22 downto  0) & "000"
						  when expo = "10010111" else
						"0000001"                           & mant(22 downto  0) & "0000"
						  when expo = "10011000" else
						"000001"                            & mant(22 downto  0) & "00000"
						  when expo = "10011001" else
						"00001"                             & mant(22 downto  0) & "000000"
						  when expo = "10011010" else
						"0001"                              & mant(22 downto  0) & "0000000"
						  when expo = "10011011" else
						"001"                               & mant(22 downto  0) & "00000000"
						  when expo = "10011100" else
						"01"                                & mant(22 downto  0) & "000000000"
						  when expo = "10011101" else
						"10000000000000000000000000000000000" -- overflow

	stic  <= '1' when expo < "01111101" or
									 (expo = "01111101" and mant(22 downto 0) /= "00000000000000000000000") or
									 (expo = "01111110" and mant(21 downto 0) /=  "0000000000000000000000") or
									 (expo = "01111111" and mant(20 downto 0) /=   "000000000000000000000") or
									 (expo = "10000000" and mant(19 downto 0) /=    "00000000000000000000") or
									 (expo = "10000001" and mant(18 downto 0) /=     "0000000000000000000") or
									 (expo = "10000010" and mant(17 downto 0) /=      "000000000000000000") or
									 (expo = "10000011" and mant(16 downto 0) /=       "00000000000000000") or
									 (expo = "10000100" and mant(15 downto 0) /=        "0000000000000000") or
									 (expo = "10000101" and mant(14 downto 0) /=         "000000000000000") or
									 (expo = "10000110" and mant(13 downto 0) /=          "00000000000000") or
									 (expo = "10000111" and mant(12 downto 0) /=           "0000000000000") or
									 (expo = "10001000" and mant(11 downto 0) /=            "000000000000") or
									 (expo = "10001001" and mant(10 downto 0) /=             "00000000000") or
									 (expo = "10001010" and mant( 9 downto 0) /=              "0000000000") or
									 (expo = "10001011" and mant( 8 downto 0) /=               "000000000") or
									 (expo = "10001100" and mant( 7 downto 0) /=                "00000000") or
									 (expo = "10001101" and mant( 6 downto 0) /=                 "0000000") or
									 (expo = "10001110" and mant( 5 downto 0) /=                  "000000") or
									 (expo = "10001111" and mant( 4 downto 0) /=                   "00000") or
									 (expo = "10010000" and mant( 3 downto 0) /=                    "0000") or
									 (expo = "10010001" and mant( 2 downto 0) /=                     "000") or
									 (expo = "10010010" and mant( 1 downto 0) /=                      "00") or
									 (expo = "10010011" and mant(0)           /=                       '0') else
					 '0';

	output <= sign & into(32 downto 2)
							when into(1) = '0' or (into(2) = '0' and into(0) = '0' and stic = '0') else
						sign & into(32 downto 2) + 1;
	flag   <= into(33) & "1"
							when into(33 downto 2) = "00000000000000000000000000000000" and (into(1 downto 0) /= "00" or stic = '1') else
						into(33) & "0"
end struct;
