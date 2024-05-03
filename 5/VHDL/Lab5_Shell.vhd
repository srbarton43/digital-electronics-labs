--=============================================================================
--ENGS 31/ CoSc 56
--Lab 5 Shell
--Ben Dobbins
--Eric Hansen
--=============================================================================

--=============================================================================
--Library Declarations:
--=============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


--=============================================================================
--Entity Declaration:
--=============================================================================
entity lab5_shell is
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
end lab5_shell;

--=============================================================================
--Architecture Type:
--=============================================================================
architecture behavioral_architecture of lab5_shell is

--=============================================================================
--Sub-Component Declarations:
--=============================================================================
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--System Clock Generation:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component system_clock_generation is
    Port (
        --External Clock:
            input_clk_port		: in std_logic;
        --System Clock:
            system_clk_port		: out std_logic);
end component;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Input Conditioning:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component button_interface is
  Port( clk_port            : in  std_logic;
        button_port         : in  std_logic;
        button_db_port      : out std_logic;
        button_mp_port      : out std_logic);	
end component;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Controller:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component lab5_controller is
  Port ( 
    --timing:
    clk_port 			: in std_logic;

    --control inputs:
    load_port		    : in std_logic;
    clear_port		    : in std_logic;

    --control outputs:
    term1_en_port	    : out std_logic;
    term2_en_port	    : out std_logic;
    sum_en_port		    : out std_logic;
    reset_port		    : out std_logic);
end component;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Datapath:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component lab5_datapath is
  Port ( 
    --timing:
    clk_port 	        : in std_logic;

    --control inputs:
    term1_en_port       : in std_logic;
    term2_en_port       : in std_logic;
    sum_en_port         : in std_logic;
    reset_port          : in std_logic;

    --datapath inputs:
    term_input_port     : in std_logic_vector(3 downto 0);

    --datapath outputs:
    term1_display_port  : out std_logic_vector(3 downto 0);
    term2_display_port  : out std_logic_vector(3 downto 0);
    answer_display_port : out std_logic_vector(3 downto 0);
    overflow_port       : out std_logic);
end component;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--7-Segment Display:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component mux7seg is
  Port (
    --should get the 1 MHz system clk
    clk_port 	: in  std_logic;

    y3_port 	: in  std_logic_vector(3 downto 0); --left most digit
    y2_port 	: in  std_logic_vector(3 downto 0);
    y1_port 	: in  std_logic_vector(3 downto 0);
    y0_port 	: in  std_logic_vector(3 downto 0); --right most digit
    dp_set_port : in  std_logic_vector(3 downto 0); --decimal points
    seg_port 	: out std_logic_vector(0 to 6);	    --segments (a...g)
    dp_port 	: out std_logic;		    --decimal point
    an_port 	: out std_logic_vector (3 downto 0) );	--anodes
end component;

--=============================================================================
--Signal Declarations: 
--=============================================================================
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Timing:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
signal sys_clk_port_sig : std_logic := '0';
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Controller:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
signal load_port_sig      : std_logic := '0';
signal clear_port_sig     : std_logic := '0';
signal term1_en_port_sig  : std_logic := '0';
signal term2_en_port_sig  : std_logic := '0';
signal sum_en_port_sig    : std_logic := '0';
signal reset_port_sig     : std_logic := '0';
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Datapath:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
signal term1_disp_port_sig  : std_logic_vector(3 downto 0) := "0000";
signal term2_disp_port_sig  : std_logic_vector(3 downto 0) := "0000";
signal answer_disp_port_sig : std_logic_vector(3 downto 0) := "0000";
signal dp_set               : std_logic_vector(3 downto 0) := "0000";
signal overflow         : std_logic := '0'; --You get this one for free!


--=============================================================================
--Port Mapping (wiring the component blocks together): 
--=============================================================================
begin
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Wire the system clock generator into the shell with a port map:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  clocking: system_clock_generation port map(
    input_clk_port  =>  clk_ext_port,     -- External clock
    system_clk_port =>  sys_clk_port_sig);   -- System clock
	
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Wire the input conditioning block into the shell with a port map:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Wiring the port map in twice generates two separate instances of one component
  load_monopulse: button_interface port map(
    clk_port            =>     sys_clk_port_sig,
    button_port         =>     op_ext_port,
    button_db_port      =>     open,
    button_mp_port      =>     load_port_sig);

  clear_monopulse: button_interface port map(
    clk_port            =>     sys_clk_port_sig,
    button_port         =>     clear_ext_port,
    button_db_port      =>     clear_port_sig,
    button_mp_port      =>     open); 
    
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Wire the controller into the shell with a port map:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  controller: lab5_controller port map(
    clk_port	 	  =>     sys_clk_port_sig,
    load_port  	          =>     load_port_sig,
    clear_port            =>     clear_port_sig,
    term1_en_port 	  =>     term1_en_port_sig,
    term2_en_port 	  =>     term2_en_port_sig,
    sum_en_port 	  =>     sum_en_port_sig,
    reset_port 		  =>     reset_port_sig);
	
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Wire the datapath into the shell with a port map:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  datapath: lab5_datapath port map(
    clk_port	 	=>     sys_clk_port_sig,
    term1_en_port 	=>     term1_en_port_sig,
    term2_en_port 	=>     term2_en_port_sig,
    sum_en_port 	=>     sum_en_port_sig,
    reset_port		=>     reset_port_sig,
    term_input_port	=>     term_input_ext_port,
    term1_display_port  =>     term1_disp_port_sig,
    term2_display_port  =>     term2_disp_port_sig,
    answer_display_port =>     answer_disp_port_sig,
    overflow_port	=>     overflow);
		
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Wire the 7-segment display into the shell with a port map:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  dp_set <= "000" & overflow;
              
  seven_seg: mux7seg port map(
    clk_port	=>     sys_clk_port_sig,   --should get the 1 MHz system clk
    y3_port	=>     term1_disp_port_sig,   --left most digit
    y2_port 	=>     term2_disp_port_sig,   --center left digit
    y1_port 	=>     "0000",   --center right digit
    y0_port 	=>     answer_disp_port_sig,   --right most digit
    dp_set_port => dp_set, --you get this one for free too
    seg_port 	=>     seg_ext_port,
    dp_port 	=>     dp_ext_port,
    an_port 	=>     an_ext_port);	
	
end behavioral_architecture;
