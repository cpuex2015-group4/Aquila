library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity cmpexp is
  port (
    ina_U     : in  std_logic_vector (31 downto 0);
    inb_U     : in  std_logic_vector (31 downto 0);
    winner_U  : out std_logic_vector (31 downto 0);
    loser_U   : out std_logic_vector (31 downto 0);
    sigzero_U : out std_logic;
    siginf_U  : out std_logic;
    anszero_U : out std_logic);
end cmpexp;

architecture struct of cmpexp is

begin
  winner_U  <= ina_U when (ina_U(30 downto 0) > inb_U(30 downto 0)) else
               inb_U;
  loser_U   <= inb_U when (ina_U(30 downto 0) > inb_U(30 downto 0)) else
               ina_U;
  sigzero_U <= '1' when ((('0' & ina_U(30 downto 0)) = x"00000000") or
                       (('0' & inb_U(30 downto 0)) = x"00000000"))    else
               '0';
  siginf_U  <= '1' when ((('1' & ina_U(30 downto 0)) = x"ff800000") or
                       (('1' & inb_U(30 downto 0)) = x"ff800000"))    else
               '0';
  anszero_U <= '1' when ((ina_U(31) /= inb_U(31)) and (ina_U(30 downto 0) = inb_U(30 downto 0))) else
               '0';
end struct;
