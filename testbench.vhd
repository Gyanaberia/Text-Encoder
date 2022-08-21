library ieee, std;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity TestBench is
end entity;

architecture reader of TestBench is
	component rle is
		port ( clk, rst : in std_logic;
		input : in std_logic_vector(7 downto 0);
		output: out std_logic_vector(7 downto 0);
		valid: out std_logic);
	end component;
	
	signal input_sig, output_sig: std_logic_vector (7 downto 0);
	signal v,clk,rst: std_logic;
begin
	dut_instance: rle
		port map (clk,rst,input_sig,output_sig,v);
	
	process
		file input_file: text open read_mode is "D:\LENOVO\Downloads\testcases\testcases\file_4.txt";
		file output_file: text open write_mode is "C:\Users\LENOVO\Desktop\output.txt";
		variable input_line, output_line: line;
		variable input_var, output_var : std_logic_vector (7 downto 0);
		
	begin
		rst <= '1';
		clk <= '1';
		wait for 20 ns;
		clk <= '0';
		wait for 10 ns;
		rst <= '0';
		
		for i in 0 to 96 loop
			if not endfile(input_file) then
				readline (input_file, input_line);
				read (input_line, input_var);
				input_sig <= input_var;
			else
				input_sig <= "00000001";
			end if;
			wait for 10 ns;
			clk <= '1';
			wait for 20 ns;
			clk <= '0';
			wait for 20 ns;
			
			output_var := output_sig;
			if(v = '1') then
				write (output_line, output_var);
				writeline (output_file, output_line);
			end if;
		end loop;
	wait;
	end process;

end architecture;
