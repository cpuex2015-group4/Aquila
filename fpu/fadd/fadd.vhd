library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fadd is
  Port (
    ina : in  STD_LOGIC_VECTOR (31 downto 0);
    inb : in  STD_LOGIC_VECTOR (31 downto 0);
    output : out STD_LOGIC_VECTOR (31  downto 0));
end fadd;

architecture struct of fadd is
  component cmpexp port (
    ina_U     : in  std_logic_vector (31 downto 0);
    inb_U     : in  std_logic_vector (31 downto 0);
    winner_U  : out std_logic_vector (31 downto 0);
    loser_U   : out std_logic_vector (31 downto 0);
    sigzero_U : out std_logic;
    siginf_U  : out std_logic;
    anszero_U : out std_logic);
  end component;

  component shiftloser port (
    winner_U         : in  std_logic_vector (31 downto 0);
    loser_U          : in  std_logic_vector (31 downto 0);
    sign_U           : out std_logic;
    subflag_U        : out std_logic;
    exp_U            : out std_logic_vector (7  downto 0);
    winner_shifted_U : out std_logic_vector (26 downto 0);
    loser_shifted_U  : out std_logic_vector (26 downto 0));
  end component;

  component moveup port (
    man1_U : in  std_logic_vector (27 downto 0);
    exp1_U : in  std_logic_vector (7  downto 0);
    man2_U : out std_logic_vector (26 downto 0);
    exp2_U : out std_logic_vector (7  downto 0);
	 siginf2_U: out std_logic);
  end component;

  component shiftupper port (
    man2_U : in  std_logic_vector (26 downto 0);
    exp2_U : in  std_logic_vector ( 7 downto 0);
    man3_U : out std_logic_vector (25 downto 0);
    exp3_U : out std_logic_vector ( 7 downto 0);
	 siginf2_U : in  std_logic);
  end component;

  component round port (
    man3_U : in  std_logic_vector (25 downto 0);
    exp3_U : in  std_logic_vector ( 7 downto 0);
    man4_U : out std_logic_vector (22 downto 0);
    exp4_U : out std_logic_vector ( 7 downto 0));
  end component;

  signal subflag : std_logic;
  signal sigzero : std_logic;
  signal siginf  : std_logic;
  signal siginf2 : std_logic;
  signal anszero : std_logic;
  signal winner1 : std_logic_vector (31 downto 0);
  signal loser1  : std_logic_vector (31 downto 0);
  signal winner2  : std_logic_vector (26 downto 0);
  signal loser2   : std_logic_vector (26 downto 0);
  signal sign : std_logic; 
  signal exp1 : std_logic_vector (7  downto 0); 
  signal exp2 : std_logic_vector (7  downto 0);
  signal exp3 : std_logic_vector (7  downto 0);
  signal exp4 : std_logic_vector (7  downto 0); 
  signal man1 : std_logic_vector (27 downto 0);
  signal man2 : std_logic_vector (26 downto 0);
  signal man3 : std_logic_vector (25 downto 0);
  signal man4 : std_logic_vector (22 downto 0);

begin
  cmpExp_U : cmpexp port map (
    ina_U     => ina,
    inb_U     => inb,
    winner_U  => winner1,
    loser_U   => loser1,
    sigzero_U => sigzero,
    siginf_U  => siginf,
    anszero_U => anszero);

  shiftLoser_U : shiftloser port map (
    winner_U  => winner1,
    loser_U   => loser1,
    sign_U    => sign,
    subflag_U => subflag,
    exp_U     => exp1,
    winner_shifted_U => winner2,
    loser_shifted_U  => loser2);

  man1 <= ('0' & winner2(26 downto 0)) - ('0' & loser2(26 downto 0)) when (subflag = '1') else
          ('0' & winner2(26 downto 0)) + ('0' & loser2(26 downto 0));

  moveUp_U : moveup port map (
    man1_U => man1,
    exp1_U => exp1,
    man2_U => man2,
    exp2_U => exp2,
	 siginf2_U => siginf2);

  shiftUpper_U : shiftupper port map (
    man2_U => man2,
    exp2_U => exp2,
    man3_U => man3,
    exp3_U => exp3,
	 siginf2_U => siginf2);

  round_U : round port map (
    man3_U => man3,
    exp3_U => exp3,
    man4_U => man4,
    exp4_U => exp4);

  output <= x"00000000"
              when (anszero = '1') else
            winner1
              when ((sigzero = '1') or (siginf = '1')) else
						x"00000000"
						  when exp4( 7 downto 0) = x"00" and man4(22 downto 0) = "00000000000000000000000" else
            sign & exp4( 7 downto 0) & man4(22 downto 0);
end struct;
