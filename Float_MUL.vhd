--! @file Float_Mul.vhd
--! @brief Floating point multiplication.
--! @details This is a implementation of the floating point multiplication algorithm.\n
--! \n 
--! @author Stefan Vukcevic
--! @date 26/06/2017
--! @version 1.1
--! \n
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Entity declaration for Float_Mul
--! @details 
--! The number_of_bits generic is for setting the input data width.\n
--! The mantissa_bits generic is for setting the width of the mantissa in the representation.\n
--! When you set A and B operands set the Start signal to high for at least one clock cycle.
--! When the multiplication process is finished it will signal with Finish that the result is
--! waiting in the Y register.\n\n
--! @image html Float_mul_block.png "Fig. 1. A block symbol of the Float_Mul component"
--! @image html Float_mul_FSM.png "Fig. 2. Internals of the Float_Mul component"
--! @image html Float_mul_FSM.png "Fig. 3. FSM of the Float_Mul component"
entity Float_Mul is
	generic(
		--! Bit width of the input
		number_of_bits 	: integer := 32;
		--! Mantissa part of the input
		mantissa_bits		: integer := 23
	);
	
	
	port(
		--! Clock signal
		Clk 			: in std_logic;
		--! Reset signal
		Reset 		: in std_logic;
		--! First operand signal vector
		A  			: in std_logic_vector(number_of_bits-1 downto 0) := (number_of_bits-1 downto 0 => '0');
		--! Second operand signal vector
		B 		 		: in std_logic_vector(number_of_bits-1 downto 0) := (number_of_bits-1 downto 0 => '0');
		--! Starting signal
		Start			: in std_logic := '0';
		
		--! Multiplication output signal
		Y				: out std_logic_vector(number_of_bits-1 downto 0);
		--! Multiplication finish signal
		Finish		: out std_logic
	);
	
end entity Float_Mul;

--! @brief Architecture for Float_Mul
--! @details 
--! The architecture to do the things described in the entity declaration
--! of the Float_Mul. \n\n
architecture Float_Mul_arch of Float_Mul is

--! Fixed point multiplication
component Fixed_Mul is
	generic(
		--! Bit width of the inputs
		number_of_bits 	: integer := 23
	);
	
	
	port(
		--! Clock signal
		Clk 			: in std_logic;
		--! Reset signal
		Reset 		: in std_logic;
		--! First input signal vector
		A  			: in std_logic_vector(number_of_bits-1 downto 0) := (number_of_bits-1 downto 0 => '0');
		--! Second input signal vector
		B 		 		: in std_logic_vector(number_of_bits-1 downto 0) := (number_of_bits-1 downto 0 => '0');
		--! Start signal
		Start			: in std_logic := '0';
		
		--! Output signal vector
		Y				: out std_logic_vector(2*number_of_bits+1 downto 0);
		--! Finish signal
		Finish		: out std_logic
	);
	
end component Fixed_Mul;

--! Fixed point adder
component Fixed_Adder is
	generic(
		--! Bit width of the inputs
		number_of_bits 	: integer := 8
	);
	
	
	port(
		--! Clock signal
		Clk 			: in std_logic;
		--! Reset signal
		Reset 		: in std_logic;
		--! First input signal vector
		A  			: in std_logic_vector(number_of_bits-1 downto 0) := (number_of_bits-1 downto 0 => '0');
		--! Second input signal vector
		B 		 		: in std_logic_vector(number_of_bits-1 downto 0) := (number_of_bits-1 downto 0 => '0');
		--! Start signal
		Start			: in std_logic := '0';
		
		--! Output signal vector
		Y				: out std_logic_vector(number_of_bits downto 0);
		--! Finish signal
		Finish		: out std_logic
	);
	
end component Fixed_Adder;

--! Definition of the states in the FSM.
type state_type_t is (idle_mul, start_mul, mul, finish_mul);
--! Current and next state signals.
signal state_reg, next_state 	: state_type_t := idle_mul;

