library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.my_pack.all;


entity proj_top is
port (
      clk    : in    std_logic; 
      rst    : in    std_logic;  
      start  : in    std_logic;   
      done   : out   std_logic);
     attribute altera_chip_pin_lc : string;
     attribute altera_chip_pin_lc of clk  : signal is "AF14";
     attribute altera_chip_pin_lc of rst  : signal is "AB28";
	 attribute altera_chip_pin_lc of start: signal is "AC28";
     attribute altera_chip_pin_lc of done : signal is "E21";
end entity proj_top;

ARCHITECTURE arc_proj_top of proj_top is

component pip is
	port(
		data_in: in bus_vector;
		data_out: out bus_vector;
		clk: in std_logic;
		rst: in std_logic
		);
end component;

component XRAM IS
GENERIC (rom_fn:string:="XROM");
	PORT
	(
		aclr : in std_logic;
		address		: IN addr;
		clock		: IN STD_LOGIC;
		data		: IN bus_vector;
		wren		: IN STD_LOGIC ;
		q		: OUT bus_vector
	);
end component XRAM;

component XROM IS
	generic (mif_fn :string:="r.mif");
	PORT
	(
		aclr : in std_logic;
		address		: IN addr;
		clock		: IN STD_LOGIC;
		rden		: IN STD_LOGIC;
		q		: OUT bus_vector
	);
END component XROM;

component CU is
port (
	clk : in std_logic;
	rst : in std_logic;
	start : in std_logic;
	read_en,write_en,done : out std_logic;
	read_addr,write_addr : out addr
);
end component CU;

 signal data_out,data_in : full_data(2 downto 0);
 signal read_en,write_en : std_logic;
 signal read_addr,write_addr : addr;
 
begin

FSM: CU port map(
	clk=>clk ,
	rst=>rst ,
	start=>start,
	read_en=>read_en,
	write_en=>write_en,
	done=>done,
	read_addr=>read_addr,
	write_addr=>write_addr
	
);

Full_pip: for i in 2 downto 0 GENERATE
	ROM:XROM 
	generic map(mif_fn =>mif_name(i))
	port map(
		aclr=>rst,
		address=>read_addr,
		clock=>clk,
		rden=>read_en,
		q=>data_in(i)
	);
	RAM:XRAM 
	GENERIC map(rom_fn=>ram_name(i))
	port map(
		aclr=>rst,
		address=>write_addr,
		clock=>clk,
		data=>data_out(i),
		wren=>write_en
	);
	Buff_FIler:pip port map(
		data_in=>data_in(i),
		data_out=>data_out(i),
		clk=>clk,
		rst=>rst
	);
end GENERATE Full_pip;

end ARCHITECTURE arc_proj_top;
