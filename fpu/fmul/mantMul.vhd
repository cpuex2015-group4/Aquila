library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mantmul is
  port (
	  mantA : in  std_logic_vector (22 downto 0);
		mantB : in  std_logic_vector (22 downto 0);
		mantO : out std_logic_vector (22 downto 0);
		shift : out std_logic);
end mantmul;

architecture struct of mantmul is
  signal mantAex : std_logic_vector (23 downto 0);
	signal mantBex : std_logic_vector (23 downto 0);
	
	signal ans     : std_logic_vector (25 downto 0);
	signal ansHH   : std_logic_vector (25 downto 0);
	signal ansHL   : std_logic_vector (23 downto 0);
	signal ansLH   : std_logic_vector (23 downto 0);
begin
  mantAex <= "1" & mantA;
	mantBex <= "1" & mantB;

	ansHH <= mantAex(23 downto 11) * mantBex(23 downto 11);
	ansHL <= mantAex(23 downto 11) * mantBex(10 downto  0);
	ansLH <= mantAex(10 downto  0) * mantBex(23 downto 11);

	ans   <= ansHH + ansHL(23 downto 11) + ansLH(23 downto 11) + 2;

  mantO <= ans(24 downto 2) when ans(25) = '1' else
	         ans(23 downto 1);
	shift <= '1'              when ans(25) = '1' else
	         '0';
end struct;

         
