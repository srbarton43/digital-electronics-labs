--=============================================================================
--ENGS 31/ CoSc 56 22S
--Lab 4 Prelab Thunderbird FSM VHDL Model
--B.L. Dobbins, E.W. Hansen, Professor Luke
--
-- Slight tweaks by Tad
--=============================================================================

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
entity lab4_thunderbird_fsm is
    Port (
		--timing:
			clk_port 		: in std_logic;
		--control inputs:
			left_port 	    : in std_logic;
			right_port      : in std_logic;
		--LED outputs:
			LC_port			: out std_logic;
			LB_port			: out std_logic;
			LA_port			: out std_logic;
			RA_port			: out std_logic;
			RB_port			: out std_logic;
			RC_port			: out std_logic );
end lab4_thunderbird_fsm;

--=============================================================================
--Architecture Type:
--=============================================================================
architecture behavioral_architecture of lab4_thunderbird_fsm is
--=============================================================================
--Signal Declarations: 
--=============================================================================
type state_type is (OFF, HAZARD, R1, R2, R3, L1, L2, L3);
signal current_state, next_state : state_type;
--=============================================================================
--Processes: 
--=============================================================================
begin
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Update the current state (synchronous):
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
StateUpdate: process(clk_port)
begin
	if rising_edge(clk_port) then
    	current_state <= next_state;
    end if;
end process StateUpdate;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Next State Logic (asynchronous):
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NextStateLogic: process(current_state, left_port, right_port)
begin
  -- set default next_state to current_state
	next_state <= current_state;
	case current_state is
    	when OFF =>
        	if left_port = '1' and right_port = '1' then
            	next_state <= HAZARD;
            elsif left_port = '1' then
            	next_state <= L1;
            elsif right_port = '1' then
            	next_state <= R1;
            end if;
        when HAZARD => next_state <= OFF;
        when R1 => next_state <= R2;
        when R2 => next_state <= R3;
        when R3 => next_state <= OFF;
        when L1 => next_state <= L2;
        when L2 => next_state <= L3;
        when L3 => next_state <= OFF;
    end case;
end process NextStateLogic; 

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Output Logic (asynchronous):
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
OutputLogic: process(current_state)
begin
  -- set the default outputs
	LC_port <= '0';
	LB_port	<= '0';
	LA_port	<= '0';
	RA_port	<= '0';
	RB_port	<= '0';
	RC_port <= '0';
	case current_state is
		when HAZARD =>
        	LC_port <= '1';
			LB_port	<= '1';
			LA_port	<= '1';
			RA_port	<= '1';
			RB_port	<= '1';
			RC_port <= '1';
        when R1 => RA_port <= '1';
        when L1 => LA_port <= '1';
        when R2 =>
        	RA_port <= '1';
            RB_port <= '1';
        when L2 =>
        	LA_port <= '1';
            LB_port <= '1';
       	when R3 =>
           	RA_port <= '1';
            RB_port <= '1';
            RC_port <= '1';
        when L3 =>
        	LA_port <= '1';
            LB_port <= '1';
            LC_port <= '1';
		when others =>
    end case;
end process OutputLogic;
				
end behavioral_architecture;
