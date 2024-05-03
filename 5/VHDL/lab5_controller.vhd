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
entity lab5_controller is
  Port ( 
    --timing:
    clk_port 		: in std_logic;

    --control inputs:
    load_port	      	: in std_logic;
    clear_port          : in std_logic;

    --control outputs:
    term1_en_port	: out std_logic;
    term2_en_port	: out std_logic;
    sum_en_port		: out std_logic;
    reset_port		: out std_logic);
end lab5_controller;

--=============================================================================
--Architecture Type:
--=============================================================================
architecture behavioral_architecture of lab5_controller is
--=============================================================================
--Signal Declarations: 
--=============================================================================
type state_type is (sInit, sA, sWaitB, sB, sWaitSum, sSum);
signal current_state, next_state : state_type := sInit;
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
NextStateLogic: process(current_state,load_port,clear_port)
begin
    -- default
    next_state <= current_state;
    if clear_port = '1' then
        next_state <= sInit;
    else
        case current_state is
            when sInit => 
                if load_port = '1' then
                    next_state <= sA;
                end if;
            when sA => next_state <= sWaitB;
            when sWaitB =>
                if load_port = '1' then
                    next_state <= sB;
                end if;
            when sB => next_state <= sWaitSum;
            when sWaitSum =>
                if load_port = '1' then
                    next_state <= sSum;
                end if;
            when others =>
        end case;
    end if;
end process NextStateLogic;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Output Logic (asynchronous):
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
OutputLogic: process(current_state)
begin
    -- defaults
    term1_en_port <= '0';
    term2_en_port <= '0';
    reset_port <= '0';
    sum_en_port <= '0';
    case current_state is
        when sInit => reset_port <= '1';
        when sA => term1_en_port <= '1';
        when sB => term2_en_port <= '1';
        when sSum => sum_en_port <= '1';
        when others =>
    end case;
    
end process OutputLogic;
				
end behavioral_architecture;
