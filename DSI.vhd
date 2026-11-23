library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DSI_FSM_Compact is
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
end DSI_FSM_Compact;

architecture Behavioral of DSI_FSM_Compact is
    type state_type is (IDLE, SWAP, EXACT, SEARCH, APPROX, ADD, DONE);
    signal state, next_state : state_type := IDLE;

    signal reg_A, reg_B         : std_logic_vector(N-1 downto 0);
    signal multiplicand         : std_logic_vector(N-1 downto 0);
    signal multiplier           : std_logic_vector(N-1 downto 0);
    signal shift_amount         : integer range 0 to 2*N-1;
    signal valid_bit            : std_logic;
    signal exact_result         : std_logic_vector(2*N-1 downto 0);
    signal approx_result        : std_logic_vector(2*N-1 downto 0);
    signal reg_exact_result     : std_logic_vector(2*N-1 downto 0);
    signal reg_pout             : std_logic_vector(2*N-1 downto 0);

begin

    -- State Register
    process(clk, rst)
    begin
        if rst = '1' then
            state <= IDLE;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    -- Next State Logic
    process(state, start)
        variable found : boolean := false;
        constant S_WIDTH : integer := D / 2;
        variable mult_ext   : unsigned(2*N-1 downto 0);
        variable shift_1    : unsigned(2*N-1 downto 0);
        variable shift_2    : unsigned(2*N-1 downto 0);
        variable partial_mult : unsigned(2*N-1 downto 0);
    begin
        -- Default
        next_state <= state;

        case state is

            when IDLE =>
                if start = '1' then
                    next_state <= SWAP;
                end if;

            when SWAP =>
                if unsigned(reg_A) < unsigned(reg_B) then
                    multiplicand <= reg_A;
                    multiplier   <= reg_B;
                else
                    multiplicand <= reg_B;
                    multiplier   <= reg_A;
                end if;
                next_state <= EXACT;

            when EXACT =>
                partial_mult := resize(unsigned(multiplicand) * unsigned(multiplier(N-1 downto N-D)), 2*N);
                exact_result <= std_logic_vector(shift_left(partial_mult, (N - D)));
                next_state <= SEARCH;

            when SEARCH =>
                found := false;
                shift_amount <= 0;
                valid_bit <= '0';

                for i in D-1 downto S_WIDTH loop
                    if multiplier(i) = '1' and not found then
                        shift_amount <= i;
                        valid_bit <= '1';
                        found := true;
                    end if;
                end loop;

                if not found then
                    shift_amount <= D - S_WIDTH - 1;
                    valid_bit <= '0';
                end if;

                reg_exact_result <= exact_result;
                next_state <= APPROX;

            when APPROX =>
                mult_ext := resize(unsigned(multiplicand), 2*N);
                shift_1 := shift_left(mult_ext, shift_amount);
                if valid_bit = '1' and shift_amount > 0 then
                    shift_2 := shift_left(mult_ext, shift_amount - 1);
                    approx_result <= std_logic_vector(shift_1 + shift_2);
                else
                    approx_result <= std_logic_vector(shift_1);
                end if;
                next_state <= ADD;

            when ADD =>
                reg_pout <= std_logic_vector(unsigned(reg_exact_result) + unsigned(approx_result));
                next_state <= DONE;

            when DONE =>
                next_state <= IDLE;

        end case;
    end process;

    -- Sample inputs
    process(clk)
    begin
        if rising_edge(clk) then
            if state = IDLE and start = '1' then
                reg_A <= A;
                reg_B <= B;
            end if;
        end if;
    end process;

    -- Outputs
    POUT <= reg_pout;
    done_flag <= '1' when state = DONE else '0';

end Behavioral;
