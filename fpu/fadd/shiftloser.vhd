library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity shiftloser is
  port (
    winner_U         : in  std_logic_vector (31 downto 0);
    loser_U          : in  std_logic_vector (31 downto 0);
    sign_U           : out std_logic;
    subflag_U        : out std_logic;
    exp_U            : out std_logic_vector (7  downto 0);
    winner_shifted_U : out std_logic_vector (26 downto 0); -- 27bit / 1bit h & 23bit man & 1bit r & 1bit g & 1bit s
    loser_shifted_U  : out std_logic_vector (26 downto 0));
end shiftloser;

architecture struct of shiftloser is
begin
  sign_U           <= winner_U(31);
  subflag_U        <= '1' when (winner_U(31) /= loser_U(31)) else
                      '0';
  exp_U            <= winner_U(30 downto 23);
  winner_shifted_U <= '1' & winner_U(22 downto 0) & "000";
  loser_shifted_U  <= '1' & loser_U(22 downto 0) & "000"
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 0) else
                      "01" & loser_U(22 downto 0) & "00"
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 1) else
                      "001" & loser_U(22 downto 0) & '0'
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 2) else
                      "0001" & loser_U(22 downto 1) & loser_U(0)
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 3) else
                      "00001" & loser_U(22 downto 2) & (loser_U(1) or loser_U(0))
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 4) else
                      "000001" & loser_U(22 downto 3) & (loser_U(2) or loser_U(1) or loser_U(0))
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 5) else
                      "0000001" & loser_U(22 downto 4) & (loser_U(3) or loser_U(2) or loser_U(1) or loser_U(0))
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 6) else
                      "00000001" & loser_U(22 downto 5) & (loser_U(5) or loser_U(4) or loser_U(3) or loser_U(2) or loser_U(1) or loser_U(0))
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 7) else
                      "000000001" & loser_U(22 downto 6) & (loser_U(6) or loser_U(5) or loser_U(4) or loser_U(3) or loser_U(2) or loser_U(1) or loser_U(0))
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 8) else
                      "0000000001" & loser_U(22 downto 7) & (loser_U(7) or loser_U(6) or loser_U(5) or loser_U(4) or loser_U(3) or loser_U(2) or loser_U(1) or loser_U(0))
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 9) else
                      "00000000001" & loser_U(22 downto 8) & (loser_U(7) or loser_U(6) or loser_U(5) or loser_U(4) or loser_U(3) or loser_U(2) or loser_U(1) or loser_U(0))
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 10) else
                      "000000000001" & loser_U(22 downto 9) & (loser_U(8) or loser_U(7) or loser_U(6) or loser_U(5) or loser_U(4) or loser_U(3) or loser_U(2) or loser_U(1) or loser_U(0))
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 11) else
                      "0000000000001" & loser_U(22 downto 10) & (loser_U(9) or loser_U(8) or loser_U(7) or loser_U(6) or loser_U(5) or loser_U(4) or loser_U(3) or loser_U(2) or loser_U(1) or loser_U(0))
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 12) else
                      "00000000000001" & loser_U(22 downto 11) & (loser_U(10) or loser_U(9) or loser_U(8) or loser_U(7) or loser_U(6) or loser_U(5) or loser_U(4) or loser_U(3) or loser_U(2) or loser_U(1) or loser_U(0))
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 13) else
                      "000000000000001" & loser_U(22 downto 12) & (loser_U(11) or loser_U(10) or loser_U(9) or loser_U(8) or loser_U(7) or loser_U(6) or loser_U(5) or loser_U(4) or loser_U(3) or loser_U(2) or loser_U(1) or loser_U(0))
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 14) else
                      "0000000000000001" & loser_U(22 downto 13) & (loser_U(12) or loser_U(11) or loser_U(10) or loser_U(9) or loser_U(8) or loser_U(7) or loser_U(6) or loser_U(5) or loser_U(4) or loser_U(3) or loser_U(2) or loser_U(1) or loser_U(0))
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 15) else
                      "00000000000000001" & loser_U(22 downto 14) & (loser_U(13) or loser_U(12) or loser_U(11) or loser_U(10) or loser_U(9) or loser_U(8) or loser_U(7) or loser_U(6) or loser_U(5) or loser_U(4) or loser_U(3) or loser_U(2) or loser_U(1) or loser_U(0))
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 16) else
                      "000000000000000001" & loser_U(22 downto 15) & (loser_U(14) or loser_U(13) or loser_U(12) or loser_U(11) or loser_U(10) or loser_U(9) or loser_U(8) or loser_U(7) or loser_U(6) or loser_U(5) or loser_U(4) or loser_U(3) or loser_U(2) or loser_U(1) or loser_U(0))
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 17) else
                      "0000000000000000001" & loser_U(22 downto 16) & (loser_U(15) or loser_U(14) or loser_U(13) or loser_U(12) or loser_U(11) or loser_U(10) or loser_U(9) or loser_U(8) or loser_U(7) or loser_U(6) or loser_U(5) or loser_U(4) or loser_U(3) or loser_U(2) or loser_U(1) or loser_U(0))
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 18) else
                      "00000000000000000001" & loser_U(22 downto 17) & (loser_U(16) or loser_U(15) or loser_U(14) or loser_U(13) or loser_U(12) or loser_U(11) or loser_U(10) or loser_U(9) or loser_U(8) or loser_U(7) or loser_U(6) or loser_U(5) or loser_U(4) or loser_U(3) or loser_U(2) or loser_U(1) or loser_U(0))
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 19) else
                      "000000000000000000001" & loser_U(22 downto 18) & (loser_U(17) or loser_U(16) or loser_U(15) or loser_U(14) or loser_U(13) or loser_U(12) or loser_U(11) or loser_U(10) or loser_U(9) or loser_U(8) or loser_U(7) or loser_U(6) or loser_U(5) or loser_U(4) or loser_U(3) or loser_U(2) or loser_U(1) or loser_U(0))
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 20) else
                      "0000000000000000000001" & loser_U(22 downto 19) & (loser_U(18) or loser_U(17) or loser_U(16) or loser_U(15) or loser_U(14) or loser_U(13) or loser_U(12) or loser_U(11) or loser_U(10) or loser_U(9) or loser_U(8) or loser_U(7) or loser_U(6) or loser_U(5) or loser_U(4) or loser_U(3) or loser_U(2) or loser_U(1) or loser_U(0))
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 21) else
                      "00000000000000000000001" & loser_U(22 downto 20) & (loser_U(19) or loser_U(18) or loser_U(17) or loser_U(16) or loser_U(15) or loser_U(14) or loser_U(13) or loser_U(12) or loser_U(11) or loser_U(10) or loser_U(9) or loser_U(8) or loser_U(7) or loser_U(6) or loser_U(5) or loser_U(4) or loser_U(3) or loser_U(2) or loser_U(1) or loser_U(0))
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 22) else
                      "000000000000000000000001" & loser_U(22 downto 21) & (loser_U(20) or loser_U(19) or loser_U(18) or loser_U(17) or loser_U(16) or loser_U(15) or loser_U(14) or loser_U(13) or loser_U(12) or loser_U(11) or loser_U(10) or loser_U(9) or loser_U(8) or loser_U(7) or loser_U(6) or loser_U(5) or loser_U(4) or loser_U(3) or loser_U(2) or loser_U(1) or loser_U(0))
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 23) else
                      "0000000000000000000000001" & loser_U(22) & (loser_U(21) or loser_U(20) or loser_U(19) or loser_U(18) or loser_U(17) or loser_U(16) or loser_U(15) or loser_U(14) or loser_U(13) or loser_U(12) or loser_U(11) or loser_U(10) or loser_U(9) or loser_U(8) or loser_U(7) or loser_U(6) or loser_U(5) or loser_U(4) or loser_U(3) or loser_U(2) or loser_U(1) or loser_U(0))
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 24) else
                      "00000000000000000000000001" & (loser_U(22) or loser_U(21) or loser_U(20) or loser_U(19) or loser_U(18) or loser_U(17) or loser_U(16) or loser_U(15) or loser_U(14) or loser_U(13) or loser_U(12) or loser_U(11) or loser_U(10) or loser_U(9) or loser_U(8) or loser_U(7) or loser_U(6) or loser_U(5) or loser_U(4) or loser_U(3) or loser_U(2) or loser_U(1) or loser_U(0))
                          when ((winner_U(30 downto 23) - loser_U(30 downto 23)) = 25) else
                      "000000000000000000000000001";
end struct;