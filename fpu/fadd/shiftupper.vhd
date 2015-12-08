library ieee;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;

entity shiftupper is
  port (
    man2_U : in  std_logic_vector (26 downto 0);
    exp2_U : in  std_logic_vector ( 7 downto 0);
    man3_U : out std_logic_vector (25 downto 0);
    exp3_U : out std_logic_vector ( 7 downto 0);
	  siginf2_U : in  std_logic);
end shiftupper;

architecture struct of shiftupper is

begin
  man3_U <= man2_U(25 downto 0) when (man2_U(26) = '1') else
            man2_U(24 downto 0) & '0'
              when (man2_U(25) = '1' and "00000001" < exp2_U) else
            man2_U(23 downto 0) & "00"
              when (man2_U(24) = '1' and "00000010" < exp2_U) else
            man2_U(22 downto 0) & "000"
              when (man2_U(23) = '1' and "00000011" < exp2_U) else
            man2_U(21 downto 0) & "0000"
              when (man2_U(22) = '1' and "00000100" < exp2_U) else
            man2_U(20 downto 0) & "00000"
              when (man2_U(21) = '1' and "00000101" < exp2_U) else
            man2_U(19 downto 0) & "000000"
              when (man2_U(20) = '1' and "00000110" < exp2_U) else
            man2_U(18 downto 0) & "0000000"
              when (man2_U(19) = '1' and "00000111" < exp2_U) else
            man2_U(17 downto 0) & "00000000"
              when (man2_U(18) = '1' and "00001000" < exp2_U) else
            man2_U(16 downto 0) & "000000000"
              when (man2_U(17) = '1' and "00001001" < exp2_U) else
            man2_U(15 downto 0) & "0000000000"
              when (man2_U(16) = '1' and "00001010" < exp2_U) else
            man2_U(14 downto 0) & "00000000000"
              when (man2_U(15) = '1' and "00001011" < exp2_U) else
            man2_U(13 downto 0) & "000000000000"
              when (man2_U(14) = '1' and "00001100" < exp2_U) else
            man2_U(12 downto 0) & "0000000000000"
              when (man2_U(13) = '1' and "00001101" < exp2_U) else
            man2_U(11 downto 0) & "00000000000000"
              when (man2_U(12) = '1' and "00001110" < exp2_U) else
            man2_U(10 downto 0) & "000000000000000"
              when (man2_U(11) = '1' and "00001111" < exp2_U) else
            man2_U( 9 downto 0) & "0000000000000000"
              when (man2_U(10) = '1' and "00010000" < exp2_U) else
            man2_U( 8 downto 0) & "00000000000000000"
              when (man2_U( 9) = '1' and "00010001" < exp2_U) else
            man2_U( 7 downto 0) & "000000000000000000"
              when (man2_U( 8) = '1' and "00010010" < exp2_U) else
            man2_U( 6 downto 0) & "0000000000000000000"
              when (man2_U( 7) = '1' and "00010011" < exp2_U) else
            man2_U( 5 downto 0) & "00000000000000000000"
              when (man2_U( 6) = '1' and "00010100" < exp2_U) else
            man2_U( 4 downto 0) & "000000000000000000000"
              when (man2_U( 5) = '1' and "00010101" < exp2_U) else
            man2_U( 3 downto 0) & "0000000000000000000000"
              when (man2_U( 4) = '1' and "00010110" < exp2_U) else
            man2_U( 2 downto 0) & "00000000000000000000000"
              when (man2_U( 3) = '1' and "00010111" < exp2_U) else
            man2_U( 1 downto 0) & "000000000000000000000000"
              when (man2_U( 2) = '1' and "00011000" < exp2_U) else
            man2_U( 0) & "0000000000000000000000000"
              when (man2_U( 1) = '1' and "00011001" < exp2_U) else
            "00000000000000000000000000";

  exp3_U <= exp2_U  when (man2_U(26) = '1') else
            exp2_U - 1
              when (man2_U(25) = '1' and "00000001" < exp2_U) else
            exp2_U - 2
              when (man2_U(24) = '1' and "00000010" < exp2_U) else
            exp2_U - 3
              when (man2_U(23) = '1' and "00000011" < exp2_U) else
            exp2_U - 4
              when (man2_U(22) = '1' and "00000100" < exp2_U) else
            exp2_U - 5
              when (man2_U(21) = '1' and "00000101" < exp2_U) else
            exp2_U - 6
              when (man2_U(20) = '1' and "00000110" < exp2_U) else
            exp2_U - 7
              when (man2_U(19) = '1' and "00000111" < exp2_U) else
            exp2_U - 8
              when (man2_U(18) = '1' and "00001000" < exp2_U) else
            exp2_U - 9
              when (man2_U(17) = '1' and "00001001" < exp2_U) else
            exp2_U - 10
              when (man2_U(16) = '1' and "00001010" < exp2_U) else
            exp2_U - 11
              when (man2_U(15) = '1' and "00001011" < exp2_U) else
            exp2_U - 12
              when (man2_U(14) = '1' and "00001100" < exp2_U) else
            exp2_U - 13
              when (man2_U(13) = '1' and "00001101" < exp2_U) else
            exp2_U - 14
              when (man2_U(12) = '1' and "00001110" < exp2_U) else
            exp2_U - 15
              when (man2_U(11) = '1' and "00001111" < exp2_U) else
            exp2_U - 16
              when (man2_U(10) = '1' and "00010000" < exp2_U) else
            exp2_U - 17
              when (man2_U( 9) = '1' and "00010001" < exp2_U) else
            exp2_U - 18
              when (man2_U( 8) = '1' and "00010010" < exp2_U) else
            exp2_U - 19
              when (man2_U( 7) = '1' and "00010011" < exp2_U) else
            exp2_U - 20
              when (man2_U( 6) = '1' and "00010100" < exp2_U) else
            exp2_U - 21
              when (man2_U( 5) = '1' and "00010101" < exp2_U) else
            exp2_U - 22
              when (man2_U( 4) = '1' and "00010110" < exp2_U) else
            exp2_U - 23
              when (man2_U( 3) = '1' and "00010111" < exp2_U) else
            exp2_U - 24
              when (man2_U( 2) = '1' and "00011000" < exp2_U) else
            exp2_U - 25
              when (man2_U( 1) = '1' and "00011001" < exp2_U) else
            exp2_U - 26
              when (man2_U( 0) = '1' and "00011010" < exp2_U) else
            "00000000"
				  when (siginf2_U = '0') else
				"11111111";
end struct;

  
