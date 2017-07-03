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
-- Generated on "05/12/2017 00:17:48"
                                                            
-- Vhdl Test Bench template for design  :  exp_fp_value
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY exp_fp_value_vhd_tst IS
END exp_fp_value_vhd_tst;
ARCHITECTURE exp_fp_value_arch OF exp_fp_value_vhd_tst IS
-- constants
constant clk_period: time := 20 ns;                                                 
-- signals                                                   
SIGNAL clk : STD_LOGIC;
SIGNAL exp_fp : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL exp_lut_data : STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL exp_lut_index : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL exp_sgn : STD_LOGIC;
SIGNAL reset : STD_LOGIC;
COMPONENT exp_fp_value
	PORT (
	clk : IN STD_LOGIC;
	exp_fp : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	exp_lut_data : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
	exp_lut_index : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
	exp_sgn : IN STD_LOGIC;
	reset : IN STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : exp_fp_value
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	exp_fp => exp_fp,
	exp_lut_data => exp_lut_data,
	exp_lut_index => exp_lut_index,
	exp_sgn => exp_sgn,
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
        -- code executes for every event on sensitivity list
        reset <= '1';
	 wait for 3*clk_period;
	 reset <= '0';
	 exp_lut_index <= "1011110";
         exp_lut_data <= "100000010";
         exp_sgn <= '0';
         wait for 3*clk_period;
         exp_lut_index <= "1111111";
         exp_lut_data <= "000000000";
         exp_sgn <= '0';
         wait for 3*clk_period;
         exp_lut_index <= "1111110";
         exp_lut_data <= "111000000";
         exp_sgn <= '0';
         wait for 3*clk_period;
         exp_lut_index <= "0001000";
         exp_lut_data <= "101110111";
         exp_sgn <= '1';  
WAIT;                                                        
END PROCESS always;                                          
END exp_fp_value_arch;
