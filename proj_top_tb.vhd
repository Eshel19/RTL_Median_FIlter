library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.my_pack.all;

entity proj_top_tb is
end entity proj_top_tb;


architecture arc_proj_top_tb of proj_top_tb is
component proj_top is
port (
      clk    : in    std_logic; 
      rst    : in    std_logic;  
      start  : in    std_logic;   
      done   : out   std_logic);
end component proj_top; 

	signal clk,rst,start,done : std_logic:='0';
begin

MC: proj_top port map(
	clk=>clk ,
	rst=>rst ,
	start=>start,
	done=>done
);

process
begin
	clk<=not clk;
	wait for 5 ns;
end process;


process 
begin
	rst<='1';
	wait for 10 ns;
	rst<='0';
	wait for 10 ns;
	start<='1';
	wait for 10 ns;
	start<='1';
	wait until done'event;
	wait for 100 ns;
end process;
end architecture arc_proj_top_tb;
