----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 12.12.2017 17:48:44
-- Design Name:
-- Module Name: FSM_testbench - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY project_tb IS
END project_tb;
ARCHITECTURE projecttb OF project_tb IS
	CONSTANT c_CLOCK_PERIOD : TIME := 100 ns;
	SIGNAL tb_done : std_logic;
	SIGNAL mem_address : std_logic_vector (15 DOWNTO 0) := (OTHERS => '0');
	SIGNAL tb_rst : std_logic := '0';
	SIGNAL tb_start : std_logic := '0';
	SIGNAL tb_clk : std_logic := '0';
	SIGNAL mem_o_data, mem_i_data : std_logic_vector (7 DOWNTO 0);
	SIGNAL enable_wire : std_logic;
	SIGNAL mem_we : std_logic;

	TYPE ram_type IS ARRAY (65535 DOWNTO 0) OF std_logic_vector(7 DOWNTO 0);
	--signal RAM: ram_type := (0 => "00011000", 1 =>"00000111",2 => "00000010", 29 => "00000011", 30 => "00000011", 31 => "00000011", 32 => "00000011", 35 => "00000111", 36 => "00000111", 37 => "00000111", 38 => "00000111", 41 => "00001011", 42 => "00001011", 43 => "00001011", 44 => "00001011", 47 => "00001111", 53 => "00000011", 59 => "00000111", 65 => "00011111", 71 => "00011001", 77 => "00000011", 78 => "00000011", 79 => "00000011", 83 => "00000111", 84 => "00000111", 85 => "00000111", 89 => "00011111", 90 => "00011111", 91 => "00011111", 95 => "00011001", 101 => "00000011", 107 => "00000111", 113 => "00011111", 119 => "00011001", 125 => "00000011", 131 => "00000111", 132 => "00000111", 133 => "00000111", 134 => "00000111", 137 => "00001011", 138 => "00001011", 139 => "00001011", 140 => "00001011", 143 => "00001111", 144 => "00001111", 145 => "00001111", 146 => "00001111", others => (others =>'0'));
	SIGNAL RAM : 
	ram_type := (0 => std_logic_vector(to_unsigned(169, 8)), 
	             1 => std_logic_vector(to_unsigned(75, 8)), 
	             2 => std_logic_vector(to_unsigned(32, 8)), 
	             3 => std_logic_vector(to_unsigned(111, 8)), 
	             4 => std_logic_vector(to_unsigned(213, 8)), 
	             5 => std_logic_vector(to_unsigned(79, 8)), 
	             6 => std_logic_vector(to_unsigned(33, 8)), 
	             7 => std_logic_vector(to_unsigned(1, 8)), 
	             8 => std_logic_vector(to_unsigned(33, 8)), 
	             9 => std_logic_vector(to_unsigned(80, 8)), 
	             10 => std_logic_vector(to_unsigned(35, 8)), 
	             11 => std_logic_vector(to_unsigned(12, 8)), 
	             12 => std_logic_vector(to_unsigned(254, 8)), 
	             13 => std_logic_vector(to_unsigned(215, 8)), 
	             14 => std_logic_vector(to_unsigned(78, 8)), 
	             15 => std_logic_vector(to_unsigned(211, 8)), 
	             16 => std_logic_vector(to_unsigned(121, 8)), 
	             17 => std_logic_vector(to_unsigned(78, 8)), 
	             18 => std_logic_vector(to_unsigned(33, 8)), 
	             19 => std_logic_vector(to_unsigned(17, 8)),
	             OTHERS => (OTHERS => '0'));
	COMPONENT project_reti_logiche IS
		PORT (
			i_clk      : IN std_logic;
			i_start    : IN std_logic;
			i_rst      : IN std_logic;
			i_data     : IN std_logic_vector(7 DOWNTO 0); --1 byte
			o_address  : OUT std_logic_vector(15 DOWNTO 0); --16 bit addr: max size is 255*255 + 3 more for max x and y and thresh.
			o_done     : OUT std_logic;
			o_en       : OUT std_logic;
			o_we       : OUT std_logic;
			o_data     : OUT std_logic_vector (7 DOWNTO 0)
		);
	END COMPONENT project_reti_logiche;
BEGIN
	UUT : project_reti_logiche
	PORT MAP(
		i_clk      => tb_clk, 
		i_start    => tb_start, 
		i_rst      => tb_rst, 
		i_data     => mem_o_data, 
		o_address  => mem_address, 
		o_done     => tb_done, 
		o_en       => enable_wire, 
		o_we       => mem_we, 
		o_data     => mem_i_data
	);

	p_CLK_GEN : PROCESS IS
	BEGIN
		WAIT FOR c_CLOCK_PERIOD/2;
		tb_clk <= NOT tb_clk;
	END PROCESS p_CLK_GEN;
 
 
	MEM : PROCESS (tb_clk)
	BEGIN
		IF tb_clk'EVENT AND tb_clk = '1' THEN
			IF enable_wire = '1' THEN
				IF mem_we = '1' THEN
					RAM(conv_integer(mem_address)) <= mem_i_data;
					mem_o_data <= mem_i_data;
				ELSE
					mem_o_data <= RAM(conv_integer(mem_address));
				END IF;
			END IF;
		END IF;
	END PROCESS;

 
	test : PROCESS IS
	BEGIN
		WAIT FOR 100 ns;
		WAIT FOR c_CLOCK_PERIOD;
		tb_rst <= '1';
		WAIT FOR c_CLOCK_PERIOD;
		tb_rst <= '0';
		WAIT FOR c_CLOCK_PERIOD;
		tb_start <= '1';
		WAIT FOR c_CLOCK_PERIOD;
		tb_start <= '0';
		WAIT UNTIL tb_done = '1';
		WAIT UNTIL tb_done = '0';
		WAIT UNTIL rising_edge(tb_clk);

		ASSERT RAM(18) = "11111111" REPORT "FAIL high bits" SEVERITY failure;
		ASSERT false REPORT "Simulation Ended!, test passed" SEVERITY failure;
	END PROCESS test;

END projecttb;