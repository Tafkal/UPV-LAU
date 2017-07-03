--! @file exp_fp_value.vhd
--! @brief Generating float point value
--! @details This file describes generation of 32-bit floating point exponent. 
--! It has the exp_fp_value's entity interface description and
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

--! @brief Entity declaration for exp_fp_value
--! @details
--! exp_fp_value is a sequential component that based on exponent sign, index for LUT table 
--! in which are stored 3 LSB bits of exponent floating point value' s exponent and 6 MSB bits of 
--! of exponent floating point value' s mantissa, generates exponent's floating point value.
--! The interface description is shown in Fig. 1
--! @image html exp_fp_value.png "Fig. 1. exp_fp_value block"


entity exp_fp_value is
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
end exp_fp_value;


--! @brief Behavioral architecture for exp_fp_value
--! @details
--! Input clock <b>clk</b> is used for sequential logic. 
--! Signal <b>exp_sgn</b> is used for determining the sign of the floating point representation. If it 1 the sign bit is 0 and vice versa.
--! Based on the signal <b>exp_lut_index</b> it is determinend what bits 
--! are MSB bits of exponent in floating point representation. In case that exponent is 0
--! which means that <b>exp_lut_index</b>  is equal to 127, 5 MSB bits in exponent are
--! all 0. In case that exponent is 1 which means that <b>exp_lut_index</b> is equal to 126, 
--! 5 MSB bits in exponent are "01111". In all the other cases MSB bits are equal to "10000".
--! Lower 3 bits of the exponent represent 3 MSB bits of data read from  LUT <b>exp_lut_data</b>.
--! Lower 6 bits of <b>exp_lut_data</b> represent 6 MSB bits of mantissa in the floating point representation
--! while lower bits are all 0.

architecture exp_fp_behavioral of exp_fp_value is

signal exp_0, exp_1, exp             : std_logic; --indicators for exponent equal 0, 1 or other 
signal exp_0_vec, exp_1_vec, exp_vec : std_logic_vector (4 downto 0); --masks based on indicators above
signal exp_fp_temp                   : std_logic_vector (31 downto 0); --signal used to store temorarily the result

begin

	exp_0           <= '1' when (unsigned(exp_lut_index) = 127 ) else
							 '0'; -- check if exponent is 1
	exp_1           <= '1' when (unsigned(exp_lut_index) = 126 ) else
							 '0'; -- check if exponent is 0
	exp             <= not (exp_0 or exp_1) ; -- if exponent is not 0 or 1
	
	exp_0_vec       <= (others => exp_0); --make mask based on indicators 
	exp_1_vec       <= (others => exp_1); --make mask based on indicators
	exp_vec         <= (others => exp);   --make mask based on indicators

	exp_fp_temp(31)           <= not exp_sgn; -- sign of the floating point representation
	
	exp_fp_temp(30 downto 26) <= ("00000" and exp_0_vec) or ("01111" and exp_1_vec) or ("10000" and exp_vec); --determining 5 MSB bits of the exponent in float point representation
	
	exp_fp_temp(25 downto 23) <= exp_lut_data(8 downto 6); -- 3 LSB bits of the exponent in float point representation
	
	exp_fp_temp(22 downto 17) <= exp_lut_data(5 downto 0); -- 6 MSB bits of the mantissa in float point representation
	
	exp_fp_temp(16 downto 0)  <= (others => '0'); --LSB bits of the mantissa in float point representation

	--! Sequential logic
	--! When reset is asserted, the output is all 0.
	--! On rising edge of <b>clk<b/> temporary value is written into the final result. 
	exp_process: process (clk, reset) is
	begin
	
		if (reset = '1') then
			exp_fp <= x"00000000";
		
		elsif (rising_edge(clk)) then
			exp_fp <= exp_fp_temp;
		
		end if;
	
	end process;

end exp_fp_behavioral;	
		
	
	




		