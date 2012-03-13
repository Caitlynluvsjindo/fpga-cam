library IEEE;
        use IEEE.std_logic_1164.all;
		  use IEEE.std_logic_signed.all;
		  use ieee.math_real.log2;
		  use ieee.math_real.ceil;
		  use ieee.numeric_std.all;

PACKAGE camera IS
component i2c_master is
	port(
 		clock : in std_logic; 
 		arazb : in std_logic; 
 		slave_addr : in std_logic_vector(6 downto 0 ); 
 		data_in : in std_logic_vector(7 downto 0 );
		data_out : out std_logic_vector(7 downto 0 );  
 		send : in std_logic; 
 		rcv : in std_logic; 
 		scl : inout std_logic; 
 		sda : inout std_logic; 
 		dispo, ack_byte : out std_logic
	); 
end component;

component register_rom is
	port(
		clk,en : in std_logic;
 		data : out std_logic_vector(15 downto 0 ); 
 		addr : in std_logic_vector(7 downto 0 )
	); 
end component;

component yuv_register_rom is
	port(
		clk,en : in std_logic;
 		data : out std_logic_vector(15 downto 0 ); 
 		addr : in std_logic_vector(7 downto 0 )
	); 
end component;

component rgb565_register_rom is
	port(
		clk,en : in std_logic;
 		data : out std_logic_vector(15 downto 0 ); 
 		addr : in std_logic_vector(7 downto 0 )
	); 
end component;

component camera_interface is
	port(
 		clock : in std_logic; 
 		i2c_clk : in std_logic; 
 		arazb : in std_logic; 
 		pixel_data : in std_logic_vector(7 downto 0 ); 
 		y_data : out std_logic_vector(7 downto 0 ); 
 		u_data : out std_logic_vector(7 downto 0 ); 
 		v_data : out std_logic_vector(7 downto 0 ); 
 		scl : inout std_logic; 
 		sda : inout std_logic; 
 		pixel_clock_out, hsync_out, vsync_out : out std_logic; 
 		pxclk, href, vsync : in std_logic
	); 
end component;

component yuv_camera_interface is
	port(
 		clock : in std_logic; 
 		i2c_clk : in std_logic; 
 		arazb : in std_logic; 
 		pixel_data : in std_logic_vector(7 downto 0 ); 
 		y_data : out std_logic_vector(7 downto 0 ); 
 		u_data : out std_logic_vector(7 downto 0 ); 
 		v_data : out std_logic_vector(7 downto 0 ); 
 		scl : inout std_logic; 
 		sda : inout std_logic; 
 		pixel_clock_out, hsync_out, vsync_out : out std_logic; 
 		pxclk, href, vsync : in std_logic
	); 
end component;

component rgb565_camera_interface is
	port(
 		clock : in std_logic; 
 		i2c_clk : in std_logic; 
 		arazb : in std_logic; 
 		pixel_data : in std_logic_vector(7 downto 0 ); 
 		r_data : out std_logic_vector(7 downto 0 ); 
 		g_data : out std_logic_vector(7 downto 0 ); 
 		b_data : out std_logic_vector(7 downto 0 ); 
 		scl : inout std_logic; 
 		sda : inout std_logic; 
 		pixel_clock_out, hsync_out, vsync_out : out std_logic; 
 		pxclk, href, vsync : in std_logic
	); 
end component;

component down_scaler is
	port(
 		clk : in std_logic; 
 		arazb : in std_logic; 
 		pixel_clock, hsync, vsync : in std_logic; 
 		pixel_clock_out, hsync_out, vsync_out : out std_logic; 
 		pixel_data_in : in std_logic_vector(7 downto 0 ); 
 		pixel_data_out : out std_logic_vector(7 downto 0 )
	); 
end component;


component line_ram is
	port(
 		clk : in std_logic; 
 		we, en : in std_logic; 
 		data_out : out std_logic_vector(15 downto 0 ); 
 		data_in : in std_logic_vector(15 downto 0 ); 
 		addr : in std_logic_vector(6 downto 0 )
	); 
end component;


component send_picture is
	port(
 		clk : in std_logic; 
 		arazb : in std_logic; 
 		pixel_clock, hsync, vsync : in std_logic; 
 		pixel_data_in : in std_logic_vector(7 downto 0 ); 
 		data_out : out std_logic_vector(7 downto 0 ); 
 		send : out std_logic; 
		output_ready : in std_logic
	); 
end component;

