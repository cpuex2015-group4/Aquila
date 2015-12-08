library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity finv is
  port (
    clk    : in  std_logic;
	  input  : in  std_logic_vector (31 downto 0);
		output : out std_logic_vector (31 downto 0));
end finv;

architecture struct of finv is
  type float is record
	  sign : std_logic;
		expo : std_logic_vector ( 7 downto 0);
		mant : std_logic_vector (22 downto 0);
	end record;

  component finv_table is
	  port (
		  CLKA  : in  std_logic;
			ADDRA : in  std_logic_vector ( 9 downto 0); 
			DOUTA : out std_logic_vector (45 downto 0));
	end component;

	signal input_f  : float;
	signal output_f : float;

  signal rom_en   : std_logic := '0';
  signal rom_addr : std_logic_vector ( 9 downto 0);
  signal rom_data : std_logic_vector (45 downto 0);
	signal const    : std_logic_vector (23 downto 0);
	signal manti    : std_logic_vector (23 downto 0);
  signal grad     : std_logic_vector (22 downto 0);
	signal gx       : std_logic_vector (46 downto 0);
  signal gx2      : std_logic_vector (23 downto 0);
	signal mant     : std_logic_vector (23 downto 0);

begin
	rom_addr <= input(22 downto 13);

	finv_table_rom : finv_table port map (
	  CLKA  => clk,
		ADDRA => rom_addr,
		DOUTA => rom_data);

  manti <= "1" & input_f.mant(22 downto 0);
  const <= "1" & rom_data(45 downto 23);
  grad  <= rom_data(22 downto  0);
  gx    <= grad * manti;
  gx2   <= gx(46 downto 23);
  mant  <= const - gx2;

  output_f.sign <= input_f.sign;
	output_f.expo <= 253 - input_f.expo;
	output_f.mant <= mant(21 downto 0) & "0";

  holo : process(clk)
  begin
    if rising_edge(clk) then
      input_f.sign <= input(31);
    	input_f.expo <= input(30 downto 23);
    	input_f.mant <= input(22 downto  0);    
    end if;
  end process;
  
  output <= output_f.sign & output_f.expo & output_f.mant;
end struct;
