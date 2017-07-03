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
-- Generated on "05/11/2017 23:23:49"
                                                            
-- Vhdl Test Bench template for design  :  exp_fp_gen
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY exp_fp_gen_vhd_tst IS
END exp_fp_gen_vhd_tst;
ARCHITECTURE exp_fp_gen_arch OF exp_fp_gen_vhd_tst IS
-- constants   
constant clk_period: time := 20 ns;                                              
-- signals                                                   
SIGNAL clk : STD_LOGIC;
SIGNAL exp_fp_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL exp_value : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL reset : STD_LOGIC;
COMPONENT exp_fp_gen
	PORT (
	clk : IN STD_LOGIC;
	exp_fp_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	exp_value : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	reset : IN STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : exp_fp_gen
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	exp_fp_out => exp_fp_out,
	exp_value => exp_value,
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
	 exp_value <= "10000010";
         wait for 3*clk_period;
         exp_value <= "01111111";
         wait for 3*clk_period;
         exp_value <= "01111110";
         wait for 3*clk_period;
         exp_value <= "00001000";

  
WAIT;                                                        
END PROCESS always;                                          
END exp_fp_gen_arch;
