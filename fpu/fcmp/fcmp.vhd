library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity fcmp is
  port(
   inputA : in  std_logic_vector (31 downto 0);
	 inputB : in  std_logic_vector (31 downto 0);
	 mode   : in  std_logic_vector ( 5 downto 0);  -- "111110" = le / "111100" = lt / "110010" = eq
	 output : out std_logic);
end fcmp;

architecture struct of fcmp is
	signal lt : std_logic;
	signal eq : std_logic;
begin
	eq <= '1' when inputA(30 downto 0) = 0 and inputB(30 downto 0) = 0 else
	      '1' when inputA = inputB else
				'0';
	lt <= '0' when inputA(30 downto 0) = 0 and inputB(30 downto 0) = 0 else
	      '1' when inputA(31) = '1' and inputB(31) = '0' else
	      '1' when inputA(31) = '1' and inputB(31) = '1' and inputA(30 downto 0) > inputB(30 downto 0) else
				'1' when inputA(31) = '0' and inputB(31) = '0' and inputA(30 downto 0) < inputB(30 downto 0) else
				'0';

	output <= (lt or eq) when mode = "111110" else
	          lt         when mode = "111100" else
						eq         when mode = "110010" else
            '0';
end struct;
