--! @file UART_TX
--! @brief UART transmitter
--! @details This file describes UART transmission 
--! It has the UART_TX's entity interface description and
--! and one behavioral architecture description. \n
--! \n
--! @author Natalija Colic 90/2013 \n
--! @date 15/4/2017
--! @version 1.0
--!

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


--! @brief Entity declaration for UART_TX
--! @detals This transmitter is able to transmit 32 bits of serial data, by sending 4 bytes with one start bit,
--! one stop bit and no parity bit.
--! When transmit is complete <b>o_TX_Done<b/> will be  driven high for one clock cycle.
 
--! The interface description is shown in 
--! @ image html UART_TX_block.png "UART_TX block"
 
entity UART_TX is
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
end UART_TX;


--! @brief Behavioral architecture for UART_TX
--! @details
--! UART_TX is realized as a state machine shown  
--! @image html UART_TX_FSM.png "UART_TX FSM"
--! Input clock <b>clk</b> is used for state_transition. 
--! Initial state of the state machine is <b>s_Idle</b>, in which the initialization is implemented. Signal <b>o_TX_Serial<b/> is asserted because 
--! transmittion starts on transition og signal on that line high to low (start bit). 
--! If signal<b>i_TX_DV</b> is active, data <b>i_TX_Data</b>is parsed in 4 bytes, the state machine goes to <b>s_TX_Start_Bit</b> state, otherwise it stays
--! in <b>s_Idle</b>. In <b>s_TX_Start_Bit</b> state start bit is sent. Then state machine goes to <b>s_TX_Data_Bits</b>.
--! In this state machine sends one byte of the data. Then it goes to <b>s_TX_Stop_Bit</b> when it sends one stop bit.
--! After that machine goes to <b>s_Cleanup<b/> state where it checks if all bytes were sent and raises <b>o_TX_Done<b/> flag.
--! and after returns to <s_Idle> state.
 
architecture RTL of UART_TX is

	--! Definition of states of UART_TX state machine. See detailed description for more details.
   type t_SM_Main is (s_Idle, s_TX_Start_Bit, s_TX_Data_Bits,
                     s_TX_Stop_Bit, s_Cleanup);							
  signal r_SM_Main : t_SM_Main := s_Idle;
  
  -- Definitions of signals used in the implementation of UART_TX
  signal r_Clk_Count : integer range 0 to g_CLKS_PER_BIT-1 := 0; -- counter for clocks
  signal r_Bit_Index : integer range 0 to 7 := 0;  -- 8 Bits Total
  signal r_TX_Data   : std_logic_vector(7 downto 0) := (others => '0'); --1 byte of data to send
  signal r_TX_Done   : std_logic := '0'; --flag that indicates if transmission is done
  signal index : integer range 3 downto 0 := 3; --counter for bytes
  
begin
  --! State transition process.\n
  --! Next state process. This process defines when the state machine changes states.
  --! When <b>i_TX_DV<b/> is set to 1 machine starts the state sequence for every byte
  --! <b>s_Idle - s_TX_Start_Bit - s_TX_Data_Bits - s_TX_Stop_Bit - s_Cleanup - s_Idle</b> \n 
   
  p_UART_TX : process (i_Clk)
  begin
    if rising_edge(i_Clk) then
         
      case r_SM_Main is
 
        when s_Idle =>
          o_TX_Active <= '0';
          o_TX_Serial <= '1';         -- Drive line high for Idle
          r_TX_Done   <= '0';
          r_Clk_Count <= 0;
          r_Bit_Index <= 0;
          
			 
          if ((i_TX_DV = '1')) then
				case (index) is  -- based on index it is decided which bit is sent
            when 2 =>
				r_TX_Data <= i_TX_Data(31 downto 24); 
				when 1 =>
				r_TX_Data <= i_TX_Data(23 downto 16); 
				when 0 =>
				r_TX_Data <= i_TX_Data(15 downto 8); 
				when 3 =>
				r_TX_Data <= i_TX_Data(7 downto 0);
				when others =>
				r_TX_Data <= (others => '0');
				end case;
				
				r_SM_Main <= s_TX_Start_Bit; -- if i_TX_DV active set FSM goes to s_TX_Data_Bits
				
          else
            r_SM_Main <= s_Idle;-- if i_TX_DV not set FSM stays to s_Idle
          
			 end if;
 
           
        
        when s_TX_Start_Bit =>
          o_TX_Active <= '1'; -- transmission started
          o_TX_Serial <= '0'; -- Send out Start Bit. Start bit = 0
 
          -- Wait g_CLKS_PER_BIT-1 clock cycles for start bit to finish
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1; 
            r_SM_Main   <= s_TX_Start_Bit;
          
			 else
            r_Clk_Count <= 0;
            r_SM_Main   <= s_TX_Data_Bits; --when Start bit sent FSM goes to s_TX_Data_Bits 
          end if;
 
           
        -- Wait g_CLKS_PER_BIT-1 clock cycles for data bits to finish          
        when s_TX_Data_Bits =>
          o_TX_Serial <= r_TX_Data(r_Bit_Index);
           
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= s_TX_Data_Bits;
          
			 else
            r_Clk_Count <= 0;
             
            -- Check if we have sent out all bits
            if r_Bit_Index < 7 then
              r_Bit_Index <= r_Bit_Index + 1;
              r_SM_Main   <= s_TX_Data_Bits; --if still has bits to send FSM stays in s_TX_Data_Bits
            
				else
              r_Bit_Index <= 0;
              r_SM_Main   <= s_TX_Stop_Bit; --if all bits sent FSM goes to s_TX_Stop_Bit
            
				end if;
          
			 end if;
 
 
        
        when s_TX_Stop_Bit =>
          o_TX_Serial <= '1'; -- Send out Stop bit.  Stop bit = 1
 
          -- Wait g_CLKS_PER_BIT-1 clock cycles for Stop bit to finish
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= s_TX_Stop_Bit;
          
			 else
            
            r_Clk_Count <= 0;
            r_SM_Main   <= s_Cleanup; --FSM goes in s_Cleanup after Stop bit sent
          
			 end if;
 
                   
        -- Stay here 1 clock
        when s_Cleanup =>
         
          r_SM_Main   <= s_Idle; -- FSM goes to s_Idle
			 
			 if (index > 0) then    --cheks if all bytes are sent
			 index <= index - 1;
          o_TX_Active <= '1';    -- transmission is in progress
          r_TX_Done   <= '0';    --transmission not done
			 
			 else
			 index <= 3;
			 o_TX_Active <= '0';    -- transmission is not in progress
          r_TX_Done   <= '1';    --transmission done
			 
			 end if;
             
        when others =>
          r_SM_Main <= s_Idle; -- if in any other state FSM goes to IDLE (just to be sure)
 
      end case;
    end if;
  end process p_UART_TX;
 
  o_TX_Done <= r_TX_Done;
   
end RTL;