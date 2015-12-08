library ieee;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;

entity moveup is
  port (
    man1_U    : in  std_logic_vector (27 downto 0);
    exp1_U    : in  std_logic_vector (7  downto 0);
    man2_U    : out std_logic_vector (26 downto 0);
    exp2_U    : out std_logic_vector (7  downto 0);
	 siginf2_U : out std_logic);
end moveup;

architecture struct of moveup is

begin
  man2_U <= man1_U(26 downto 0) when (man1_U(27) = '0') else
            man1_U(27 downto 2) & (man1_U(1) or man1_U(0)) when (exp1_U(7 downto 0) < "11111110") else
            "000000000000000000000000000";
  exp2_U <= exp1_U( 7 downto 0) when (man1_U(27) = '0') else
            exp1_U( 7 downto 0) + "00000001" when (exp1_U(7 downto 0) < "11111110") else
            "11111111";
  siginf2_U <= '0' when (man1_U(27) = '0') else
               '0' when (exp1_U(7 downto 0) < "11111110") else
               '1';
end struct;

