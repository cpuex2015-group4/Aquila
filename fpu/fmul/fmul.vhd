library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity fmul is
  Port (
	  inputA : in  std_logic_vector (31 downto 0);
		inputB : in  std_logic_vector (31 downto 0);
		output : out std_logic_vector (31 downto 0));
--  	exflag : out std_logic_vector (3  downto 0); for overflow and underflow 
end fmul;

architecture struct of fmul is
  type float is record -- IEEE754 float
	  sign : std_logic;
		expo : std_logic_vector ( 7 downto 0);
		mant : std_logic_vector (22 downto 0);
	end record;

	component expoAdd port( -- exponent add
	  expoA   : in  std_logic_vector (7 downto 0);
		expoB   : in  std_logic_vector (7 downto 0);
		expoO1  : out std_logic_vector (7 downto 0);
		expoO2  : out std_logic_vector (7 downto 0);
		uFlag1  : out std_logic;
		uFlag2  : out std_logic);
  end component;
	  
  component mantMul port (
	  mantA : in  std_logic_vector (22 downto 0);
		mantB : in  std_logic_vector (22 downto 0);
		mantO : out std_logic_vector (22 downto 0);
		shift : out std_logic);
  end component;


	signal inputA_f : float;
	signal inputB_f : float;
	signal output_f : float;

	signal expoO1   : std_logic_vector ( 7 downto 0);
	signal expoO2   : std_logic_vector ( 7 downto 0);

	signal mantO    : std_logic_vector (22 downto 0);
	signal shift    : std_logic;
	signal uFlag1   : std_logic;
	signal uFlag2   : std_logic;
	signal infFlag  : std_logic;
	signal zeroFlag : std_logic;
begin
  -- input to float
  inputA_f.sign <= inputA(31);
	inputA_f.expo <= inputA(30 downto 23);
	inputA_f.mant <= inputA(22 downto  0);

	inputB_f.sign <= inputB(31);
	inputB_f.expo <= inputB(30 downto 23);
	inputB_f.mant <= inputB(22 downto  0);

  expoAddU : expoAdd port map (
	  expoA  => inputA_f.expo,
		expoB  => inputB_f.expo,
		expoO1 => expoO1,
		expoO2 => expoO2,
		uFlag1 => uFlag1,
		uFlag2 => uFlag2);

	mantMulU : mantMul port map (
	  mantA => inputA_f.mant,
		mantB => inputB_f.mant,
		mantO => mantO,
		shift => shift);


	zeroFlag <= '1' when inputA_f.expo = "0" or inputB_f.expo = "0" else
							'1' when shift = '0' and expoO1 = x"00" and uFlag1 = '0' else
							'1' when shift = '1' and expoO2 = x"00" and uFlag2 = '0' else
	            uFlag1 and expoO1(7) when shift = '0' else
              uFlag2 and expoO2(7) when shift = '1';
	infFlag  <= '1' when inputA_f.expo = "11111111" or inputB_f.expo = "11111111" else
	            '1' when expoO1 = x"ff" and shift = '0' and uFlag1 = '0' else
							'1' when expoO2 = x"ff" and shift = '1' and uFlag2 = '0'else
	            uFlag1 and (not expoO1(7)) when shift = '0' else
							uFlag2 and (not expoO2(7)) when shift = '1';
	
	output_f.sign <= inputA_f.sign xor inputB_f.sign when zeroFlag = '0' else
	                 '0';
  output_f.expo <= x"ff"  when infFlag  = '1' else
	                 x"00"  when zeroFlag = '1' else
	                 expoO1 when shift    = '0' else
	                 expoO2;
  output_f.mant <= "00000000000000000000000" when infFlag = '1' or zeroFlag = '1' else
	                 mantO;
  output <= output_f.sign & output_f.expo & output_f.mant;
end struct;
