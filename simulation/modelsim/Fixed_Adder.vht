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
-- Generated on "05/05/2017 17:51:28"
                                                            
-- Vhdl Test Bench template for design  :  Fixed_Adder
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY Fixed_Adder_vhd_tst IS
END Fixed_Adder_vhd_tst;
ARCHITECTURE Fixed_Adder_arch OF Fixed_Adder_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL A : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL B : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL Clk : STD_LOGIC;
SIGNAL Finish : STD_LOGIC;
SIGNAL Reset : STD_LOGIC;
SIGNAL Start : STD_LOGIC;
SIGNAL Y : STD_LOGIC_VECTOR(8 DOWNTO 0);
COMPONENT Fixed_Adder
	PORT (
	A : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	B : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	Clk : IN STD_LOGIC;
	Finish : OUT STD_LOGIC;
	Reset : IN STD_LOGIC;
	Start : IN STD_LOGIC;
	Y : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
	);
END COMPONENT;
BEGIN
	i1 : Fixed_Adder
	PORT MAP (
-- list connections between master ports and signals
	A => A,
	B => B,
	Clk => Clk,
	Finish => Finish,
	Reset => Reset,
	Start => Start,
	Y => Y
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
BEGIN                                                         
        Reset <= '1';
	Start <= '0';
	wait for 25 ns;
	Reset <= '0';
	wait for 20 ns;
	A <= x"02";
	B <= x"01";
	wait for 20 ns;
	Start <= '1';
	wait for 20 ns;
	Start <= '0';

WAIT;                                                        
END PROCESS always;                                          
END Fixed_Adder_arch;
