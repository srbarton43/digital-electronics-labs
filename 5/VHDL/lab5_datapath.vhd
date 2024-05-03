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
entity lab5_datapath is
  Port ( 
    --timing:
    clk_port 			 : in std_logic;

    --control inputs:
    term1_en_port        : in std_logic;
    term2_en_port        : in std_logic;
    sum_en_port          : in std_logic;
    reset_port           : in std_logic;

    --datapath inputs:
    term_input_port      : in std_logic_vector(3 downto 0);

    --datapath outputs:
    term1_display_port   : out std_logic_vector(3 downto 0);
    term2_display_port   : out std_logic_vector(3 downto 0);
    answer_display_port  : out std_logic_vector(3 downto 0);
    overflow_port		 : out std_logic);
end lab5_datapath;

--=============================================================================
--Architecture Type:
--=============================================================================
architecture behavioral_architecture of lab5_datapath is
--=============================================================================
--Signal Declarations: 
--=============================================================================
--Registers
signal A_reg : std_logic_vector(3 downto 0) := "0000";
signal B_reg : std_logic_vector(3 downto 0) := "0000";
signal sum_reg : std_logic_vector(3 downto 0) := "0000";
signal overflow_reg : std_logic := '0';
--Other Signals
signal sum_sig : unsigned(4 downto 0) := "00000";
signal overflow_sig : std_logic := '0';
signal carry_in_bit : std_logic := '0';
--=============================================================================
--Processes: 
--=============================================================================
begin

-- Here is logic for the first operand, A's register
-- clocked process since it is a register
A_reg_logic : process(clk_port, term1_en_port, term_input_port, reset_port)
begin
  if rising_edge(clk_port) then
    if (reset_port = '1') then
      A_reg <= "0000";
    elsif term1_en_port = '1' then
      A_reg <= term_input_port;
    end if;
  end if;
end process A_reg_logic;

-- Here is logic for the second operand, B's register
-- clocked process since it is a register
B_reg_logic : process(clk_port, term2_en_port, term_input_port, reset_port)
begin
  if rising_edge(clk_port) then
    if (reset_port = '1') then
      B_reg <= "0000";
    elsif term2_en_port = '1' then
      B_reg <= term_input_port;
    end if;
  end if;
end process B_reg_logic;

-- Here is logic for the sum register
-- clocked process since it is a register
sum_reg_logic : process(clk_port, sum_en_port, reset_port, sum_sig)
begin
  if rising_edge(clk_port) then
    if reset_port = '1' then
      sum_reg <= "0000";
    elsif sum_en_port = '1' then
      sum_reg <= std_logic_vector(sum_sig(3 downto 0));
    end if;
  end if;
end process sum_reg_logic;

-- clocked process for the overflow register
-- takes the value of overflow signal if sum_enabled
overflow_reg_logic : process(clk_port, sum_en_port, reset_port, sum_sig)
begin
  if rising_edge(clk_port) then
    if reset_port = '1' then
      overflow_reg <= '0';
    elsif sum_en_port = '1' then
      overflow_reg <= overflow_sig;
    end if;
  end if;
end process overflow_reg_logic;

-- async process to calculate the SUM value
sum_logic : process(A_reg, B_reg)
begin
  sum_sig <= unsigned('0' & A_reg) + unsigned('0' & B_reg);
end process sum_logic;

-- async process for getting the overflow bit
overflow_logic : process(sum_sig)
begin
  overflow_sig <= sum_sig(4);
end process overflow_logic;

-- tie registers to output pins
term1_display_port <= A_reg;
term2_display_port <= B_reg;
answer_display_port <= sum_reg;
overflow_port <= overflow_reg;

end behavioral_architecture;

