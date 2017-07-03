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
-- Generated on "06/26/2017 22:31:14"
                                                            
-- Vhdl Test Bench template for design  :  top
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY top_vhd_tst IS
END top_vhd_tst;
ARCHITECTURE top_arch OF top_vhd_tst IS
-- constants
constant clk_period: time := 20 ns;                                                 
-- signals                                                   
SIGNAL clk : STD_LOGIC;
SIGNAL data_in : STD_LOGIC;
SIGNAL data_out : STD_LOGIC;
SIGNAL reset : STD_LOGIC;
COMPONENT top
	PORT (
	clk : IN STD_LOGIC;
	data_in : IN STD_LOGIC;
	data_out : BUFFER STD_LOGIC;
	reset : IN STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : top
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	data_in => data_in,
	data_out => data_out,
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
        
	reset <= '0';
        data_in <= '0';
	wait for 434*clk_period;
	data_in <= '0';
	wait for 434*clk_period;
	data_in <= '1';
	wait for 434*clk_period;
	data_in <= '0';
	wait for 434*clk_period;
	data_in <= '0';
	wait for 434*clk_period;
	data_in <= '0';
	wait for 434*clk_period;
	data_in <= '0';
	wait for 434*clk_period;
	data_in <= '0';
	wait for 434*clk_period;
	data_in <= '1';
        wait for 434*clk_period;
        data_in <= '1';
        wait for 434*clk_period;
	
        data_in <= '0';
	wait for 434*clk_period;
        data_in <= '0';
	wait for 434*clk_period; 
        data_in <= '1';
	wait for 434*clk_period;
	data_in <= '1';
	wait for 434*clk_period;
	data_in <= '1';
	wait for 434*clk_period;
	data_in <= '0';
	wait for 434*clk_period;
	data_in <= '0';
	wait for 434*clk_period;
	data_in <= '0';
	wait for 434*clk_period;
	data_in <= '0';
	wait for 434*clk_period;
        data_in <= '1';
        wait for 434*clk_period;
	

        data_in <= '0';
	wait for 434*clk_period;
        data_in <= '0';
	wait for 434*clk_period;
	data_in <= '0';
	wait for 434*clk_period;
	data_in <= '0';
	wait for 434*clk_period;
        data_in <= '0';
	wait for 434*clk_period;
	data_in <= '0';
	wait for 434*clk_period;
	data_in <= '0';
	wait for 434*clk_period;
	data_in <= '0';
	wait for 434*clk_period;
	data_in <= '0';
	wait for 434*clk_period;
	data_in <= '1';
        wait for 434*clk_period;


        data_in <= '0';
	wait for 434*clk_period;
        data_in <= '0';
	wait for 434*clk_period;
	data_in <= '0';
	wait for 434*clk_period;
	data_in <= '0';
	wait for 434*clk_period;
	data_in <= '0';
	wait for 434*clk_period;
	data_in <= '0';
	wait for 434*clk_period;
        data_in <= '0';
	wait for 434*clk_period;
	data_in <= '0';
	wait for 434*clk_period;
	data_in <= '0';
	wait for 434*clk_period;
	data_in <= '1';
        wait for 434*clk_period;
        
	wait for 100*clk_period;
	reset <= '1';
	         




WAIT;                                                        
END PROCESS always;                                          
END top_arch;
