--=============================================================
--Ben Dobbins
--ES31/CS56
--This script is the SPI Receiver code for Lab 6, the voltmeter.
--Your name goes here: 
--=============================================================

--=============================================================
--Library Declarations
--=============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;			-- needed for arithmetic
use ieee.math_real.all;				-- needed for automatic register sizing
library UNISIM;						-- needed for the BUFG component
use UNISIM.Vcomponents.ALL;

--=============================================================
--Entitity Declarations
--=============================================================
entity spi_receiver is
	generic(
		N_SHIFTS 				: integer);
	port(
	    --1 MHz serial clock
		clk_port				: in  std_logic;	
    	
    	--controller signals
		take_sample_port 		: in  std_logic;	
		spi_cs_port			    : out std_logic;
        
        --datapath signals
		spi_s_data_port		    : in  std_logic;	
		adc_data_port			: out std_logic_vector(11 downto 0));
end spi_receiver; 

--=============================================================
--Architecture + Component Declarations
--=============================================================
architecture Behavioral of spi_receiver is
--=============================================================
--Local Signal Declaration
--=============================================================
signal shift_enable		: std_logic := '0';
signal load_enable		: std_logic := '0';
signal shift_reg	    : std_logic_vector(11 downto 0) := (others => '0');
type state_type is (sIdle, sShifting, sLoad);
signal cstate, nstate : state_type := sIdle;
signal nshifts : integer := 0;
signal done_shifting_sig : std_logic := '0';

begin
--=============================================================
--Controller:
--=============================================================
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--State Update: current state is next state
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
  state_update : process(clk_port)
  begin
    if rising_edge(clk_port) then
      cstate <= nstate;
    end if;
  end process state_update;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Next State Logic: depends on current state, take_sample input, and done_shifting signal
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  next_state_logic : process(cstate, take_sample_port, done_shifting_sig)
  begin
    nstate <= cstate;
    case cstate is
      when sIdle =>
        if take_sample_port = '1' then
          nstate <= sShifting;
        end if;
      when sShifting =>
        if done_shifting_sig = '1' then
          nstate <= sLoad;
        end if;
      when sLoad => nstate <= sIdle;
    end case;
  end process next_state_logic;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Output Logic: outputs of controller depends on state
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  output_logic : process(cstate)
  begin
    spi_cs_port <= '1';
    shift_enable <= '0';
    load_enable <= '0';
    case cstate is
      when sShifting =>
        shift_enable <= '1';
        spi_cs_port <= '0';
      when sLoad =>
        load_enable <= '1';
      when others =>
    end case;
  end process output_logic;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Timer Sub-routine: keep track of how long to shift
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  shift_count_logic : process(clk_port, shift_enable, nshifts)
  begin
    if rising_edge(clk_port) then
      if shift_enable = '1' then
        nshifts <= nshifts + 1;
      else
        nshifts <= 0;
      end if;
    end if;
  end process shift_count_logic;

  -- keeps track of when shifting is done using async signal
  async_shift_count_logic : process (nshifts)
  begin
    done_shifting_sig <= '0';
    if nshifts = N_SHIFTS-1 then
      done_shifting_sig <= '1';
    end if;
  end process async_shift_count_logic;

--=============================================================
--Datapath:
--=============================================================
shift_register: process(clk_port) 
begin
	if rising_edge(clk_port) then
		if shift_enable = '1' then shift_reg <= shift_reg(10 downto 0) & spi_s_data_port;
		end if;
		
		if load_enable = '1' then adc_data_port <= shift_reg;
		end if;
    end if;
end process;
end Behavioral; 
