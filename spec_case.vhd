library ieee;
use ieee.std_logic_1164.all;

entity spec_case is
	generic(
		number_of_bits 	: integer := 32;
		mantissa_bits 		: integer := 23
	);
	
	
	port(
		A : in std_logic_vector(number_of_bits-1 downto 0);
		
		Y : out std_logic_vector(number_of_bits-1 downto 0);
		S : out std_logic
	);
	
end entity spec_case;

architecture spec_case_arch of spec_case is

begin
		
	SC_PROC : process (A)
	begin
	
		if (A(number_of_bits-1) = '1') then
			S <= '1';
			Y <= '0' & (number_of_bits-2 downto 0 => '1');
		elsif (A(number_of_bits-2 downto mantissa_bits) = (number_of_bits-2-mantissa_bits downto 0 => '1')) then 
			S <= '1';
			Y <= A;
		elsif (A(number_of_bits-2 downto mantissa_bits) = (number_of_bits-2-mantissa_bits downto 0 => '0')) then
			S <= '1';
			Y <= '0' & (number_of_bits-2 downto 0 => '1');
		else
			S <= '0';
			Y <= (number_of_bits-1 downto 0 => '0');
		end if;
		
	end process;
	
end architecture spec_case_arch;