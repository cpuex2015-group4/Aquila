LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.Vcomponents.all;

entity top is
  port( MCLK1 : in  std_logic;
        RS_TX : out std_logic);
end top;

architecture testbench of top is
  signal clk  : std_logic;
  signal iclk : std_logic;
  signal send : std_logic := '1';
  signal full : std_logic := '0';

  component serialif port (
    serialO : out std_logic;
	  dataIN  : in  std_logic_vector(7 downto 0) := "10101010";
	  send    : in  std_logic;
	  full    : out std_logic;
	  clk     : in  std_logic);
  end component;
    
  component fmul port (
    inputA : in  std_logic_vector (31 downto 0);
    inputB : in  std_logic_vector (31 downto 0);
    output : out std_logic_vector (31 downto 0));
  end component;
   
  component finv port (
    clk    : in  std_logic;
    input  : in  std_logic_vector (31 downto 0);
    output : out std_logic_vector (31 downto 0));
  end component;
  
  component fcmp port (
    inputA : in  std_logic_vector (31 downto 0);
    inputB : in  std_logic_vector (31 downto 0);
    mode   : in  std_logic_vector ( 5 downto 0);
    output : out std_logic);
  end component;
  
  component fadd port (
    ina    : in  std_logic_vector (31 downto 0);
    inb    : in  std_logic_vector (31 downto 0);
    output : out std_logic_vector (31 downto 0));
  end component;
  
  signal inputA    : std_logic_vector (31 downto 0) := "00111111111011001100110011001101"; -- 1.85
  signal inputB    : std_logic_vector (31 downto 0) := "00111111100001100110011001100110"; -- 1.05
  signal mode      : std_logic_vector ( 5 downto 0) := "111100";
  signal muloutput : std_logic_vector (31 downto 0);
  signal mulanswer : std_logic_vector (31 downto 0) := "00111111111110001010001111010111";
  signal invoutput : std_logic_vector (31 downto 0);
  signal invanswer : std_logic_vector (31 downto 0) := "00111111000010100110000011011110"; -- 0.33...
  signal addoutput : std_logic_vector (31 downto 0) := "00000000000000000000000000000000";
  signal addanswer : std_logic_vector (31 downto 0) := "01000000001110011001100110011010"; -- 2.90
  signal cmpoutput : std_logic;
  signal cmpanswer : std_logic := '1';
  signal tb_result : std_logic_vector (7 downto 0) := "00000000";
  
  signal clkcount  : std_logic_vector (3 downto 0) := "0000";
  signal mulcorrect: std_logic := '0';
  signal invcorrect: std_logic := '0';
  signal cmpcorrect: std_logic := '0';
  signal addcorrect: std_logic := '0';
begin
  ib : IBUFG port map (
    i => MCLK1,
	  o => iclk);
  bg : BUFG port map (
    i => iclk,
	  o => clk);

  mul_u : fmul port map (
    inputA => inputA,
    inputB => inputB,
    output => muloutput);
    
  inv_u : finv port map (
    clk    => clk,
    input  => inputA,
    output => invoutput);
    
  cmp_u : fcmp port map (
    inputA => inputA,
    inputB => inputB,
    mode   => mode,
    output => cmpoutput);
    
  add_u : fadd port map (
    ina    => inputA,
    inb    => inputB,
    output => addoutput);
  
  rc232c : serialif port map (
    serialO => rs_tx,
	  dataIN  => tb_result,
	  send    => send,
	  full    => full,
	  clk     => clk);
    
  cmp_ans : process(clk)
  begin
    if rising_edge(clk) then
      if muloutput = mulanswer then
        mulcorrect <= '1';
      else
        mulcorrect <= '0';
      end if;
      if invoutput = invanswer then
        invcorrect <= '1';
      else
        invcorrect <= '0';
      end if;
      if (not cmpoutput) = cmpanswer then
        cmpcorrect <= '1';
      else
        cmpcorrect <= '0';
      end if;
      if addoutput = addanswer then
        addcorrect <= '1';
      else
        addcorrect <= '0';
      end if;
      clkcount <= clkcount + 1;
	  end if;
  end process;
  
  tb_result <= addcorrect & mulcorrect & invcorrect & cmpcorrect & clkcount;
  send <= not full;
end;
