-- Copyright (C) 1991-2016 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, the Altera Quartus Prime License Agreement,
-- the Altera MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Altera and sold by Altera or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "05/01/2017 18:22:54"
                                                            
-- Vhdl Test Bench template for design  :  Shift_Reg
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY Shift_Reg_vhd_tst IS
END Shift_Reg_vhd_tst;
ARCHITECTURE Shift_Reg_arch OF Shift_Reg_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL Clk : STD_LOGIC;
SIGNAL Load : STD_LOGIC;
SIGNAL P_in : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL P_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL Reset : STD_LOGIC;
SIGNAL S_in : STD_LOGIC;
SIGNAL S_out : STD_LOGIC;
SIGNAL Shift : STD_LOGIC;
COMPONENT Shift_Reg
	PORT (
	Clk : IN STD_LOGIC;
	Load : IN STD_LOGIC;
	P_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	P_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	Reset : IN STD_LOGIC;
	S_in : IN STD_LOGIC;
	S_out : OUT STD_LOGIC;
	Shift : IN STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : Shift_Reg
	PORT MAP (
-- list connections between master ports and signals
	Clk => Clk,
	Load => Load,
	P_in => P_in,
	P_out => P_out,
	Reset => Reset,
	S_in => S_in,
	S_out => S_out,
	Shift => Shift
	);
clk_p : PROCESS                                               
-- variable declarations                                     
BEGIN                                                        
Clk <= '0';
wait for 10 ns;
Clk <= '1';
wait for 10 ns;                                                       
END PROCESS clk_p;                                           
always : PROCESS                                              
-- optional sensitivity list                                  
-- (        )                                                 
-- variable declarations                                      
BEGIN                                                         
       reset <= '1';
	Load <= '0';
	Shift <= '0';
	S_in <= '0';
	wait for 25 ns;
	reset <= '0';
	wait for 5 ns;
	P_in <=  x"fa51fa51";
	wait for 5 ns;
	Load <= '1';
	wait for 20 ns;
	Load <= '0';
	wait for 20 ns;
	Shift <= '1';
	P_in <=  x"aaaaaaaa";
	wait for 100 ns;
	S_in <= '1';
WAIT;                                                        
END PROCESS always;                                          
END Shift_Reg_arch;
