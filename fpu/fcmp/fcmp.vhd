library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.global_types;

package fcmp_package is
  function fcmp(inputA:word;inputB:word;mode:fcmp_mode)return boolean;
end package;

package body fcmp_package is
  function fcmp(inputA:word;inputB:word;mode:B_type)return boolean is
    variable lt : std_logic;
    variable eq : std_logic;
  begin
    eq := '1' when inputA(30 downto 0) = 0 and inputB(30 downto 0) = 0 else
          '1' when inputA = inputB else
          '0';
    lt := '0' when inputA(30 downto 0) = 0 and inputB(30 downto 0) = 0 else
          '1' when inputA(31) = '1' and inputB(31) = '0' else
          '1' when inputA(31) = '1' and inputB(31) = '1' and inputA(30 downto 0) > inputB(30 downto 0) else
          '1' when inputA(31) = '0' and inputB(31) = '0' and inputA(30 downto 0) < inputB(30 downto 0) else
          '0';

    output := (lt or eq) when mode = B_BLE else
              lt         when mode = B_BLT else
              eq         when mode = B_BEQ else
              '0';
    return output;
  end function;
end fcmp_package;
