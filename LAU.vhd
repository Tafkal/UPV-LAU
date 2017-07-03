--! @file LAU.vhd
--! @brief Logarithm approximation unit
--! @details This file describes calculation of 32-bit float point number 
--! It has the LAU's entity interface description and
--! and one structural architecture description. \n
--! \n
--! @author Natalija Colic 90/2013 \n
--! @date 1/4/2017
--! @version 1.0
--!
--! <b>References:</b> \n
--! [1] <i>Efficient floating-point logarithm unit for FPGA-s</i>, 
--! Nikolaos Alachiotis, Alexandros Stamatakis

library IEEE;
library work;
use IEEE.std_logic_1164.all;
use work.Q_val.all;

--! @brief Entity declaration for LAU
--! @details
--! LAU based on 32 bit float point input number and given precision calculates approximated logarithm 
--! The interface description is shown in Fig. 1
--! @image html LAU_block.png "Fig. 1. LAU block"

entity LAU is
generic
	(
      --! Precision
      q: integer := Q
	);
port
	(
                --Input ports

                --! clk signal
		clk       : in std_logic;
		--! Sequential circuit reset signal
                reset     : in std_logic;
		
		--! Input number is ready 
                input_valid : in std_logic;
		--! Input single precision floating point number
                input_number: in std_logic_vector(31 downto 0);
		
		--! Result ready
                output_valid : out std_logic;
		--! Result
                output_number: out std_logic_vector(31 downto 0)
		
		);
end LAU;

--! @brief Structural architecture for LAU
--! @details
--! Input clock <b>clk</b> is used for sequential logic. 
--! Calculation of <b>input_number</b> logarithm starts with taking its exponent and using exp_fp_gen
--! block to generate floating point value. Signal <b>input_valid</b> is delayed using counter and it is
--! used to start Float_mul. Float_mul multiplies float point represenation of exponent  
--! and logx(2), x being the base, which is also float point. fp_adder starts when multiplication is done
--! and adds multiplication result and output number of Man_ROM which is the approximated logarithm. 
--! If <b>input_number</b> is inf, negative number or zero, spec_case block provides the correct result 
--! and the calculation mentioned above is ignored.
architecture LAU_structural of LAU is

component reg_32b is
port
	(
                --Input ports
                
                --! Input value 
		input_num   : in std_logic_vector (31 downto 0);
		
		--! clk signal
                clk         : in std_logic;
		--! Sequential circuit reset signal
                reset       : in std_logic;
		
                --! Input value is valid and needs to be stored
                input_valid : in std_logic;
		
                --! Stored value
		output_num  : out std_logic_vector (31 downto 0)
	);
end component;


component exp_fp_gen is
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
end component;

component log_base_ROM is
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (0 DOWNTO 0):= "0";
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;


component Float_Mul is
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
end component;

component Man_ROM is
	GENERIC
	(
		address_bits : integer
	);
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (address_bits-1 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

component fp_adder is
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
end component;

component spec_case is
	generic(
                --! Bit width of the inputs
		number_of_bits 	: integer := 32;
		--! Mantissa bits in the data
                mantissa_bits 		: integer := 23
	);
	
	
	port(
		--! Input signal vector
                A : in std_logic_vector(number_of_bits-1 downto 0);
		
                --! Output signal vector
		Y : out std_logic_vector(number_of_bits-1 downto 0);
		--! Output select signal to be used on a MUX
                S : out std_logic
	);
	
end component;

signal reg_out: std_logic_vector(31 downto 0); --output register out
signal fp_exp : std_logic_vector (31 downto 0); -- exp_fp_gen out
signal base_out: std_logic_vector(31 downto 0); -- LUT log2 out
signal mul_start: std_logic := '0' ; --multipler start
signal cnt : integer range 0 to 10 := 0; -- counter value
signal mul_out: std_logic_vector(31 downto 0); -- multiplier output value 
signal mul_done: std_logic; -- multiplier done
signal man_out: std_logic_vector(31 downto 0); -- LUT mantissa out
signal add_out: std_logic_vector(31 downto 0); -- float point adder out
signal add_done: std_logic; -- float point adder done
signal spec_out : std_logic_vector(31 downto 0); -- special case detector out
signal spec : std_logic; -- special case detected
signal output_number_temp: std_logic_vector(31 downto 0); -- input number for output register
signal cir: std_logic; -- signal to write to output register
signal add_en: std_logic:= '0'; -- ready signal for float point adder


begin
--instantiating output 32 bit register
reg: reg_32b port map (input_num => output_number_temp, clk => clk, reset => reset, input_valid => cir, output_num => reg_out);

cir <= add_done or spec; -- when addition is done or special case detected writing to output register

--instatiating exp_fp_gen 
exp_gen: exp_fp_gen port map (exp_value => input_number(30 downto 23), clk => clk, reset => reset, exp_fp_out => fp_exp);

--instatiating ROM which contains float point value of logx(2)
rom : log_base_ROM port map (address => open, clock => clk, q => base_out);

-- Sequential logic
-- Counter process, when reaches maximum it stays there until reset or another number is calculated 
cnt_proc: process (reset, clk, input_valid) 
	  begin
		if ((reset = '1') or (input_valid = '1')) then
			cnt <= 0;
		elsif (rising_edge(clk)) then
	      if (cnt = 10) then
			 cnt <= 10;
			else
				cnt <= cnt +1;
				end if;
			end if;
end process;

--Sequential logic
--When counter counts to 5 multiplier is started and its <b>Start</b> signal is active for 1 clk period
mul_proc: process(cnt, mul_done)
			 begin
			  if (cnt = 5) then
				mul_start <= '1';
			  
			  elsif (mul_done = '1') then
			    mul_start <= '0';
			  end if;
			  end process;
			
--instatiating float point multiplier
mul: Float_Mul port map (Clk => clk, Reset => reset, A => fp_exp, B=> base_out, Start => mul_start,
								Y => mul_out, Finish => mul_done);
--instatiating LUT for mantissa
man: Man_ROM generic map (address_bits => q) port map (address => input_number(22 downto 23-q), clock => clk, q => man_out);		

--Generating start signal for adder, when multiplier is done adder is started, and when adder is done adder is disabled
delay: process (mul_done, add_done)
       begin
			if (mul_done = '1') then
			 add_en <= '1';
			 
		   elsif (add_done = '1') then
				add_en <= '0';
			
		 end if;
		end process;
				
--instatiating adder
add: fp_adder port map (A => mul_out, B => man_out, clk => clk, reset => reset, ready => add_en, 
								valid_out => add_done , result => add_out);
--instatiating special case detection block
special: spec_case port map (A => input_number, Y => spec_out, S => spec);

--If special case detected value from spec_case is written to output register, otherwise value from fp_adder is
out_proc: process(spec, spec_out, add_out, add_done)
			 begin
			 if (spec = '1') then
				output_number_temp <= spec_out;
				output_valid <= add_done;
			 else
				output_number_temp <= add_out;
				output_valid <= add_done;
			 end if;
			 end process;
 
					 
output_number <= reg_out; -- LAU output
end LAU_structural;






	


