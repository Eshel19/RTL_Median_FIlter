
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

package my_pack is

----file information 
constant color_depth : integer := 5;
constant pic_width : integer := 256;
constant pic_height : integer := 256;
constant filter_size : integer :=9;
constant time_until_c : integer :=4;
constant time_until_b : integer :=3; 
----

constant data_bus_length : integer:=color_depth*pic_width;
constant log2_pic_width : integer := integer(ceil(log2(real(pic_width))));
constant log2_pic_height : integer := integer(ceil(log2(real(pic_height))));

type row is array (natural range <>) of std_logic_vector(color_depth-1 downto 0);

subtype row_pad is row (pic_width+1 downto 0); -- use for pad row
subtype row_data is row (pic_width-1 downto 0) ; -- use for row from rom \ram
subtype addr is std_logic_vector(log2_pic_height-1 downto 0); -- use as signal for address 
subtype bus_vector is std_logic_vector(data_bus_length-1 downto 0);
subtype filer_rows is row (filter_size-1 downto 0);

constant mif_s : string := "x.mif";
constant ram_s : string := "xram";
type mif is array (natural range <>) of string(mif_s'range);
type ram is array (natural range <>) of string(ram_s'range);
type full_data is array (natural range<>) of bus_vector;


constant mif_name : mif :=("r.mif","g.mif","b.mif");
constant ram_name : ram :=("RRAM","GRAM","BRAM");


procedure replace_if_bigger (a,b : inout std_logic_vector);
procedure Odd_Even_sort(data : inout row; step: in integer:=0);
function get_mid_of_mid(a: row_pad;b: row_pad;c: row_pad) return row_data;
function comp (a: std_logic_vector; b: std_logic_vector) return std_logic_vector;--return 100 if a=b, return 010 if a>b return 001 if a<b 
function get_middle (a: std_logic_vector; b: std_logic_vector; c: std_logic_vector) return std_logic_vector;
function addone (a: std_logic_vector) return std_logic_vector; -- to make an effiction ++ for conter
function at_final_line (cur_addr: addr) return std_logic; -- effiction way to check if we are at the final line
function log2of (num : integer) return integer; 
function is_greater (a: std_logic_vector; b: std_logic_vector) return std_logic;
function full_midian_3X3 (a: row_pad;b: row_pad;c: row_pad) return row_data;
function Parallel_sort (data : row) return row;
function row_data_to_bus (data : row_data) return bus_vector;


end package my_pack;

package body my_pack is 

function log2of (num : integer) return integer is
	variable result : integer;
begin
	if(num=1) then return 0;
	end if;
	result:= 1+log2of(num/2);
	return result;
end function log2of;

function at_final_line (cur_addr: addr) return std_logic is
	variable final_add : std_logic_vector(addr'range);
	variable checker : std_logic;
begin
	checker:='1';
	final_add:=conv_std_logic_vector(pic_height-1,log2_pic_height);
	for i in cur_addr'range loop
		checker:=checker and (cur_addr(i) xnor final_add(i));
	end loop;
	return checker;
end function at_final_line;


function addone (a: std_logic_vector) return std_logic_vector is
	variable cer: std_logic_vector(a'length downto 0);
begin
	cer:=conv_std_logic_vector(0,a'length-1) & a(0) & (a(0) xor '1');
	for i in 1 to a'length-1 loop 
		cer(i+1):=cer(i) and a(i);
		cer(i):=(cer(i) xor a(i));
	end loop;
	return cer(a'length-1 downto 0);
end function addone;

function get_mid_of_mid(a: row_pad;b: row_pad;c: row_pad) return row_data is
	variable first_mid :row_pad;
	variable result: row_data;
begin

	for i in a'range loop
		first_mid(i):=get_middle(a(i),b(i),c(i));
	end loop;
	
	for i in 1 to (result'length) loop
		result(i-1):=get_middle(first_mid(i-1),first_mid(i),first_mid(i+1));
	end loop;
	
	return result;
end function get_mid_of_mid;


procedure replace_if_bigger (a,b : inout std_logic_vector) is 
	variable tmp : std_logic_vector(a'range);
begin 
	if(is_greater(a,b)='1') then
		tmp:=a;
		a:=b;
		b:=tmp;
	end if;
end procedure replace_if_bigger;

procedure Odd_Even_sort(data : inout row; step: in integer:=0) is  
begin

end procedure Odd_Even_sort;


function get_middle (a: std_logic_vector; b: std_logic_vector; c: std_logic_vector) return std_logic_vector is
	variable result : std_logic_vector(a'range);
begin
	if ((is_greater(A,B) and is_greater(c,a)) or (is_greater(A,c) and is_greater(b,a))) ='1'	then
            result := A;
        elsif ((is_greater(b,a) and is_greater(c,b)) or (is_greater(b,c) and is_greater(a,b)))='1' then
            result := B;
        else
            result := C;
        end if;
	return result;
end function get_middle;

function Parallel_sort (data : row) return row is
	variable filer_data,result : row (data'range);
	variable result2 : row(data'length downto 0);
begin
result:=data;
	if(result'length>1) then
		if(result'length=2) then
			replace_if_bigger(result(result'LEFT),result(result'RIGHT));
		else
			for i in result'LEFT downto ((result'LEFT+result'RIGHT)/2+1) loop
					replace_if_bigger(result(i), result(result'LEFT - (i - result'RIGHT)));
			end loop;
			if(((data'LEFT-data'RIGHT) mod 2) /=0) then
				result((result'LEFT) downto (result'LEFT+result'RIGHT)/2+1):=Parallel_sort(result((result'LEFT) downto (result'LEFT+result'RIGHT)/2+1));
				result(((result'LEFT+result'RIGHT)/2) downto result'RIGHT):=Parallel_sort(result(((result'LEFT+result'RIGHT)/2) downto result'RIGHT));
			else
				result((result'LEFT) downto (result'LEFT+result'RIGHT)/2):=Parallel_sort(result((result'LEFT) downto (result'LEFT+result'RIGHT)/2));
				result(((result'LEFT+result'RIGHT)/2)-1 downto result'RIGHT):=Parallel_sort(result(((result'LEFT+result'RIGHT)/2)-1 downto result'RIGHT));
			end if;
		end if;

	end if;
	return result;
end function Parallel_sort;



function full_midian_3X3 (a: row_pad;b: row_pad;c: row_pad) return row_data is
	variable filer_data : filer_rows;
	variable result : row_data;
	variable tmp : std_logic_vector(color_depth-1 downto 0);
begin
	for i in (result'length) downto 1 loop
		filer_data(0):=a(i-1);
		filer_data(1):=b(i-1);
		filer_data(2):=c(i-1);
		filer_data(3):=a(i);
		filer_data(4):=b(i);
		filer_data(5):=c(i);
		filer_data(6):=a(i+1);
		filer_data(7):=b(i+1);
		filer_data(8):=c(i+1);
		filer_data:=Parallel_sort(filer_data);
		replace_if_bigger(filer_data((filer_data'LEFT+filer_data'RIGHT)/2+1),result((filer_data'LEFT+filer_data'RIGHT)/2));
		replace_if_bigger(filer_data((filer_data'LEFT+filer_data'RIGHT)/2+1),result((filer_data'LEFT+filer_data'RIGHT)/2-1));
		replace_if_bigger(filer_data((filer_data'LEFT+filer_data'RIGHT)/2),result((filer_data'LEFT+filer_data'RIGHT)/2-1));
		result(i-1):=filer_data(4);
	end loop;
	return result;
end function full_midian_3X3;



function comp (a: std_logic_vector; b: std_logic_vector) return std_logic_vector is
	variable	e,g,l : std_logic;
	variable result : std_logic_Vector (2 downto 0);
begin
	(e,g,l):=std_logic_vector'(o"4");
		for i in a'range loop
		   g:=g or (a(i) and (not b(i)) and e);
			l:=l or (b(i) and (not a(i)) and e);
			e:=(a(i) xnor b(i)) and e;
		end loop;	
		result:= e & g & l;
		return result;
end function comp;

function row_data_to_bus (data : row_data) return bus_vector is
	variable result : bus_vector;
begin
	for i in pic_width downto 1 loop
		result(i*color_depth-1 downto ((i*color_depth-1)-(color_depth-1))):=data(i-1);
	end loop;
	return result;
end function row_data_to_bus;


function is_greater (a: std_logic_vector; b: std_logic_vector) return std_logic is
	variable result,checker : std_logic;
begin
	result:='0';
	checker:='1';
	for i in a'range loop

	result:=result or (checker and a(i) and (not b(i)));
	checker:=checker and not((b(i) and (not a(i))));
	end loop;
	return result;
end function is_greater;

end package body my_pack;
