--! @file fp_adder.vhd
--! @brief Floating point single precision adder
--! @details This file describes floating point adder which operates with 32-bit
--! operands. It has the floating point adder's entity interface description and
--! and one behavioral architecture description. \n
--! \n
--! @author Natalija Colic 90/2013 \n
--! @date 15/3/2017
--! @version 1.0
--!
--! <b>References:</b> \n
--! [1] <i>Tradeoff of FPGA Design of a Floating-point Library for Arithmetic 
--! operators</i>, D. Munos, D. Sanchez, C. Llanos, M. Ayala-Rincon



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--! @brief Entity declaration for fp_adder
--! @details
--! fp_adder is a sequential component that adds two 32-bit numbers and gives 32-bit
--! result. It uses signal <b>ready</b> to start the addition and input clock 
--! <b>clk</b> to define when state transitions happen. When <b>result</b> is calculated
--! signal <b>valid_out</b> is used to notify that addition is over and result can be used
--! The interface description is shown in Fig. 1
--! @image html fp_adder_block.png "Fig. 1. fp_adder block"

entity fp_adder is
port
	(
		-- Input ports
		
		--! Operands
		A         : in std_logic_vector (31 downto 0); 
		B         : in std_logic_vector (31 downto 0);
		
		--! clk signal
		clk       : in std_logic;
		--! Sequential circuit reset signal
		reset     : in std_logic;
		--! Signal used to start addition
		ready     : in std_logic;
		
      --Output ports

      --! Signal that indicates that addition is done		
		valid_out : out std_logic;
		--! Addition result
		result    : out std_logic_vector (31 downto 0)
	);
end fp_adder;


--! @brief Behavioral architecture for fp_adder
--! @details
--! fp_adder is realized as a state machine shown in Fig. 2
--! @image html fp_adder_FSM.png "Fig. 2. fp_adder FSM"
--! Input clock <b>clk</b> is used for state_transition. 
--! Initial state of the state machine is <b>IDLE</b>, in which the initialization is implemented.
--! If signal<b>ready</b> is active, the state machine goes to <b>ALIGN</b> state, otherwise it stays
--! in <b>IDLE</b>. In <b>ALIGN</b> state exponents of opernads are being compared and if they are the
--! same the state machine goes to <b>ADD</b> state. If they're not the same, the difference between exponents
--! is determined and the mantissa of the number with smaller exponent is being shifted right for number of
--! bits determined by difference and state machine goes to <b>ADD</b> state. If difference is larger than 23 bits 
--! it means that the smaller number is insignificant relative to the larger number (mantissa will be shifted right 23 times), which
--! means that the sum is determined by the larger number, in which case the state machine goes to <b>PAUSE</b> state. 
--! In <b>ADD</b> state based on the sign of the numbers and mantissas sign and mantissa of the final result are determined. 
--! State machine goes to <b>NORM</b> state.
--! In <b>NORM</b> state normalization is done on the final result's mantissa. In case that is already normalized next state is <b>PAUSE</b> state.
--! Otherwise first bit that is 1 in mantissa is found and mantissa is shifted left so that 1 becomes MSB of the mantissa and the exponent is decreased by
--! the number of positions that mantissa has been shifted left. Next state is <b>PAUSE</b> state.
--! In <b>PAUSE</b> state final sum is being made and state machine goes to <b>FIN</b> state.
--! In <b>FIN</b> state output is defined and its signalized that output is valid by setting signal <b>valid_out</b>.
--! FSM goes back to <b>IDLE</b>.

architecture fp_adder_behavioral of fp_adder is

--! Definition of states of fp_adder state machine. See detailed description for more details.
type state_type is ( IDLE, ALIGN, ADD, NORM, PAUSE, FIN ); 
signal next_state : state_type;

-- Definitions of signals used in the implementation of fp_adder

signal A_mantissa, B_mantissa   : std_logic_vector (24 downto 0) := "0000000000000000000000000"; --input numbers mantissas
signal A_exp, B_exp             : std_logic_vector (8 downto 0)  := "000000000" ;                --input numbers exponents, A_exp is also used for storing exponent of final sum
signal A_sgn, B_sgn             : std_logic := '0';                                              --input numbers signs

