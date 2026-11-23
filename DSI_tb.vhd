library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DSI_FSM_Compact_tb is
end DSI_FSM_Compact_tb;

architecture Behavioral of DSI_FSM_Compact_tb is

    constant N : integer := 16;
    constant D : integer := 8;

    signal clk, rst, start, done_flag : std_logic := '0';
    signal A, B : std_logic_vector(N-1 downto 0);
    signal POUT : std_logic_vector(2*N-1 downto 0);

    component DSI_FSM_Compact is
        generic (
            N : integer := 16;
            D : integer := 8
        );
        port (
            clk        : in  std_logic;
            rst        : in  std_logic;
            start      : in  std_logic;
            A, B       : in  std_logic_vector(N-1 downto 0);
            POUT       : out std_logic_vector(2*N-1 downto 0);
            done_flag  : out std_logic
        );
    end component;

begin

    uut: DSI_FSM_Compact
        generic map (N => N, D => D)
        port map (
            clk        => clk,
            rst        => rst,
            start      => start,
            A          => A,
            B          => B,
            POUT       => POUT,
            done_flag  => done_flag
        );

    clk_process : process
    begin
        while true loop
            clk <= '0'; wait for 5 ns;
            clk <= '1'; wait for 5 ns;
        end loop;
    end process;

    stim_proc: process
    begin
        -- Reset pulse
        rst <= '1'; wait for 20 ns;
        rst <= '0'; wait for 20 ns;

        -- Test Case 1: A < B (Best-case)
        A <= x"924C";
        B <= x"E9C5";
        start <= '1'; wait for 10 ns;
        start <= '0';
        wait until done_flag = '1';
        wait for 20 ns;

        -- Test Case 2: A > B
        A <= x"F0F0";
        B <= x"1234";
        start <= '1'; wait for 10 ns;
        start <= '0';
        wait until done_flag = '1';
        wait for 20 ns;

        -- Test Case 3: A = B
        A <= x"AAAA";
        B <= x"AAAA";
        start <= '1'; wait for 10 ns;
        start <= '0';
        wait until done_flag = '1';
        wait for 20 ns;

        wait;
    end process;

end Behavioral;