component ram_Nx8 is
	generic(N : natural := 64; A : natural := 6);
	port(
 		clk : in std_logic; 
 		we, en : in std_logic; 
 		do : out std_logic_vector(7 downto 0 ); 
 		di : in std_logic_vector(7 downto 0 ); 
 		addr : in std_logic_vector( (A - 1) downto 0 )
	); 
end component;

component fifo_Nx8 is
	generic(N : natural := 64);
	port(
 		clk, arazb, sraz : in std_logic; 
 		wr, rd : in std_logic; 
		empty, full, data_rdy : out std_logic ;
 		data_out : out std_logic_vector(7 downto 0 ); 
 		data_in : in std_logic_vector(7 downto 0 )
	); 
end component;

component MAC16 is
port(clk, sraz : in std_logic;
	  add_subb	:	in std_logic;
	  A, B	:	in signed(15 downto 0);
	  RES	:	out signed(31 downto 0) 
);
end component;

component SAC16 is
port(clk, sraz : in std_logic;
	  A, B	:	in signed(15 downto 0);
	  RES	:	out signed(31 downto 0)  
);
end component;



type row3 is array (0 to 2) of signed(8 downto 0);
type mat3 is array (0 to 2) of row3;

type irow3 is array (0 to 2) of integer range -256 to 255;
type imat3 is array (0 to 2) of irow3;


type duplet is array (0 to 1) of integer range 0 to 3;
type index_array is array (0 to 8) of duplet ;


component block3X3 is
		generic(LINE_SIZE : natural := 640);
		port(
			clk : in std_logic; 
			arazb : in std_logic; 
			pixel_clock, hsync, vsync : in std_logic; 
			pixel_data_in : in std_logic_vector(7 downto 0 ); 
			new_block : out std_logic ;
			block_out : out mat3);
end component;

component conv3x3 is
generic(KERNEL : imat3 := ((1, 2, 1),(0, 0, 0),(-1, -2, -1));
		  NON_ZERO	: index_array := ((0, 0), (0, 1), (0, 2), (2, 0), (2, 1), (2, 2), (3, 3), (3, 3), (3, 3) ); -- (3, 3) indicate end  of non zero values
		  IS_POWER_OF_TWO : natural := 0 -- (3, 3) indicate end  of non zero values
		  );
port(
 		clk : in std_logic; 
 		arazb : in std_logic; 
 		new_block : in std_logic ;
		block3x3 : in mat3;
		new_conv : out std_logic ;
 		abs_res : out std_logic_vector(7 downto 0 );
		raw_res : out signed(15 downto 0 )
);
end component;

component sobel3x3 is
port(
 		clk : in std_logic; 
 		arazb : in std_logic; 
 		pixel_clock, hsync, vsync : in std_logic; 
 		pixel_clock_out, hsync_out, vsync_out : out std_logic; 
 		pixel_data_in : in std_logic_vector(7 downto 0 ); 
 		pixel_data_out : out std_logic_vector(7 downto 0 )

);
end component;


component binarization is
generic(INVERT : natural := 0; VALUE : std_logic_vector(7 downto 0) := X"FF");
port( 
 		pixel_data_in : in std_logic_vector(7 downto 0) ;
		upper_bound	:	in std_logic_vector(7 downto 0);
		lower_bound	:	in std_logic_vector(7 downto 0);
		pixel_data_out : out std_logic_vector(7 downto 0) 
);
end component;

component erode3x3 is
generic(INVERT : natural := 0; VALUE : std_logic_vector(7 downto 0) := X"FF");
port(
 		clk : in std_logic; 
 		arazb : in std_logic; 
 		pixel_clock, hsync, vsync : in std_logic; 
 		pixel_clock_out, hsync_out, vsync_out : out std_logic; 
 		pixel_data_in : in std_logic_vector(7 downto 0 ); 
 		pixel_data_out : out std_logic_vector(7 downto 0 )

);
end component;


component dilate3x3 is
generic(INVERT : natural := 0; VALUE : std_logic_vector(7 downto 0) := X"FF");
port(
 		clk : in std_logic; 
 		arazb : in std_logic; 
 		pixel_clock, hsync, vsync : in std_logic; 
 		pixel_clock_out, hsync_out, vsync_out : out std_logic; 
 		pixel_data_in : in std_logic_vector(7 downto 0 ); 
 		pixel_data_out : out std_logic_vector(7 downto 0 )

);
end component;

END camera;