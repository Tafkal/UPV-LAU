--! @file Fixed_Mul.vhd
--! @brief Fixed point float mantissa multiplication.
--! @details This is a implementation of the fixed point multiplication algorithm implemented
--! especialy for the floating point multiplication process, it deals with multiplying mantissas.\n
--! \n 
--! @author Stefan Vukcevic
--! @date 25/06/2017
--! @version 1.2
--! \n
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Entity declaration for Fixed_Mul
--! @details 
--! The number_of_bits generic is for setting the input data width.\n
--! First set up the A and B signals to your liking. Then set Start active.
--! When Start is active while on the falling edge of the clock signal the
--! multiplication will start. When the process is finished the Finish signal
--! will notify you that the result is in the output register. \n
--! N.B.: The output is significantly larger in width!\n\n
--! @image html Fixed_mul_block.png "Fig. 1. A block symbol of the Fixed_mul component"
--! @image html Fixed_mul_FSM.png "Fig. 2. FSM of the Fixed_mul component"
entity Fixed_Mul is
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
	
end entity Fixed_Mul;

--! @brief Architecture for Fixed_Mul
--! @details 
--! The architecture to do the things described in the entity declaration
--! of the Fixed_Mul. \n\n
architecture Fixed_Mul_arch of Fixed_Mul is

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
type state_type_t is (idle_mul, start_mul, mul, finish_mul);
--! Current and next state signals.
signal state_reg, next_state 	: state_type_t := idle_mul;

--! Signal for the end of the multiplication
signal end_of_mul							: std_logic := '0';
--! Signal to enable the counter in the process
signal counter_enable					: std_logic := '0';
--! Counting signal
signal counter_var						: integer range 0 to number_of_bits+2;
--! Intermediate output buffer
signal out_buffer							: std_logic_vector(2*number_of_bits+1 downto 0);
--! B signal serial ouput
signal serial_B							: std_logic := '0';
--! B load signal, the main load signal and the main shift signal
signal load_B, load_main, shift_all : std_logic := '0';
--! Input of the multiplication recursion signal
signal add_A								: std_logic_vector(2*number_of_bits downto 0);
--! Output of the multiplication recursion signal
signal adder_out							: std_logic_vector(2*number_of_bits+1 downto 0) := (others => '0');
--! Modified B input.
signal internal_B							: std_logic_vector(number_of_bits downto 0);
begin
	
	--! Add the hidden '1' to B.
	internal_B <= '1' & B;

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
				load_B <= '0';
				shift_all <= '0';
				counter_enable <= '0';
				Finish <= '0';
			when start_mul =>
				load_B <= '1';
				counter_enable <= '1';
			when mul =>
				load_B <= '0';
				shift_all <= '1';
			when finish_mul =>
				load_B <= '0';
				shift_all <= '0';
				counter_enable <= '0';
				Finish <= '1';
				Y <= out_buffer;
			end case;
		end if;
	end process;

	--! Next state decision making process.
	next_fsm_state : process(Clk, next_state, end_of_mul, Start) is
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
				case (end_of_mul) is
				when '1' =>
					next_state <= finish_mul;
				when others =>
					next_state <= state_reg;
				end case;
			when finish_mul =>
				next_state <= idle_mul;
			end case;
		end if;
	end process;
	
	--! Counter process needed for controlling the recursion of the algorithm.
	counter_proc : process(Clk, Reset, counter_var, counter_enable) is
	begin
		if (falling_edge(Clk)) then
			case (counter_enable) is
			when '1' =>
				if (end_of_mul = '0') then
					counter_var <= counter_var + 1;
				end if;
			when others =>
				counter_var <= 0;
			end case;
			if(counter_var >= number_of_bits+1) then
				end_of_mul <= '1';
			else
				end_of_mul <= '0';
			end if;
		end if;
	end process;
	
	--! Shift register component instance for manipulating the result
	Shift_main 		: Shift_Reg generic map(2*number_of_bits+2) port map(Clk, Reset, adder_out, '0', shift_all, load_main, out_buffer, open);
	--! Shift register component instance for manipulating the multiplication recursion operation.
	Shift_mux_sel 	: Shift_Reg generic map(number_of_bits+1) port map(Clk, Reset, internal_B, '0', shift_all, load_B, open, serial_B);

	--! Forming the full A signal from the mantissa.
	add_A_form : process(Clk, Reset, load_B) is
	begin
		if (Reset = '1') then
			add_A <= (others =>'0');
		elsif (rising_edge(Clk)) then
			if (load_B = '1') then
				add_A <= '1' & A & ((add_A'length - A'length - 2) downto 0 => '0');
			end if;
		end if;
	end process;
	
	--! The multiplication recursion process, most of the work is done here. 
	mul_proc : process(Clk, state_reg) is
	begin
		if (falling_edge(Clk)) then
			case (state_reg) is
			when mul =>
				case (serial_B) is
				when '1' =>
					load_main <= '1';
					adder_out <= std_logic_vector(unsigned(out_buffer) + unsigned(add_A));
				when others =>
					load_main <= '0';
				end case;
			when others =>
				adder_out <= (others => '0');
				load_main <= '0';
			end case;
		end if;
	end process;
	
end architecture Fixed_Mul_arch;
