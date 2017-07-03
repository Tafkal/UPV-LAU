--! @file Fixed_adder.vhd
--! @brief A fixed point adder implementation.
--! @details This is a implementation of the fixed point addition algorithm.\n
--! The goal was to make it as small as possible, so it is made using one full adder
--! and 3 shift registers.\n
--! \n 
--! @author Stefan Vukcevic
--! @date 25/06/2017
--! @version 1.1
--! \n 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Entity declaration for Fixed_Adder
--! @details 
--! The number_of_bits generic is for setting the input data width.\n
--! First set up the A and B signals to your liking. Then set Start active.
--! When Start is active while on the falling edge of the clock signal the
--! addition will start. When the process is finished the Finish signal
--! will notify you that the result is in the output register. \n
--! N.B.: The output is one bit larger in width!\n\n
--! @image html Fixed_add_block.png "Fig. 1. A block symbol of the Fixed_Adder component"
--! @image html Fixed_add_FSM.png "Fig. 2. FSM of the Fixed_Adder component"
entity Fixed_Adder is
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
	
end entity Fixed_Adder;

--! @brief Architecture for Fixed_Adder
--! @details 
--! The architecture to do the things described in the entity declaration
--! of the Fixed_Adder. \n\n
architecture Fixed_Adder_arch of Fixed_Adder is

--! Shift register
component Shift_Reg is
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
	
end component Shift_Reg;

--! Definition of the states in the FSM.
type state_type_t is (idle_add, start_add, add, finish_add);
--! Current and next state signals.
signal state_reg, next_state 	: state_type_t := idle_add;
--! Signal to enable the counting process
signal counter_enable			: std_logic := '0';
--! The counting signal
signal counter_var				: integer range 0 to number_of_bits+1;
--! Signal for the end of range for the counter
signal end_of_count				: std_logic := '0';
--! Output buffer
signal out_buffer					: std_logic_vector(number_of_bits downto 0);
--! Shift and Load control signals for the shift registers
signal shift_all, load_all		: std_logic := '0';
--! Serial outputs of the shift registers
signal serial_A, serial_B		: std_logic := '0';
--! Serial input for the result shift register
signal serial_Y					: std_logic;
--! Carry input and output signals
signal carry_in, carry_out		: std_logic := '0';
--! Output reset vector
signal reset_Y						: std_logic_vector(number_of_bits downto 0) := (number_of_bits downto 0 => '0');
begin

	--! Process that moves the FSM forward.
	fsm_reg : process(Clk, Reset, Start) is
	begin
		case (Reset) is
		when '1' =>
			state_reg <= idle_add;
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
			when idle_add =>
				counter_enable <= '0';
				load_all <= '0';
				shift_all <= '0';
				Finish <= '0';
			when start_add =>
				counter_enable <= '1'; --here or in add?
				load_all <= '1';
				shift_all <= '0';
				Finish <= '0';
			when add =>
				load_all <= '0';
				shift_all <= '1';
				Finish <= '0';
			when finish_add =>
				counter_enable <= '0';
				load_all <= '0';
				shift_all <= '0';
				Finish <= '1';
				Y <= out_buffer;
			end case;
		end if;
	end process;
	
	--! Next state decision making process.
	next_fsm_state : process(Clk, next_state, end_of_count, Start) is
	begin
		if(falling_edge(Clk)) then
			case(state_reg) is
			when idle_add =>
				case (Start) is
				when '1' =>
					next_state <= start_add;
				when others =>
					next_state <= state_reg;
				end case;
			when start_add =>
				next_state <= add;
			when add =>
				case (end_of_count) is
				when '1' =>
					next_state <= finish_add;
				when others =>
					next_state <= state_reg;
				end case;
			when finish_add =>
				next_state <= idle_add;
			end case;
		end if;
	end process;
	
	--! Counter process needed for controlling the recursion of the algorithm.
	counter_proc : process(Clk, Reset, counter_var, counter_enable) is
	begin
		if (falling_edge(Clk)) then
			case (counter_enable) is
			when '1' =>
				if (end_of_count = '0') then
					counter_var <= counter_var + 1;
				end if;
			when others =>
				counter_var <= 0;
			end case;
			if(counter_var >= number_of_bits) then
				end_of_count <= '1';
			else
				end_of_count <= '0';
			end if;
		end if;
	end process;
	
	--! Shift register component instance for feeding the A bits in the FA.
	Shift_A : Shift_Reg generic map(number_of_bits) port map(Clk, Reset, A, '0', shift_all, load_all, open, serial_A);
	--! Shift register component instance for feeding the B bits in the FA.
	Shift_B : Shift_Reg generic map(number_of_bits) port map(Clk, Reset, B, '0', shift_all, load_all, open, serial_B);
	--! Shift register component instance for storing the FA result.
	Shift_Y : Shift_Reg generic map(number_of_bits+1) port map(Clk, Reset, reset_Y, serial_Y, shift_all, load_all, out_buffer, open);
	
	--! The adding process.
	adding_proc : process(Clk, state_reg, serial_A, serial_B, carry_in) is
	begin
		serial_Y <= serial_A xor serial_B xor carry_in;
		carry_out <= ((serial_A and serial_B) or ((serial_A xor serial_B) and carry_in));
		if(rising_edge(Clk)) then
			case (state_reg) is
			when start_add =>
				carry_in <= '0';
			when others =>
				carry_in <= carry_out;
			end case;
		end if;
	end process;

end architecture Fixed_Adder_arch;
