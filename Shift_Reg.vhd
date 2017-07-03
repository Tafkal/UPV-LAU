--! @file Shift_Reg.vhd
--! @brief A shift register implementation.
--! @details This is a simple shift register with declarable bit width.\n
--! \n 
--! @author Stefan Vukcevic
--! @date 25/06/2017
--! @version 1.0
--! \n 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Entity declaration for Shift_Reg
--! @details 
--! The number_of_bits generic is used for defining the width of the data.
--! If the Load signal is active on the rising edge of the clock signal
--! Data from P_in will be stored in the register and P_out will take it's
--! value. \n
--! If the Shift signal is active on the rising edge of the clock signal
--! the data stored in the register will be shifted right once, and the S_in
--! value will be added to the new "empty" left space. \n
--! S_out is always the LSB of the data stored in the register. \n
--! Special case when Load AND Shift are active on the rising edge of the clock
--! the machine takes the P_in signal, shifts it, and gives it S_in in the place
--! of MSB, essencialy doing the Load and Shift actions in the same time. \n\n 
--! @image html SReg_block.png "Fig. 1. A block symbol of the Shift_Reg component"
entity Shift_Reg is
	generic(
		--! Bit width of the register
		number_of_bits 	: integer := 32
	);
	
	
	port(
		--! Clock signal
		Clk 			: in std_logic;
		--! Reset signal
		Reset 		: in std_logic;
		--! Parallel input signal vector
		P_in  		: in std_logic_vector(number_of_bits-1 downto 0);
		--! Serial input signal
		S_in			: in std_logic;
		--! Shift signal
		Shift			: in std_logic;
		--! Load signal
		Load			: in std_logic;
		
		--! Parallel output signal vector
		P_out			: out std_logic_vector(number_of_bits-1 downto 0);
		--! Serial output signal vector
		S_out			: out std_logic
	);
	
end entity Shift_Reg;

--! @brief Architecture for Shift_Reg
--! @details 
--! The architecture to do the things described in the entity declaration
--! of the shift register. \n\n
architecture Shift_Reg_arch of Shift_Reg is

--! Intermediate signal to buffer the output change.
signal reg_state : std_logic_vector(number_of_bits - 1 downto 0);

begin

--! The process that defines the shift register behaviour.
sreg : process (Clk, Reset)
begin

	if (Reset = '1') then
		S_out <= '0';
		reg_state <= (others => '0');
	elsif (rising_edge(Clk)) then
		if ((Shift = '1') and (Load = '1')) then
			reg_state <= S_in & P_in(number_of_bits-1 downto 1);
			S_out <= P_in(1);
		elsif (Load = '1') then
			reg_state <= P_in;
			S_out <= P_in(0);
		elsif (Shift = '1') then
			S_out <= reg_state(1);
			reg_state <= S_in & reg_state(number_of_bits - 1 downto 1);	
		end if;
	end if;
	
end process;

P_out <= reg_state;

end architecture Shift_Reg_arch;