signal sum                      : std_logic_vector (31 downto 0) :="00000000000000000000000000000000"; --sum built in FSM

signal mantissa_sum             : std_logic_vector (24 downto 0) := "0000000000000000000000000"; --mantissa of the sum

signal mantissa_sum1            : std_logic_vector (24 downto 0) := "0000000000000000000000000"; 
signal A_mantissa1, B_mantissa1 : std_logic_vector (24 downto 0) := "0000000000000000000000000";
begin

--! State transition process.\n
--! When reset is asserted, the state machine is in the <b>IDLE</b> state.

--! Next state process. This process defines when the state machine changes states.
--! When ready is set to 1 machine starts the state sequence
--! <b>IDLE - ALIGN - ADD - NORM - PAUSE - FIN - IDLE</b> \n
--! when differnce between exponents is smaller than 23, or
--! <b>IDLE - ALIGN - PAUSE - FIN - IDLE</b> \n
--! when it's not.

next_state_process : process (ready, clk, reset) is
variable diff : signed(8 downto 0);

begin
  if (reset = '1') then
	next_state <= IDLE;

	
	elsif(rising_edge(clk)) then
	case next_state is
					
					when IDLE =>
						if (ready = '1') then
							A_sgn       <= A(31);    
							B_sgn       <= B(31);
							A_exp       <= '0' & A(30 downto 23);
							B_exp       <= '0' & B(30 downto 23);
							A_mantissa  <= "01" & A(22 downto 0);
						   B_mantissa  <= "01" & B(22 downto 0);
						   A_mantissa1 <= "01" & A(22 downto 0);
						   B_mantissa1 <= "01" & B(22 downto 0);
						   next_state  <= ALIGN; -- if ready set FSM goes to ALIGN
						
						else 
						   A_sgn       <= '0';    
							B_sgn       <= '0';
							A_exp       <= "000000000";
							B_exp       <= "000000000";
							A_mantissa  <= "0000000000000000000000000";
						   B_mantissa  <= "0000000000000000000000000";
						   A_mantissa1 <= "0000000000000000000000000";
						   B_mantissa1 <= "0000000000000000000000000";
							next_state  <= IDLE;  -- if ready not set FSM stays in IDLE
						
						end if;
							
							mantissa_sum <= "0000000000000000000000000";
							valid_out    <= '0';    -- result is not ready
					      sum          <= "00000000000000000000000000000000";
					
					
					when ALIGN =>
						if (unsigned(A_exp) = unsigned(B_exp)) then
							next_state <= ADD; --if exponents are the same FSM goes to ADD
						
						elsif (unsigned(A_exp) > unsigned(B_exp)) then
							diff:= signed(A_exp) - signed(B_exp); -- determining the difference between exponents 
							
							if (diff>23) then
								mantissa_sum1 <= A_mantissa; --if difference is greater than 23 smaller operand is insignificant
								sum(31)      <= A_sgn;     
						   
								next_state   <= PAUSE;      -- FSM goes to PAUSE, greater number represents the sum
						   
							else 
								B_mantissa1(24-to_integer(diff) downto 0)  <= B_mantissa(24 downto to_integer(diff));  --smaller operand is shifted right 
								B_mantissa1(24 downto 25-to_integer(diff)) <= (others => '0'); --remaining bits on the left are filled with 0
								
								next_state                                 <= ADD;             --FSM goes to ADD
							
							end if;
						
						else
							diff:= signed(B_exp) - signed(A_exp); -- determining the difference between exponents
							
							if (diff>23) then
								mantissa_sum1 <= B_mantissa; --if difference is greater than 23 smaller operand is insignificant
								sum(31)      <= B_sgn;
								A_exp        <= B_exp;      --exponent of final sum is in A_exp    
								
								next_state   <= PAUSE;      -- FSM goes to PAUSE 
							
							else
								A_exp                                      <= B_exp; --exponent of final sum is in A_exp
								A_mantissa1(24-to_integer(diff) downto 0)  <= A_mantissa(24 downto to_integer(diff)); --smaller operand is shifted right 
								A_mantissa1(24 downto 25-to_integer(diff)) <= (others => '0');  --remaining bits on the left are filled with 0
								
								next_state                                <= ADD; --FSM goes to ADD
						
							end if;
						
						end if;
						
					when ADD =>
						if ((A_sgn xor B_sgn) = '0') then -- if A and B have the same sign their mantissas can be added
							mantissa_sum <= std_logic_vector((unsigned(A_mantissa1) + unsigned(B_mantissa1)));
							sum(31)      <= A_sgn; --sign of final sum is the same as the operands
							mantissa_sum1<= std_logic_vector((unsigned(A_mantissa1) + unsigned(B_mantissa1)));
							
						elsif (unsigned(A_mantissa1) >= unsigned(B_mantissa1)) then
							mantissa_sum <= std_logic_vector((unsigned(A_mantissa1) - unsigned(B_mantissa1))); --final sum mantissa
							sum(31)      <= A_sgn; --sign of final sum determined by greater number
						   mantissa_sum1<= std_logic_vector((unsigned(A_mantissa1) - unsigned(B_mantissa1)));	
						
						else
							mantissa_sum <= std_logic_vector((unsigned(B_mantissa1) - unsigned(A_mantissa1))); --final sum mantissa
							sum(31)      <= B_sgn; --sign of final sum determined by greater number
						   mantissa_sum1<= std_logic_vector((unsigned(B_mantissa1) - unsigned(A_mantissa1)));
						end if;
						 
						next_state <= NORM; --FSM goes to NORM
						
					when NORM =>
						if (unsigned(mantissa_sum) = to_unsigned(0, 25)) then
							mantissa_sum1 <= (others => '0'); --if mantissa of the final sum is 0 then the sum is 0
							A_exp        <= (others => '0'); -- setting exponent of the final sum to 0
							
							next_state   <= PAUSE;           --FSM goes to PAUSE
						
						elsif (mantissa_sum(24)	 = '1') then 
							mantissa_sum1 <= '0' & mantissa_sum(24 downto 1); -- mantissa should be shifted 1 bit to the right
							A_exp        <= std_logic_vector((unsigned(A_exp)+1)); --exponent should be increased by 1
							
							next_state <= PAUSE; --FSM goes to PAUSE
						
						elsif (mantissa_sum(23) = '0') then --if mantissa_sum(23)='1' is already normalized
							for i in 22 downto 1 loop
								if (mantissa_sum(i) = '1') then -- finding first 1 in mantissa looking left to right
									mantissa_sum1(24 downto (23- i)) <= mantissa_sum((i+1) downto 0); --shifting mantissa left
									mantissa_sum1((22 - i) downto 0) <= (others => '0'); --filling remaining bits on the right with 0
									A_exp                           <= std_logic_vector(unsigned(A_exp)-23+i); --adjusting exponent
									exit;
								
								end if;
							end loop;
							
							next_state <= PAUSE; --FSM goes to PAUSE
						
						else
							next_state <= PAUSE; --is already normalized, FSM goes to PAUSE
							
						end if;
					
					when PAUSE =>  
						sum(22 downto 0)  <= mantissa_sum1(22 downto 0); -- final sum mantissa
						sum(30 downto 23) <= A_exp(7 downto 0);          -- final sum exponent
						valid_out         <= '0';			 -- result is still not ready
						next_state <= FIN;                               -- FSM goes to FIN
						
					when FIN =>
					        valid_out <= '1';                                -- result ready
					   	result <= sum;					 -- output
					   	next_state <= IDLE;                              -- FSM goes to IDLE
					
					when others =>
						next_state <= IDLE; -- if in any other state FSM goes to IDLE (just to be sure)
			
			end case;
 end if;			
end process next_state_process;
 

end fp_adder_behavioral;
 						
						

						

							
						
								
							
						

