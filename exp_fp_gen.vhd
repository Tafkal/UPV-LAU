--! @file exp_fp_gen.vhd
--! @brief Generating float point value
--! @details This file describes generation of 32-bit floating point exponent. 
--! It has the exp_fp_gen's entity interface description and
--! and one behavioral architecture description. \n
--! \n
--! @author Natalija Colic 90/2013 \n
--! @date 1/4/2017
--! @version 1.0
--!
--! <b>References:</b> \n
--! [1] <i>Efficient floating-point logarithm unit for FPGA-s</i>, 
--! Nikolaos Alachiotis, Alexandros Stamatakis


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

--! @brief Entity declaration for exp_fp_gen
--! @details
--! exp_fp_gen is a sequential component that based on 8 bit exponent value, generates exponent's floating point value. 
--! The interface description is shown in Fig. 1
--! @image html exp_fp_gen.png "Fig. 1. exp_fp_gen block" 

entity exp_fp_gen is
port 
	(
		--Input ports
		
		--! Exponent
		exp_value    : in std_logic_vector (7 downto 0);
		
		--! clk signal
		clk          : in std_logic;
		--! Sequential circuit reset signal
		reset        : in std_logic;
		
		--Output ports
		
		--! Output float point value of the exponent
		exp_fp_out : out std_logic_vector (31 downto 0)
	);
end exp_fp_gen;

--! @brief Behavioral architecture for exp_fp_gen
--! @details
--! Input clock <b>clk</b> is used for sequential logic. 
--! Signal <b>exp_value</b> is used for determining the index for LUT. Since two numbers of equal absolute
--! values and oposite signs have the same float point repesentation that also differ in sign only which is used
--! to reduce the size of LUT by 50% storing only values for exponents in range 0 to 127 (decimal value).
--! If <b>exp_value<b/> is in that range than its value is used to generate 6 bit index for the LUT. 
--! Otherwise the index is calculated by substracting <b>exp_value</b> from 254 which will return the value in range and 
--! yield correct index for seaching reduced LUT.
--! MSB bit of <b>exp_value<b/> determines the sign of the floating point representation. If it 1 the sign bit is 0 and vice versa.  
--! exp_fp_gen is implemented with exp_fp_value module for final generation and ram module for LUT 

architecture exp_fp_structural of exp_fp_gen is

component exp_fp_value 
port
	(
		--Input ports
		
		--! Sign of the exponent
		exp_sgn       : in std_logic;
		--! Index for LUT
		exp_lut_index : in std_logic_vector (6 downto 0);
		--! Data read fom the LUT
		exp_lut_data  : in std_logic_vector (8 downto 0);
		
		--! clk signal
		clk           : in std_logic;
		--! Sequential circuit reset signal
		reset         : in std_logic;
		-- Output ports
		
		--! Exponent's floating point representation		
		exp_fp        : out std_logic_vector (31 downto 0)
		
	);
end component;

component ram
port
	(
		--Input ports
		
		--! Address
		address  : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
		--! clk signal
		clock		: IN STD_LOGIC  := '1';
		--! Data for writing (in this case its used only fo read)
		data		: IN STD_LOGIC_VECTOR (8 DOWNTO 0) := (others => 'X');
		--! Write enable (in this case its used only fo read so its always inactive)
		wren		: IN STD_LOGIC := '0';
		--! Read data
		q		   : OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
	);
end component;

signal exp_index   : std_logic_vector (7 downto 0); --index(address) for LUT
signal mem_out     : std_logic_vector (8 downto 0); --read data
constant value_254 : std_logic_vector(7 downto 0):="11111110"; --254 binary

begin

with exp_value(7) select
	exp_index <= '0' & exp_value(6 downto 0)                     when '0',  --if exponent is lesser or equal than 127               
					 value_254 - exp_value                           when '1',  --if exponent is greater than 127
                (others => 'X')                                 when others; --other
				 
-- instantiating LUT				
memory_unit : ram port map (address => exp_index(6 downto 0), clock => clk, data => open, wren => open, q => mem_out); 

--instatiating exp_fp_value
U1 : exp_fp_value port map ( exp_sgn => exp_value(7), exp_lut_index =>exp_index(6 downto 0), exp_lut_data => mem_out,
                          clk =>clk, reset => reset, exp_fp => exp_fp_out);

end exp_fp_structural;