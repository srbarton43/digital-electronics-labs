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
entity lab5_shell_tb is
end entity;

--=============================================================================
--Architecture
--=============================================================================
architecture testbench of lab5_shell_tb is

--=============================================================================
--Component Declaration
--=============================================================================
component lab5_shell is
  Port (

    -- mapped to external IO device (100 MHz Clock)			        	
    clk_ext_port	        : in std_logic;

    -- slide switches SW15 (MSB) down to SW12 (LSB)
    term_input_ext_port		: in std_logic_vector(3 downto 0);
    
    -- button center
    op_ext_port		        : in std_logic;

    -- button down
    clear_ext_port		: in std_logic;			

    seg_ext_port		: out std_logic_vector(0 to 6);
    dp_ext_port			: out std_logic;
    an_ext_port			: out std_logic_vector(3 downto 0) 
    );  				
end component;


--=============================================================================
--Signals
--=============================================================================
-- input signals
signal ext_clk : std_logic := '0';
signal term_input_ext : std_logic_vector(3 downto 0) := (others => '0');
signal op_ext, clear_ext : std_logic := '0';

--output signals
signal seg_ext_port : std_logic_vector(0 to 6) := (others => '0');
signal dp_ext_port : std_logic := '0';
signal an_ext_port : std_logic_vector(3 downto 0);

-- external clock period (100 MHz)
constant CLK_PERIOD : time := 10 ns;
-- clock divider clock period (1 MHz)
constant SYS_CLK_PERIOD : time := 110 * 100 ns; -- to get through debouncer

begin

--=============================================================================
--Port Map
--=============================================================================
uut: lab5_shell 
	port map(		
		clk_ext_port 	=> ext_clk,
		term_input_ext_port 	=> term_input_ext,
		op_ext_port 	=> op_ext,
		clear_ext_port 	=> clear_ext, 
		seg_ext_port 	=> seg_ext_port,
		dp_ext_port 	=> dp_ext_port,
		an_ext_port 	=>	an_ext_port);

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
  wait for 3*SYS_CLK_PERIOD;

  -- NON-OVERFLOW
  term_input_ext <= "0010";   --   2
  op_ext <= '1';
  wait for SYS_CLK_PERIOD;
  op_ext <= '0';
  wait for SYS_CLK_PERIOD;
  term_input_ext <= "0100";   -- + 4
  op_ext <= '1';
  wait for SYS_CLK_PERIOD;
  op_ext <= '0';
  wait for SYS_CLK_PERIOD;
  op_ext <= '1';              -- = 6 (0110)
  wait for SYS_CLK_PERIOD;
  op_ext <= '0';
  wait for SYS_CLK_PERIOD;

  clear_ext <= '1';
  wait for SYS_CLK_PERIOD;
  clear_ext <= '0';
  wait for SYS_CLK_PERIOD;
  
  -- OVERFLOW
  term_input_ext <= "0111";   --   7
  op_ext <= '1';
  wait for SYS_CLK_PERIOD;
  op_ext <= '0';
  wait for SYS_CLK_PERIOD;
  term_input_ext <= "1010";   -- +10
  op_ext <= '1';
  wait for SYS_CLK_PERIOD;
  op_ext <= '0';
  wait for SYS_CLK_PERIOD;
  op_ext <= '1';              -- = 17 (0001) overflow
  wait for SYS_CLK_PERIOD;
  op_ext <= '0';
  wait for SYS_CLK_PERIOD;
  wait;
end process stim_proc;

end testbench;
