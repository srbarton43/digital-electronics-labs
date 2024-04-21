--=============================================================================
--ENGS 31/ CoSc 56
--Basic4bitCounter
--Ben Dobbins
--Eric Hansen
--=============================================================================

--=============================================================================
--Library Declarations:
--=============================================================================
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

--=============================================================================
--Entity Declaration:
--=============================================================================
entity bcd_digit is
  port(clk_port	: in  std_logic;
    	 reset_port	: in  std_logic;
       enable_port : in std_logic;
    	 y_port		: out std_logic_vector(3 downto 0);
       tc_port	: out std_logic );
end entity;

--=============================================================================
--Architecture Type:
--=============================================================================            
architecture behavior of bcd_digit is

--=============================================================================
--Signal Declarations: 
--=============================================================================
-- internal unsigned signal for the counter's register
signal y: unsigned(3 downto 0) := "0000";
signal tc: std_logic := '0';

--=============================================================================
--Processes: 
--=============================================================================
begin
	
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--4-Bit Counter:
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- the counter itself
process(clk_port, enable_port)						
begin
	if rising_edge(clk_port) then
		if reset_port = '1' then y <= "0000";
		elsif enable_port = '1' then
		  if tc = '1' then y <= "0000";
		  else y <= y+1;		
		  end if;
		end if; 								 
	end if;
end process;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Terminal Count:
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
process(y)
begin
	-- tc is asynchronous, derived from y
	if y = "1001" then tc <= '1';
	else tc <= '0';
	end if;
end process;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Output Mapping:
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
y_port <= std_logic_vector(y); -- typecast y to std_logic_vector for output
tc_port <= tc;

end behavior;    


