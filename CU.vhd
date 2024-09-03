library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;
use IEEE.numeric_std.ALL;
library work;
use work.my_pack.all;

entity CU is
    Port ( 	clk, rst, Start	 	 : in  STD_LOGIC;
				read_en,write_en		 : out std_logic;
				done						 : out std_logic;
				read_addr,write_addr  : out addr);
end CU;

architecture CU_arch of CU is
    type state_type is (S0, S1, S2, S3, S4); -- S0 => start | S1 => read first Line | S2 => Read all lines | S3 => Read last line again | S4 => Done
    signal current_state, next_state : state_type;
	 signal count_to_c, count_to_b			: integer;
	 signal write_en_temp, last_line,last_line_wr 		: STD_LOGIC;
	 signal addr_wr, adrr_rd 					: addr;
	 
begin


last_line<= at_final_line(adrr_rd);
last_line_wr<=at_final_line(addr_wr);
read_addr<=adrr_rd;
write_addr<=addr_wr;
write_en_temp<= '1' when (count_to_c=time_until_c and count_to_b/=time_until_b)  else '0';
read_en<= '1' when ((next_state = s1) or (next_state = s2)) else '0';
write_en<=write_en_temp;
done <= '1' when next_state=s4 else '0';


	FSM_inside_implemention : process(clk, rst) 
		begin
			if rst = '1' then -- Reset to initial state
				current_state <= S0; 
				count_to_c<=0;
				count_to_b<=0;
				addr_wr<=(others=>'0');
				adrr_rd<=(others=>'0');
			elsif rising_edge(clk) then
				current_state<=next_state;
				if((((next_state=s1) or (next_state=s2)) and ((count_to_c/=time_until_c)))) then
					count_to_c<=count_to_c+1;
				end if;
				if(((last_line_wr='1') and ((count_to_b/=time_until_b)))) then
					count_to_b<=count_to_b+1;
				end if;
				if(write_en_temp='1' and last_line_wr='0') then
					addr_wr<=addr_wr+1;
				end if;
				if(last_line='0' and (next_state = s2)) then
					adrr_rd<=adrr_rd+1;
				end if;
				
		end if;
	end process;

    State_Machine_state_change : process(current_state, next_state, Start, adrr_rd,write_en_temp,last_line)
		 begin
			  case current_state is
					when S0 =>
						 if Start = '1' then
							  next_state <= S1;			-- Move to next state
						 else
							  next_state <= S0;			-- Move to current state
						 end if;
					when s1 => next_state<=s2;
					when S2 =>
						if last_line = '1' then
							next_state <= S3;				-- Move to current state
						else
							next_state <= S2;				-- Move to next state
						end if;
					
					when S3 => 
						if(write_en_temp='1') then
							next_state <= S3;	
							else
							next_state <= S4;	
						end if;	
					when S4 =>
						next_state <= S4;				-- Move to current state
			  end case;
		 end process;
end CU_arch;
