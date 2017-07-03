-- Copyright (C) 2017  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Intel and sold by Intel or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "06/26/2017 16:14:35"
                                                            
-- Vhdl Test Bench template for design  :  LAU
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY LAU_vhd_tst IS
END LAU_vhd_tst;
ARCHITECTURE LAU_arch OF LAU_vhd_tst IS
-- constants 
constant clk_period: time := 20 ns;                                                
-- signals                                                   
SIGNAL clk : STD_LOGIC;
SIGNAL input_number : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL input_valid : STD_LOGIC;
SIGNAL output_number : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL output_valid : STD_LOGIC;
SIGNAL reset : STD_LOGIC;
COMPONENT LAU
	PORT (
	clk : IN STD_LOGIC;
	input_number : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	input_valid : IN STD_LOGIC;
	output_number : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	output_valid : OUT STD_LOGIC;
	reset : IN STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : LAU
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	input_number => input_number,
	input_valid => input_valid,
	output_number => output_number,
	output_valid => output_valid,
	reset => reset
	);
clk_process : PROCESS                                               
-- variable declarations                                     
BEGIN                                                        
        -- code that executes only once                      
       clk <= '0';
       wait for clk_period/2;
       clk <= '1';
       wait for clk_period/2;  
                                                     
END PROCESS clk_process;                                         
                                           
always : PROCESS                                              
-- optional sensitivity list                                  
-- (        )                                                 
-- variable declarations                                      
BEGIN     
	 input_valid <= '0';                                                    
         reset <= '1';
	 wait for 3*clk_period;
	 reset <= '0';
	 input_number <= "01000001011100000000000000000000";
         input_valid <= '1';
	 wait for 3*clk_period;
 	 input_valid <= '0';
	 wait for 1000 ns;
	 input_number <= "11000001110100000000000000000000";
         input_valid <= '1';
	 wait for 3*clk_period;
 	 input_valid <= '0';

	 wait for 1000 ns;
	 input_number <= "00000000000000000000000000000000";
         input_valid <= '1';
	 wait for 3*clk_period;
 	 input_valid <= '0';


WAIT;                                                        
END PROCESS always;                                          
END LAU_arch;
