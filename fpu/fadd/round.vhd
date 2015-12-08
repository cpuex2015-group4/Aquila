library ieee;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;

entity round is
  port (
    man3_U : in  std_logic_vector (25 downto 0);
    exp3_U : in  std_logic_vector (7  downto 0);
    man4_U : out std_logic_vector (22 downto 0);
    exp4_U : out std_logic_vector (7  downto 0));
end round;

architecture struct of round is
begin
  man4_U <= man3_U(25 downto 3) 
              when (man3_U(2) = '0' or (man3_U(3) = '0' and man3_U(1) = '0' and man3_U(0) = '0')) else
            man3_U(25 downto 3) + 1 
              when (man3_U(25 downto 3) < "11111111111111111111111") else
            "00000000000000000000000";

  exp4_U <= exp3_U( 7 downto 0) 
              when (man3_U(2) = '0' or (man3_U(3) = '0' and man3_U(1) = '0' and man3_U(0) = '0')) else
            exp3_U( 7 downto 0) 
              when (man3_U(25 downto 3) < "11111111111111111111111") else
            exp3_U( 7 downto 0) + 1 
              when (exp3_U( 7 downto 0) < "11111110") else
            "11111111"; 
end struct;
