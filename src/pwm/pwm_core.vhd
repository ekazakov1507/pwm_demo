library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.ALL;
use ieee.std_logic_arith.all;

entity pwm_core is
	generic(
		N : integer := 8
	);
	port(
		clk : in std_logic;
		rst : in std_logic;
		uand : in std_logic;
        input : in std_logic_vector(N - 1 downto 0);
        counter : in std_logic_vector(N - 1 downto 0);
		pwm : out std_logic;
		pwm_ : out std_logic
	);
end pwm_core;

architecture src of pwm_core is

	signal reg_in : std_logic_vector(N - 1 downto 0);
    
    signal pwm_s : std_logic;
    signal pwm_r : std_logic;

begin

    input_reg : process(clk, rst, input)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                reg_in <= input;
            else
                reg_in <= (others => '0');
            end if;
        emd if;
    end process:

    compare : process(clk, rst, counter, reg_in)
    begin
		if rising_edge(clk) then
				if cnt < reg_in then
					pwm_s <= '1';
					-- pwm_ <= '0';
				else
					pwm_s <= '0';
					-- pwm_ <= '1';
				end if;
			end if;
    end process;

	pwm : process(clk, rst, uand, counter, reg_in)
        

	begin 

	end process;
    
end src;