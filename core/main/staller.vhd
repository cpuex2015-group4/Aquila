   --staller.vhd
   --IS.S Imai Yuki
   --Fri Feb  5 00:12:51 2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.global_types.all;

package staller_interface is

  type staller_in_type is record
    Ex_hazzard:boolean;
    Wb_hazzard:boolean;
  end record;
  constant staller_in_init:staller_in_type:=(
    Ex_hazzard=>false,
    Wb_hazzard=>false
    );
  type staller_out_type is record
    F_stall:boolean;
    D_stall:boolean;
    Ex_stall:boolean;
    WB_stall:boolean;
  end record;
  constant staller_out_init:staller_out_type:=(
    F_stall=>false,
    D_stall=>false,
    Ex_stall=>false,
    WB_stall=>false
    );
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.global_types.all;
use work.staller_interface.all;

entity staller is
  port(
    clk,rst:in  std_logic;
    port_in       :in  staller_in_type;
    port_out      :out staller_out_type
  );
end staller;

architecture RTL of staller is
  --types and constants

begin
  comb:process(port_in)
    variable vout:staller_out_type;
  begin
    vout:=staller_out_init;

    vout.F_stall:=port_in.Ex_hazzard or port_in.Wb_hazzard;
    vout.D_stall:=port_in.Ex_hazzard or port_in.Wb_hazzard;
    vout.Ex_stall:=port_in.Wb_hazzard;
    port_out<=vout;
  end process;
end RTL;
