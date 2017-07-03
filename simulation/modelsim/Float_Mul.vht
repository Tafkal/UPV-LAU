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
-- Generated on "05/06/2017 19:32:38"
                                                            
-- Vhdl Test Bench template for design  :  Float_Mul
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY Float_Mul_vhd_tst IS
END Float_Mul_vhd_tst;
ARCHITECTURE Float_Mul_arch OF Float_Mul_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL A : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL B : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL Clk : STD_LOGIC;
SIGNAL Finish : STD_LOGIC;
SIGNAL Reset : STD_LOGIC;
SIGNAL Start : STD_LOGIC;
SIGNAL Y : STD_LOGIC_VECTOR(31 DOWNTO 0);
COMPONENT Float_Mul
	PORT (
	A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	Clk : IN STD_LOGIC;
	Finish : BUFFER STD_LOGIC;
	Reset : IN STD_LOGIC;
	Start : IN STD_LOGIC;
	Y : BUFFER STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;
BEGIN
	i1 : Float_Mul
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
	A <= x"c2906666";
	B <= x"00000000";
	wait for 20 ns;
	Start <= '1';
	wait for 20 ns;
	Start <= '0';

WAIT;                                                        
END PROCESS always;                                          
END Float_Mul_arch;
