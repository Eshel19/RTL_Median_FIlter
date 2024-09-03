
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.my_pack.all;

entity pip is
port(
	data_in: in bus_vector;
	data_out: out bus_vector;
	clk: in std_logic;
	rst: in std_logic
);

end entity;

architecture arc_pip of pip is
	signal a,b,c : row_pad ;
	signal result :row_data;
begin
	process (clk,rst) is 
	begin
		if rst = '1' then
		for i in a'range loop
			a(i)<=(others=>'0');
			b(i)<=(others=>'0');
			c(i)<=(others=>'0');
		end loop;
		elsif rising_edge(clk) then 
		c<=b;
		b<=a;
		a(pic_width+1) <= data_in(data_bus_length-1 downto ((data_bus_length-1)-(color_depth-1)));-- duplticating msb
		a(0) <= data_in(color_depth-1 downto 0);-- duplticating lsb
		for i in pic_width downto 1 loop
				a(i) <= data_in(i*color_depth-1 downto ((i*color_depth-1)-(color_depth-1)));
		end loop;
		end if;

	end process;
	result<=full_midian_3X3(a,b,c);
	data_out<=row_data_to_bus(result);
end architecture arc_pip;