--! Internal sign signal
signal internal_sign : std_logic := '0';
--! Internal offsetted exponent signal vector
signal internal_exp	: std_logic_vector(number_of_bits-mantissa_bits downto 0);
--! Internal mantissa signal vector
signal internal_man	: std_logic_vector(2*mantissa_bits+1 downto 0);
--! Output buffer
signal out_buffer		: std_logic_vector(number_of_bits-1 downto 0);
--! Exponent sum without compensation for the offset
signal exp_sum_out	: std_logic_vector(number_of_bits-mantissa_bits-1 downto 0);
--! Fixed point multiplication finish sign
signal fixed_mul_fin : std_logic := '0';
--! Exponent adding finish signal
signal exp_add_fin	: std_logic := '0';
--! Exponent offset compensation finish signal
signal off_sub_fin	: std_logic := '0';
--! All processes finished signal
signal all_finished	: std_logic := '0';
--! Constant signal of the exponent offset compensation
signal offset			: std_logic_vector(number_of_bits-mantissa_bits-1 downto 0) := ("11" & (number_of_bits-mantissa_bits-4 downto 0 => '0') & '1');
--! Final exponent calculation
signal final_exp		: std_logic_vector(number_of_bits-mantissa_bits downto 0);
--! Final mantissa calculation
signal final_man		: std_logic_vector(mantissa_bits-1 downto 0);
--! Mantissa case variable, to truncate the mantissa rightfully
signal man_case_var	: std_logic_vector (1 downto 0) := "00";
--! Counter to prolong the Finish signal
signal cnt			: integer range 0 to 1;
--! Float Zero signal without the sign, to catch a 0 input
signal zero_sign : std_logic_vector(number_of_bits-2 downto 0) := (others => '0');
begin

	--! Process that moves the FSM forward.
	fsm_reg : process(Clk, Reset, Start) is
	begin
		case (Reset) is
		when '1' =>
			state_reg <= idle_mul;
		when others =>
			if(rising_edge(Clk)) then
				state_reg <= next_state;
			end if;
		end case;
	end process;
	
	--! What the fsm does with control and output signals depending
	--! on the state it is.
	fsm_do : process(Clk, state_reg) is
	begin
		if (rising_edge(Clk)) then
			case (state_reg) is
			when idle_mul =>
				Finish <= '0';
			when start_mul =>
				Finish <= '0';
			when mul =>
				Finish <= '0';
			when finish_mul =>
				Finish <= '1';
				if ((A(number_of_bits-2 downto 0) = zero_sign) or (B(number_of_bits-2 downto 0) = zero_sign)) then
					Y <= (others => '0');
				else
					Y <= out_buffer;
				end if;
			end case;
		end if;
	end process;
	
	--! Next state decision making process.
	next_fsm_state : process(Clk, next_state, all_finished, Start) is
	begin
		if(falling_edge(Clk)) then
			case(state_reg) is
			when idle_mul =>
				case (Start) is
				when '1' =>
					next_state <= start_mul;
				when others =>
					next_state <= state_reg;
				end case;
			when start_mul =>
				next_state <= mul;
			when mul =>
				case (all_finished)	is
				when '1' =>
					next_state <= finish_mul;
				when others =>
					next_state <= state_reg;
				end case;
			when finish_mul =>
				if (cnt = 0) then
					next_state <= finish_mul;
					cnt <= 1;
				else
				next_state <= idle_mul;
				cnt <= 0;
				end if;
			end case;
		end if;
	end process;
	
	--! Sumation of the exponents
	sum_exp : Fixed_Adder generic map (number_of_bits-mantissa_bits-1) port map(Clk, Reset, A(number_of_bits-2 downto mantissa_bits), B(number_of_bits-2 downto mantissa_bits), Start, exp_sum_out, exp_add_fin);
	--! Substraction to compensate the offset
	sub_exp_off : Fixed_Adder generic map (number_of_bits-mantissa_bits) port map(Clk, Reset, exp_sum_out, offset, exp_add_fin, internal_exp, off_sub_fin);
	
	--! Multiplication of the mantissas
	mul_man : Fixed_Mul generic map (mantissa_bits) port map(Clk, Reset, A(mantissa_bits-1 downto 0), B(mantissa_bits-1 downto 0), Start, internal_man, fixed_mul_fin);
	
	--! Sign of the output
	internal_sign <= A(A'left) xor B(B'left);

	--! Operation finished checker
	finish_gen : process(exp_add_fin, off_sub_fin, fixed_mul_fin, state_reg) is
	begin
		case (state_reg) is
		when mul =>
			if (rising_edge(fixed_mul_fin)) then
				all_finished <= '1';
			end if;
		when others =>
			all_finished <= '0';
		end case;
	end process;
	
	--! Final mantissa and exponent decision and output forming.
	output_forming : process(internal_exp, internal_man, internal_sign, state_reg, final_exp, final_man, man_case_var) is
	begin 
		
		man_case_var <= internal_man(internal_man'left-2 downto internal_man'left-3); --Ovde mozda greska u man
		case (man_case_var) is
		when "00" =>
			final_exp <= std_logic_vector(unsigned(internal_exp) + 2);
			final_man <= internal_man(internal_man'left-2 downto internal_man'left-mantissa_bits-1);
		when "01" =>
			final_man <= internal_man(internal_man'left-4 downto internal_man'left-mantissa_bits-3);
			final_exp <= internal_exp;
		when "10" =>
			final_exp <= std_logic_vector(unsigned(internal_exp) + 1);
			final_man <= internal_man(internal_man'left-3 downto internal_man'left-mantissa_bits-2);
		when "11" =>
			final_exp <= std_logic_vector(unsigned(internal_exp) + 1);
			final_man <= internal_man(internal_man'left-3 downto internal_man'left-mantissa_bits-2);
		when others =>
			final_exp <= (number_of_bits-mantissa_bits downto 0 => '0');
			final_man <= (mantissa_bits-1 downto 0 => '0');
		end case;
		case(state_reg) is
		when finish_mul =>
			out_buffer <= internal_sign & final_exp(final_exp'left-2 downto 0) & final_man;
		when others =>
			null;
		end case;
	end process;
	
end architecture Float_Mul_arch;