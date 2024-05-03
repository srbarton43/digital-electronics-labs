--=============================================================================
--Library Declarations:
--=============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;
library UNISIM;
use UNISIM.VComponents.all;

--=============================================================================
--Entity Declaration:
--=============================================================================
entity lab5_controller_tb is
end entity;

--=============================================================================
--Architecture
--=============================================================================
architecture testbench of lab5_controller_tb is

--=============================================================================
--Component Declaration
--=============================================================================
component lab5_controller is
    Port ( 
      --timing:
      clk_port 		: in std_logic;

      --control inputs:
      load_port	      	: in std_logic;
      clear_port        : in std_logic;

      --control outputs:
      term1_en_port	: out std_logic;
      term2_en_port	: out std_logic;
      sum_en_port	: out std_logic;
      reset_port	: out std_logic);
end component;

--=============================================================================
--Signals
--=============================================================================
signal ext_clk : std_logic := '0';
signal load_port_sig, clear_port_sig : std_logic := '0';
signal term1_en_port, term2_en_port, sum_en_port: std_logic := '0';
signal reset_port : std_logic := '0';

-- external clock period (100 MHz)
constant CLK_PERIOD : time := 10 ns;
-- clock divider clock period (1 MHz)
constant SYS_CLK_PERIOD : time := 10 ns;

begin

--=============================================================================
--Port Map
--=============================================================================
uut: lab5_controller 
	port map(		
		clk_port 	=> ext_clk,
		load_port 	=> load_port_sig,
		clear_port 	=> clear_port_sig,
		term1_en_port 	=> term1_en_port, 
		term2_en_port 	=> term2_en_port,
		sum_en_port 	=> sum_en_port,
		reset_port 	=>	reset_port);

--=============================================================================
--clk_100MHz generation 
--=============================================================================
clkgen_proc: process
begin
  ext_clk <= '1';
  wait for CLK_PERIOD/2;
  ext_clk <= '0';
  wait for CLK_PERIOD/2;
end process clkgen_proc;

--=============================================================================
--Stimulus Process
--=============================================================================
stim_proc: process
begin				
  -- wait at sInit;
  clear_port_sig <= '1';
  wait for 3*SYS_CLK_PERIOD;

  -- normal sum operation
  clear_port_sig <= '0';
  wait for 1*SYS_CLK_PERIOD;
  load_port_sig <= '1';
  wait for SYS_CLK_PERIOD;
  load_port_sig <= '0'; -- sA
  wait for SYS_CLK_PERIOD;
  load_port_sig <= '1'; -- sWaitB
  wait for SYS_CLK_PERIOD;
  load_port_sig <= '0'; -- sB
  wait for SYS_CLK_PERIOD;
  load_port_sig <= '1'; -- sWaitSum
  wait for SYS_CLK_PERIOD;
  load_port_sig <= '0'; -- sSum;
  wait for 2*SYS_CLK_PERIOD; -- should be at sum state
  clear_port_sig <= '1';
  wait for SYS_CLK_PERIOD;
  
  -- clear prematurely
  clear_port_sig <= '0';
  load_port_sig <= '1';
  wait for SYS_CLK_PERIOD;
  load_port_sig <= '0';
  wait for 3*SYS_CLK_PERIOD; -- wait at sWaitB
  clear_port_sig <= '1';
  wait for SYS_CLK_PERIOD;
  clear_port_sig <= '0';
  wait for SYS_CLK_PERIOD;

  -- hold clear and toggle load
  clear_port_sig <= '1';
  wait for SYS_CLK_PERIOD;
  load_port_sig <= '1';
  wait for SYS_CLK_PERIOD;
  load_port_sig <= '0';
  wait for SYS_CLK_PERIOD;
  load_port_sig <= '1';
  wait for SYS_CLK_PERIOD;
  load_port_sig <= '0';
  wait for SYS_CLK_PERIOD;
  wait for 3*SYS_CLK_PERIOD;
  wait;
end process stim_proc;

end testbench;
