-- Testbench for Thunderbird Project

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity thunderbird_tb is
--  Port ( );
end thunderbird_tb;

architecture testbench of thunderbird_tb is

component lab4_shell is
    Port ( 	
			clk_ext_port		: in std_logic;		-- mapped to external IO device (100 MHz Clock)				
			left_ext_port 	    : in std_logic;		-- mapped to external IO device (slide switch 15)
			right_ext_port		: in std_logic;		-- mapped to external IO device (slide switch  0)
			LC_ext_port			: out std_logic;    -- mapped to external IO device (LED 15)
			LB_ext_port			: out std_logic;    -- mapped to external IO device (LED 14)
			LA_ext_port			: out std_logic;    -- mapped to external IO device (LED 13)
			RA_ext_port			: out std_logic;    -- mapped to external IO device (LED  2)
			RB_ext_port			: out std_logic;    -- mapped to external IO device (LED  1)
			RC_ext_port			: out std_logic );  -- mapped to external IO device (LED  0)
end component;

signal clk_external : std_logic := '0';
signal left_slide   : std_logic := '0';
signal right_slide  : std_logic := '0';
signal LC_led			  : std_logic := '0';    
signal LB_led			  : std_logic := '0';    
signal LA_led			  : std_logic := '0';    
signal RA_led			  : std_logic := '0';    
signal RB_led			  : std_logic := '0';    
signal RC_led			  : std_logic := '0';

constant ext_clk_period     : time := 10ns;
constant system_clk_period  : time := 100ns;
      
begin

  -- set the port mappings
  dut: lab4_shell port map (
      clk_ext_port    => clk_external,
      left_ext_port   => left_slide,
      right_ext_port  => right_slide,
      LC_ext_port     => LC_led,
      LB_ext_port     => LB_led,
      LA_ext_port     => LA_led,
      RC_ext_port     => RC_led,
      RB_ext_port     => RB_led,
      RA_ext_port     => RA_led);

  -- set up the clock with correct period
  clkgen_proc: process
  begin
    clk_external <= not(clk_external);
    wait for ext_clk_period/2;
  end process clkgen_proc;

  stimulus_proc: process
  begin
    wait for 3*system_clk_period; -- hold off for 3 cycles

    left_slide <= '1'; -- run in hazard for a for a few cycles
    right_slide <= '1';
    wait for 4*system_clk_period;

    left_slide <= '0'; -- right turn
    wait for 4*system_clk_period;

    right_slide <= '0'; -- off for 2 cycles;
    wait for 2*system_clk_period;

    left_slide <= '1'; -- left turn;
    wait for 2*system_clk_period;

    right_slide <= '1'; -- hazard but ONLY once left_turn is done
    wait;
    
  end process stimulus_proc;

end testbench;
