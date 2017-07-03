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
-- Generated on "05/11/2017 23:11:24"
                                                            
-- Vhdl Test Bench template for design  :  fp_adder
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY fp_adder_vhd_tst IS
END fp_adder_vhd_tst;
ARCHITECTURE fp_adder_arch OF fp_adder_vhd_tst IS
-- constants
constant clk_period: time := 20 ns;                                                 
-- signals                                                   
SIGNAL A : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL B : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL clk : STD_LOGIC;
SIGNAL ready : STD_LOGIC;
SIGNAL reset : STD_LOGIC;
SIGNAL result : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL valid_out : STD_LOGIC;
COMPONENT fp_adder
	PORT (
	A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	clk : IN STD_LOGIC;
	ready : IN STD_LOGIC;
	reset : IN STD_LOGIC;
	result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	valid_out : OUT STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : fp_adder
	PORT MAP (
-- list connections between master ports and signals
	A => A,
	B => B,
	clk => clk,
	ready => ready,
	reset => reset,
	result => result,
	valid_out => valid_out
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
        -- code executes for every event on sensitivity list 
        reset <= '1';
	 wait for 3*clk_period;
	 reset <= '0';
	 ready <= '1';
         A <= "00111111111000000000000000000000";
         B <= "11000000001000000000000000000000";
         wait for 15*clk_period;
         ready <= '0';
         wait for 3*clk_period;
         ready <= '1';
         A <= "01000011100111000000000000000000";
         B <= "01000010100111000000000000000000";
         wait for 15*clk_period;
         ready <= '0';
         wait for 3*clk_period;
         ready <= '1';
         A <= "01000000000000000000000000000000";
         B <= "01001100011100000000000000000000";
         wait for 15*clk_period;
         ready <= '0';
         wait for 3*clk_period;
         ready <= '1';
         A <= "01000010101110100000000000000000";
         B <= "01000010101010100000000000000000";
         wait for 15*clk_period;
         ready <= '0';
         wait for 3*clk_period;
         ready <= '1';
         A <= "01000001000000000000000000000000";
         B <= "01000101000000000000000000000000";
         wait for 15*clk_period;
         ready <= '0';
         wait for 3*clk_period;
         ready <= '1';
         A <= "11000111011110000000000000000000";
         B <= "11000111111110000000000000000000";
         wait for 15*clk_period;
         ready <= '0';
         wait for 3*clk_period;
         ready <= '1';
         A <= "11000010010010000000000000000000";
         B <= "01000001011100000000000000000000";
         wait for 15*clk_period;
         ready <= '0';
         wait for 3*clk_period;
         ready <= '1';
         A <= "00111110100110011001100110011010";
         B <= "00111111011010111000010100011111";
         wait for 15*clk_period;
         ready <= '0';
         wait for 3*clk_period;
         ready <= '1';
         A <= "01000001011100000000000000000000";
         B <= "11000010001010000000000000000000";
         wait for 15*clk_period;
         ready <= '0';
       
         
         
          
WAIT;                                                        
END PROCESS always;                                          
END fp_adder_arch;
