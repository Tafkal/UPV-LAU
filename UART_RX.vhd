--! @file UART_RX
--! @brief UART receiver
--! @details This file describes UART reciver 
--! It has the  UART_RX's entity interface description and
--! and one behavioral architecture description. \n
--! \n
--! @author Natalija Colic 90/2013 \n
--! @date 15/4/2017
--! @version 1.0
--!

-- This file contains the UART Receiver.  This receiver is able to
-- receive 8 bits of serial data, one start bit, one stop bit,
-- and no parity bit.  When receive is complete o_rx_dv will be
-- driven high for one clock cycle.
-- 


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--! @brief Entity declaration for UART_RX
--! @detals   This receiver is able to receive 32 bits of serial data, by receiving 4 bytes with one start bit, 
--! one stop bit and no parity bit.  When receive is complete <b>o_RX_DV<b/> will be
--! driven high for one clock cycle.
--! The interface description is shown in Fig. 1
--! @image html UART_RX_block.png "Fig. 1. UART_RX block"
 
entity UART_RX is
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
end UART_RX;

--! @brief Behavioral architecture for UART_RX
--! @details
--! UART_RX is realized as a state machine shown in Fig. 2
--! @image html UART_RX_FSM.png "Fig. 2. UART_RX FSM"
--! Input clock <b>clk</b> is used for state_transition. 
--! Initial state of the state machine is <b>s_Idle</b>, in which the initialization is implemented. 
--! If signal<b>i_RX_Serial</b> is 0 start bit is detected and, the state machine goes to <b>s_RX_Start_Bit</b> state, otherwise it stays
--! in <b>s_Idle</b>. In <b>s_RX_Start_Bit</b> state start bit is received. Then state machine goes to <b>s_RX_Data_Bits</b>.
--! In this state machine receives one byte of the data. Then it goes to <b>s_RX_Stop_Bit</b> when it receives one stop bit.
--! After that machine goes to <b>s_Cleanup<b/> state where it checks if all bytes were received and raises <b>o_RX_DV<b/> flag
--! and after returns to <s_Idle> state.
 
 
architecture rtl of UART_RX is


  --! Definition of states of UART_TX state machine. See detailed description for more details.
  type t_SM_Main is (s_Idle, s_RX_Start_Bit, s_RX_Data_Bits,
                     s_RX_Stop_Bit, s_Cleanup);
  signal r_SM_Main : t_SM_Main := s_Idle;
 
  -- Definitions of signals used in the implementation of UART_TX
  signal r_RX_Data_R : std_logic := '0'; --received bit
  signal r_RX_Data   : std_logic := '0'; --received bit
   
  signal r_Clk_Count : integer range 0 to g_CLKS_PER_BIT-1 := 0; --counter for clocks
  signal r_Bit_Index : integer range 7 downto 0 := 0;  -- 8 Bits Total
  signal r_RX_Byte   : std_logic_vector(7 downto 0) := (others => '0'); --1 byte of received data 
  signal r_RX_DV     : std_logic := '0'; --receiving done
  signal index       : integer range 3 downto 0 := 3; --counter for bytes
begin
 
  
  -- Purpose: Double-register the incoming data.
  -- This allows it to be used in the UART RX Clock Domain.
  -- (It removes problems caused by metastabiliy)
  p_SAMPLE : process (i_Clk)
  begin
    if rising_edge(i_Clk) then
      r_RX_Data_R <= i_RX_Serial;
      r_RX_Data   <= r_RX_Data_R;
    end if;
  end process p_SAMPLE;
   
 
   --! State transition process.\n
  --! Next state process. This process defines when the state machine changes states.
  --! When <b>i_RX_Serial<b/> is set to 0 machine starts the state sequence for every byte
  --! <b>s_Idle - s_RX_Start_Bit - s_RX_Data_Bits - s_RX_Stop_Bit - s_Cleanup - s_Idle</b> \n 
  p_UART_RX : process (i_Clk)
  begin
    if rising_edge(i_Clk) then
         
      case r_SM_Main is
 
        when s_Idle =>
          r_RX_DV     <= '0';
          r_Clk_Count <= 0;
          r_Bit_Index <= 0;
 
          if r_RX_Data = '0' then       -- Start bit detected
            r_SM_Main <= s_RX_Start_Bit; -- FSM goes to s_RX_Start_Bit state
          
			 else
            r_SM_Main <= s_Idle; --FSM stays in s_Idle
          end if;
 
           
        -- Check middle of start bit to make sure it's still low
        when s_RX_Start_Bit =>
          if r_Clk_Count = (g_CLKS_PER_BIT-1)/2 then
            
				if r_RX_Data = '0' then --check if 
              r_Clk_Count <= 0;  -- reset counter since we found the middle
              r_SM_Main   <= s_RX_Data_Bits; --FSM goes to s_RX_Data_Bits if received bit is still 0
            
				else
              r_SM_Main   <= s_Idle; -- if received bit changed to 1 than it's not Start bit, FSM goes to s_Idle
            
				end if;
          
			 else
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= s_RX_Start_Bit; --FSM stays to s_RX_Start_Bit if not middle middle of start bit lasting
          
			 end if;
 
           
        -- Wait g_CLKS_PER_BIT-1 clock cycles to sample serial data
        when s_RX_Data_Bits =>
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= s_RX_Data_Bits;
          
			 else
            r_Clk_Count            <= 0;
            r_RX_Byte(r_Bit_Index) <= r_RX_Data;
             
            -- Check if we have received out all bits
            if r_Bit_Index < 7  then
              r_Bit_Index <= r_Bit_Index + 1;
              r_SM_Main   <= s_RX_Data_Bits; --if there is more bits to be received than FSM stays in s_RX_Data_Bits
            
				else
              r_Bit_Index <= 0;
              r_SM_Main   <= s_RX_Stop_Bit; --if all bits are received, FSM goes to s_RX_Stop_Bit
            
				end if;
          
			 end if;
 
 
        
        when s_RX_Stop_Bit =>
          -- Wait g_CLKS_PER_BIT-1 clock cycles for Stop bit to finish
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= s_RX_Stop_Bit; -- Receive Stop bit.  Stop bit = 1
          else
            r_RX_DV     <= '0';
            r_Clk_Count <= 0;
            r_SM_Main   <= s_Cleanup; --FSM goes in s_Cleanup after Stop bit received
          end if;
 
                   
        -- Stay here 1 clock
        when s_Cleanup =>
          r_SM_Main <= s_Idle; --FSM goes to s_Idle state
          
        case (index) is -- based on index it is decided which byte is received			
			when 3 =>
				o_RX_Data(31 downto 24) <= r_RX_Byte;
			   index <= index - 1;
				r_RX_DV     <= '0';
			when 2 =>
				o_RX_Data(23 downto 16) <= r_RX_Byte;
			   index <= index - 1;
				r_RX_DV     <= '0';
			when 1 =>
				o_RX_Data(15 downto 8) <= r_RX_Byte;
			   index <= index - 1;
				r_RX_DV     <= '0';
			when 0 =>
				o_RX_Data(7 downto 0) <= r_RX_Byte;
			   index <= 3;
			   r_RX_DV     <= '1';
			when others =>
				o_RX_Data(31 downto 0) <= x"00000000";
			   r_RX_DV     <= '0';
			end case;
		  
             
        when others =>
          r_SM_Main <= s_Idle; -- if in any other state FSM goes to IDLE (just to be sure)
 
      end case;
    end if;
	 
 
  
  end process p_UART_RX;
 
 o_RX_DV   <= r_RX_DV;
   
end rtl;