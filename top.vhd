--! @file top.vhd
--! @brief top level entity for logarithm approximation unit
--! @details This file combines UART_RX, LAU and UART_TX modules in order
--!  to form a system which controls communication and processes with LAU\n
--! @author Natalija Colic 90/2013 \n
--! @author Stefan Vukcevic 509/2013 \n
--! @date 28/6/2017
--! @version 1.0
--!
--! <b>References:</b> \n
--! [1] <i>Efficient floating-point logarithm unit for FPGA-s</i>, 
--! Nikolaos Alachiotis, Alexandros Stamatakis
library IEEE;
library work;
use IEEE.std_logic_1164.all;
use work.Q_val.all;

entity top is
generic
	(
           --Precision for mantissa
	   precision: integer := Q
	);
port 
	(
                --Input ports
                
                --! clk signal
		clk : in std_logic;
		--! Reset signal
                reset :in std_logic;
		
               --! Data received via UART
	       data_in	: in std_logic;
	       
               --Output ports
               
               --! Result sent via UART
	       data_out : out std_logic
		
	);

end top;
--! @brief Structural architecture for top
--! @details
--! top is combination of UART_RX, LAU and UART_TX modules in order
--!  to form a system which controls communication and processes with LAU
architecture top_structural of top is
component UART_RX is
  generic (
	 -- Generic
	 
	 --!  Number of clocks to transmit a bit (g_CLKS_PER_BIT = (Frequency of i_Clk)/(Frequency of UART))
    g_CLKS_PER_BIT : integer := 435     -- Needs to be set correctly
    
	 );
  port (
    --Input  ports
	 
	 --! clk signal
	 i_Clk       : in  std_logic;
	 --! Receiving data
    i_RX_Serial : in  std_logic;
    
	 --! Receiving complete signal
	 o_RX_DV     : out std_logic;
	 --! Data received
    o_RX_Data   : out std_logic_vector(31 downto 0)
    );
end component;

component LAU is
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
		
                --Output ports

		--! Result ready
                output_valid : out std_logic;
		--! Result
                output_number: out std_logic_vector(31 downto 0)
		
		);
end component;

component UART_TX is
  generic 
  
  (
    -- Generic
	 
	 --!  Number of clocks to transmit a bit (g_CLKS_PER_BIT = (Frequency of i_Clk)/(Frequency of UART))
    g_CLKS_PER_BIT : integer := 435     -- Needs to be set correctly
    
	 );
  port (
    
	 --Input  ports
	 
	 --! clk signal
    i_Clk       : in  std_logic;
	 --! Signal to start transmission
    i_TX_DV     : in  std_logic;
	 --! Data to be sent
    i_TX_Data   : in  std_logic_vector(31 downto 0);
    
	 --Output ports
	 
	 --! Transmission active
	 o_TX_Active : out std_logic;
    --! Transmited bits
	 o_TX_Serial : out std_logic;
	 --! Transmission done signal
    o_TX_Done   : out std_logic
    );
end component;	

signal data_received : std_logic; --data_received
signal number_in: std_logic_vector (31 downto 0); -- received number
signal number_out: std_logic_vector (31 downto 0); -- LAU output
signal valid : std_logic; -- LAU output valid
signal valid_del : std_logic;	-- LAU output valid delayed
signal transmit: std_logic := '0'; -- trigger for UART_TX
signal trans_active: std_logic; -- transmition in progress 
signal trans_done :std_logic := '0'; --transmition done
signal reset_n : std_logic; -- not reset

begin

-- Input reset active 0, reset_n active 1 
reset_n <= not reset;

RX: UART_RX port map (i_Clk => clk, i_RX_Serial => data_in, o_RX_DV =>	data_received, o_RX_Data => number_in);

L: LAU generic map (q=> precision) port map ( clk => clk, reset => reset_n, input_valid => data_received, input_number => number_in,
						output_valid => valid , output_number => number_out);
TX: UART_TX port map (i_Clk => clk, i_TX_DV => transmit, i_TX_Data => number_out,  o_TX_Active => trans_active,
							 o_TX_Serial => data_out, o_TX_Done => trans_done);

-- Generating a trigger for transmition start by delaying signal that data is valid from LAU, when transmition is done,
-- transmit signal is inactive
transmission: process (valid, trans_done, clk)
				  begin
				  if (rising_edge(clk)) then
					if (valid_del = '1') then
					 transmit <= '1';
				  
				  elsif ( trans_done = '1') then
				  transmit <= '0';
				  end if;
				  end if;
				  end process;
-- Delaying signal from LAU						
trans: process(clk, valid)
		 begin
		 if (falling_edge(clk)) then
			if (valid = '1') then
				valid_del <= '1';
			else
				valid_del <= '0';
			end if;
		 end if;
		 end process;
--! @mainpage LAU project documentation
--! @section introduction Component overview
--! This component is a combination of the modules UART_RX, LAU and UART_TX a system 
--! which completely controls the communication and processes with LAU. The interface 
--! description is shown in Fig. 1
--! @image html top_block.png "Fig. 1. A block schematic of the top entity component"
--! @section protocol Protocol description
--! The UART protocol is shown in Fig. 2
--! @image html UART.png "Fig. 2. UART" 
--! The timing diagram of LAU is shown in Fig. 3 
--! @image html LAU_timing.png "Fig. 3. LAU timing diagram" 
--! @image html LAU_timing1.png "Fig. 4. LAU timing diagram" 
--! @section thisdocs About this documentation
--! This project is done for the need of the Technical documentation course at the Department of Electronics,
--! School of Electrical Engineering. 
--! Anyone can use these documents for non-commercial use without any restrictions.
					
			
end top_structural;				  
				  