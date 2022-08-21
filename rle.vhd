library IEEE;
use IEEE.STD_LOGIC_1164.all;
--use ieee.numeric_std.all;
USE ieee.std_logic_arith.all;
 
entity rle is

port(input: in std_logic_vector(7 downto 0);
	clk,rst:in std_logic;
	output:out std_logic_vector(7 downto 0);
	valid:out std_logic);
end entity;

architecture compress of rle is
	signal prev: std_logic_vector(7 downto 0):=(others=>'0');

	type memory_type is array (0 to 127) of std_logic_vector(7 downto 0);
	signal m : memory_type:=(others => (others => '0')) ;   --memory for queue.
	signal rp,wp : integer := 0;  --read and write pointers.

	begin

		process(clk)
		variable n : integer := 0;  
		variable count: integer:=0;

		begin
		if(rising_edge(clk)) then
			if(prev="00000001") then
				count:=0;
			elsif(count=15) then--if count is 15
				m(wp) <= "00011011";--store esc
				m(wp+1)<="00001111";--15
				m(wp+2)<=prev;--and current character
				wp <= (wp + 3);  --update write pointer to point next free pointer
				n := n+3;--increase elements in array by 3

				--add esc 15 char to buffer,change count to 0
				count:=0;
				
			elsif( prev/=input )  then
				if(prev="00011011") and (count>0) then--if prev element is esc
					m(wp) <= "00011011";--add esc
					m(wp+1)<=conv_std_logic_vector(count,8);--count,but first convert to binary
					m(wp+2)<="00011011";--esc
					wp <= wp + 3;  --update write pointer to point next free pointer					
					n := n+3;

				elsif(count=1) then 
					--add char to buffer
					m(wp)<=prev;--add single char 
					wp<=(wp+1) ;--update pointer
					n :=n+1;--update no of element
					
				elsif(count=2) then
					--add char char to buffer
					m(wp)<=prev;--add [rev char 2 times
					m(wp+1)<=prev;
					wp<=(wp+2);--update pointer
					n:=n+2;--update no of elemetn by 2
				elsif(count>2) then
					--add esc n char to buffer
					m(wp) <= "00011011";--add esc
					m(wp+1)<=conv_std_logic_vector(count,8);--add count but first convert to binary
					m(wp+2)<=prev;--add char
					wp <= (wp + 3);  --update pointer
					n := n+3;--update element no
				end if;
					
				prev<=input;--save current char
				count:=1;	--reset count to 1
			else
				count:=count+1;--if current is same as prev,just increase count by 1
			end if;
			
			
			if(n>0) then--withtin same clk,if current array size>0
				valid<='1';--set datavalid to 1
			  output<= m(rp);--output
			  rp <= rp + 1;--update read pointer      
			  n := n-1;--decrease no of elements
			else
				valid<='0';--else no output
			 end if;
	--		if(rp = 128) then      --resetting read pointer.
	  --      rp <= 0;
		--	end if;
		  -- if(wp = depth) then        --resetting write pointer.
			 -- wp <= 0;
				
		--   end if; 
		end if;
		end process;
	end compress;
			
