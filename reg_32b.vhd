--! @file reg_32b.vhd
--! @brief 32-bit register
--! @details This file describes behaviour of 32-bit register. 
--! It has the reg_32b's entity interface description and
--! and one behavioral architecture description. \n
--! \n
--! @author Natalija Colic 90/2013 \n
--! @date 1/4/2017
--! @version 1.0


library IEEE;
use IEEE.std_logic_1164.all;

--! @brief Entity declaration for reg_32b
--! @details
--! reg_32b is a sequential component that based on signal <b>input_valid</b>, stores 32-bit value
--! The interface description is shown 
--! @image html reg_32b_block.png "reg_32b block"


entity reg_32b is
port
	(       --Input ports
                
                --! Input value 
		input_num   : in std_logic_vector (31 downto 0);
		
		--! clk signal
                clk         : in std_logic;
		--! Sequential circuit reset signal
                reset       : in std_logic;
		
                --! Input value is valid and needs to be stored
                input_valid : in std_logic;
		
		-- Output ports
		
		--! Stored value
                output_num  : out std_logic_vector (31 downto 0)
	);
end reg_32b;

--! @brief Behavioral architecture for reg_32b
--! @details
--! Input clock <b>clk</b> is used for sequential logic. 
--! Signal <b>input_valid</b> is used for determining if the value should be stored.




architecture reg_32b_behavioral of reg_32b is

begin

--! Sequential logic
	--! When reset is asserted, the output is all 0.
	--! On rising edge of <b>clk<b/> and if <b>input_valid</b> value is written into the register.

register_process: process (clk, reset, input_valid) is
begin

	if (reset = '1') then
		output_num <= x"00000000";
	
	elsif (rising_edge(clk)) then
		
		if (input_valid = '1') then
			output_num <= input_num;
			
		end if;
	
	end if;
	
end process;

end reg_32b_behavioral;
		
	