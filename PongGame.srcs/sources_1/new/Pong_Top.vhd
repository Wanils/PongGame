----------------------------------------------------------------------------------
-- Engineer: Filip Rydzewski (Wanils)
-- Create Date: 11.09.2021 14:00
-- Design Name: Pong_Game
-- Module Name: Pong_Top - rtl
-- Target Devices: Basys3 Board
-- Notes: Module based on the one created by Nandaland. It is designed for 640x480 
-- with a 25 MHz input clock. It is responsible for the entire pong game.
-- Prefixes: g_ stands for Generic, o_ stands for Output signal, i_ stands for 
-- Input signal, s_ stands for Signal, c_ stands for constant, p_ stand for process.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.PONG_PKG.ALL;
 
entity Pong_Top is
  generic (
    g_Video_Width    : integer;
    g_Total_Columns  : integer;
    g_Total_Rows     : integer;
    g_Active_Columns : integer;
    g_Active_Rows    : integer);
  port (
    clk              : in std_logic;
    i_HSync          : in std_logic;
    i_VSync          : in std_logic;
    -- Input from UART Receiver
    i_UART_RX        : in std_logic_vector (7 downto 0);
    i_UART_DV        : in std_logic;
    -- Buttons and switches
    i_Button_Start   : in std_logic;
    i_Button_RST     : in std_logic;
    i_Paddle_Move_P1 : in std_logic;
    i_Paddle_Lock_P1 : in std_logic;
    i_Paddle_Move_P2 : in std_logic;
    i_Paddle_Lock_P2 : in std_logic;
    -- 7 Segment display
    display          : out std_logic_vector (6 downto 0);
    enable           : out std_logic_vector (3 downto 0);
    -- VGA outputs
    o_HSync          : out std_logic;
    o_VSync          : out std_logic;
    o_Red_Video      : out std_logic_vector(g_Video_Width-1 downto 0);
    o_Blu_Video      : out std_logic_vector(g_Video_Width-1 downto 0);
    o_Grn_Video      : out std_logic_vector(g_Video_Width-1 downto 0));
end entity Pong_Top;
 
architecture rtl of Pong_Top is
 
  constant c_clock_freq : integer := 25000000;
  signal   s_counter_1s : integer range 0 to c_clock_freq -1 := 0;
  signal   s_Draw_state : std_logic_vector(2 downto 0) := "000";
  signal   s_UART_RX    : std_logic_vector(7 downto 0);
  type SM_Main is (Idle, Count_3, Count_2, Count_1, Game_Running, P1_Scores, P2_Scores, P1_Wins, P2_Wins, Clean);
  signal   SM_Pong : SM_Main := Idle;

  signal s_HSync : std_logic;
  signal s_VSync : std_logic;
  signal s_Columns_Count : std_logic_vector(9 downto 0);
  signal s_Rows_Count    : std_logic_vector(9 downto 0);
  -- Dividing counters by 16. It makes the screen of 40x30 locations -> easier to deal with
  signal s_Columns_Count_Div : std_logic_vector(5 downto 0) := (others => '0');
  signal s_Rows_Count_Div    : std_logic_vector(5 downto 0) := (others => '0');
 
  -- Integer representation of the above counters -> way easier to work with
  signal s_Columns_Index : integer range 0 to 2**s_Columns_Count_Div'length-1 := 0;
  signal s_Rows_Index    : integer range 0 to 2**s_Rows_Count_Div'length-1 := 0; 
 
  signal s_Draw_Paddle_P1  : std_logic;
  signal s_Draw_Paddle_P2  : std_logic;
  signal s_Paddle_Y_P1     : std_logic_vector(5 downto 0);
  signal s_Paddle_Y_P2     : std_logic_vector(5 downto 0);
  signal s_Draw_Ball       : std_logic;
  signal s_Ball_X          : std_logic_vector(5 downto 0);
  signal s_Ball_Y          : std_logic_vector(5 downto 0);
  signal s_Draw_Word       : std_logic;
  signal s_Draw_Any        : std_logic;
  signal s_Game_Active     : std_logic;
  signal s_Paddle_Y_P1_Top : unsigned(5 downto 0);
  signal s_Paddle_Y_P1_Bot : unsigned(5 downto 0);
  signal s_Paddle_Y_P2_Top : unsigned(5 downto 0);
  signal s_Paddle_Y_P2_Bot : unsigned(5 downto 0);
  signal s_P1_Score        : integer range 0 to c_Score_Limit := 0;
  signal s_P2_Score        : integer range 0 to c_Score_Limit := 0;
  signal s_P1_Score_STD    : std_logic_vector(3 downto 0) := std_logic_vector(to_unsigned(s_P1_Score,4));
  signal s_P2_Score_STD    : std_logic_vector(3 downto 0) := std_logic_vector(to_unsigned(s_P2_Score,4));
  -- Signals for 7-SEG DISPLAY
  signal Seg_0             : std_logic_vector (6 downto 0);
  signal Seg_1             : std_logic_vector (6 downto 0) := "0111111";
  signal Seg_2             : std_logic_vector (6 downto 0) := "0111111";
  signal Seg_3             : std_logic_vector (6 downto 0);
  signal toggle		         : std_logic_vector(3 downto 0) := "1110";
  signal refresh_cnt  	   : integer := 0;
  constant refresh_max	   : integer := 50000; -- 500 Hz 
  
   
begin
----------------------------------------------------------------------------------
------------------------------MODULES INSTANTIATION-------------------------------
----------------------------------------------------------------------------------
  -- HEX to 7-Segment Converter for players scores
  Seg0 : entity work.Hex2seg
    port map(
      hex => s_P2_Score_STD,
      seg => Seg_0);
  Seg3 : entity work.Hex2seg
    port map(
      hex => s_P1_Score_STD,
      seg => Seg_3);
  -- Sync to Count
  Sync_To_Count_Mod : entity work.Sync_To_Count
    generic map (
      g_Total_Columns => g_Total_Columns,
      g_Total_Rows    => g_Total_Rows)
    port map (
      clk             => clk,
      i_HSync         => i_HSync,
      i_VSync         => i_VSync,
      o_HSync         => s_HSync,
      o_VSync         => s_VSync,
      o_Col_Count     => s_Columns_Count,
      o_Row_Count     => s_Rows_Count);
  -- Instantiation of Paddle for P1
  Paddle_P1_Mod : entity work.Pong_Paddle
  generic map (
    g_Player_Paddle_X   => c_Paddle_Col_Location_P1)
  port map (
    clk                 => clk,
    i_Columns_Count_Div => s_Columns_Count_Div,
    i_Rows_Count_Div    => s_Rows_Count_Div,
    i_Paddle_Move       => i_Paddle_Move_P1,
    i_Paddle_Lock       => i_Paddle_Lock_P1,
    o_Draw_Paddle       => s_Draw_Paddle_P1,
    o_Paddle_Y          => s_Paddle_Y_P1);
-- Instantiation of Paddle for P2
Paddle_P2_Mod : entity work.Pong_Paddle
  generic map (
    g_Player_Paddle_X   => c_Paddle_Col_Location_P2)
  port map (
    clk                 => clk,
    i_Columns_Count_Div => s_Columns_Count_Div,
    i_Rows_Count_Div    => s_Rows_Count_Div,
    i_Paddle_Move       => i_Paddle_Move_P2,
    i_Paddle_Lock       => i_Paddle_Lock_P2,
    o_Draw_Paddle       => s_Draw_Paddle_P2,
    o_Paddle_Y          => s_Paddle_Y_P2);
-- Instantiation of Ball
Pong_Ball_Mod : entity work.Pong_Ball
  port map (
    clk                 => clk,
    i_Game_Active       => s_Game_Active,
    i_Columns_Count_Div => s_Columns_Count_Div,
    i_Rows_Count_Div    => s_Rows_Count_Div,
    o_Draw_Ball         => s_Draw_Ball,
    o_Ball_X            => s_Ball_X,
    o_Ball_Y            => s_Ball_Y);
-- Instantiation of Digits/Words
Pong_Words_Mod : entity work.Pong_Words
  port map (
    clk                 => clk,
    i_Draw_State        => s_Draw_state,
    i_Columns_Count_Div => s_Columns_Count_Div,
    i_Rows_Count_Div    => s_Rows_Count_Div,
    o_Draw_Word         => s_Draw_Word);
----------------------------------------------------------------------------------
-------------------------------SIGNALS ASSIGNMENT---------------------------------
----------------------------------------------------------------------------------
  -- Divide by 16 -> create 40x30 screen of areas
  s_Columns_Count_Div <= s_Columns_Count(s_Columns_Count'left downto 4);
  s_Rows_Count_Div    <= s_Rows_Count(s_Rows_Count'left downto 4);
  -- Signals for Bot and Top Paddle P1 position
  s_Paddle_Y_P1_Bot   <= unsigned(s_Paddle_Y_P1);
  s_Paddle_Y_P1_Top   <= s_Paddle_Y_P1_Bot + to_unsigned(c_Paddle_Height, s_Paddle_Y_P1_Bot'length);
  -- Signals for Bot and Top Paddle P2 position
  s_Paddle_Y_P2_Bot   <= unsigned(s_Paddle_Y_P2);
  s_Paddle_Y_P2_Top   <= s_Paddle_Y_P2_Bot + to_unsigned(c_Paddle_Height, s_Paddle_Y_P2_Bot'length);
  -- Conditional Assignment of Game Active based on State Machine
  s_Game_Active       <= '1' when SM_Pong = Game_Running else '0';
  -- OR Gate -> draw anything
  s_Draw_Any          <= s_Draw_Ball or s_Draw_Paddle_P1 or s_Draw_Paddle_P2 or s_Draw_Word ;
  -- 7 Segment display
  enable              <= toggle;
----------------------------------------------------------------------------------
-----------------------------------PROCESSES--------------------------------------
----------------------------------------------------------------------------------
  -- Register syncs
  p_Reg_Syncs : process (clk) is
  begin
    if rising_edge(clk) then
      o_VSync <= s_VSync;
      o_HSync <= s_HSync;
    end if;
  end process p_Reg_Syncs; 
  -- State Machine process
  p_SM_Main : process (clk) is
  begin
    if rising_edge(clk) then
      case SM_Pong is
        when Idle => -- Stay in this state until Game Start button is hit (either space on a PC or top button on Basys-3 Board)
          if i_Button_RST = '1' then
            s_Draw_state <= "000";
            s_P1_Score <= 0;
            s_P2_Score <= 0;
            SM_Pong <= Idle;
          else
            if (i_UART_RX = x"20" and i_UART_DV = '1') or i_Button_Start = '1' then
              SM_Pong <= Count_3;
            end if;
          end if;
        when Count_3 => -- Stay here 1 sec and display "3" on the screen
          if i_Button_RST = '1' then
            s_Draw_state <= "000";
            s_P1_Score <= 0;
            s_P2_Score <= 0;
            SM_Pong <= Idle;
          else
            s_Draw_state <= "011";
            if s_counter_1s = c_clock_freq - 1 then
              s_counter_1s <= 0;
              SM_Pong <= Count_2;
            else
              s_counter_1s <= s_counter_1s + 1;
            end if;
          end if;
        when Count_2 => -- Stay here 1 sec and display "2" on the screen
          if i_Button_RST = '1' then
            s_Draw_state <= "000";
            s_P1_Score <= 0;
            s_P2_Score <= 0;
            SM_Pong <= Idle;
          else
            s_Draw_state <= "010";
            if s_counter_1s = c_clock_freq - 1 then
              s_counter_1s <= 0;
              SM_Pong <= Count_1;
            else
              s_counter_1s <= s_counter_1s + 1;
            end if;
          end if;
        when Count_1 => -- Stay here 1 sec and display "1" on the screen
          if i_Button_RST = '1' then
            s_Draw_state <= "000";
            s_P1_Score <= 0;
            s_P2_Score <= 0;
            SM_Pong <= Idle;
          else
            s_Draw_state <= "001";
            if s_counter_1s = c_clock_freq - 1 then
              s_counter_1s <= 0;
              SM_Pong <= Game_Running;
              s_Draw_state <= "000";
            else
              s_counter_1s <= s_counter_1s + 1;
            end if;
          end if;
        when Game_Running => -- Game starts. Stay here until either player misses the ball
          if i_Button_RST = '1' then
            s_Draw_state <= "000";
            s_P1_Score <= 0;
            s_P2_Score <= 0;
            SM_Pong <= Idle;
          else
            -- Player 1's Side:
            if s_Ball_X = std_logic_vector(to_unsigned(0, s_Ball_X'length)) then
              if (unsigned(s_Ball_Y) < s_Paddle_Y_P1_Bot or
                  unsigned(s_Ball_Y) > s_Paddle_Y_P1_Top) then
                SM_Pong <= P2_Scores;
              end if;
            -- Player 2's Side:
            elsif s_Ball_X = std_logic_vector(to_unsigned(c_Game_Width-1, s_Ball_X'length)) then
              if (unsigned(s_Ball_Y) < s_Paddle_Y_P2_Bot or
                  unsigned(s_Ball_Y) > s_Paddle_Y_P2_Top) then
                SM_Pong <= P1_Scores;
              end if;
            end if;
          end if;
        when P1_Scores => -- P1 Scores -> P1 Score = P1 Score + 1
          if s_P1_Score = c_Score_Limit-1 then -- Chceck if P1 won
            s_P1_Score <= s_P1_Score + 1;
            SM_Pong <= P1_Wins;
          else
            s_P1_Score <= s_P1_Score + 1;
            SM_Pong  <= Clean;
          end if;
        when P2_Scores => -- P1 Scores -> P2 Score = P2 Score + 1
          if s_P2_Score = c_Score_Limit-1 then -- Chceck if P2 won
            s_P2_Score <= s_P2_Score + 1;
            SM_Pong <= P2_Wins;
          else
            s_P2_Score <= s_P2_Score + 1;
            SM_Pong <= Clean;
          end if;
        when P1_Wins => -- P1 Wins. Stay here until Game Start button is hit (either space on a PC or top button on Basys-3 Board) and display "P1 WINS" on screen
          if i_Button_RST = '1' then
            s_Draw_state <= "000";
            s_P1_Score <= 0;
            s_P2_Score <= 0;
            SM_Pong <= Idle;
          else
            s_Draw_state <= "100";
            if (i_UART_RX = x"20" and i_UART_DV = '1') or i_Button_Start = '1' then
              s_P1_Score <= 0;
              s_P2_Score <= 0;
              SM_Pong <= Clean;
              s_Draw_state <= "000";
            end if;
          end if;
        when P2_Wins => -- P2 Wins. Stay here until Game Start button is hit (either space on a PC or top button on Basys-3 Board) and display "P2 WINS" on screen
          if i_Button_RST = '1' then
            s_Draw_state <= "000";
            s_P1_Score <= 0;
            s_P2_Score <= 0;
            SM_Pong <= Idle;
          else
            s_Draw_state <= "110";
            if (i_UART_RX = x"20" and i_UART_DV = '1') or i_Button_Start = '1' then
              s_P1_Score <= 0;
              s_P2_Score <= 0;
              SM_Pong <= Clean;
              s_Draw_state <= "000";
            end if;  
          end if;
        when Clean => -- Stay here for one clock cycle
          SM_Pong <= Idle;
        when others =>
          SM_Pong <= Idle;
      end case;
    end if;
  end process p_SM_Main;
  -- HEX 7 - SEGMENT DISPLAY processes
  p_refresh_counter: process(clk) -- 500 Hz refresh rate
  begin
    if(rising_edge(clk)) then
        if(refresh_cnt = refresh_max - 1) then
            refresh_cnt <= 0;
        else 
            refresh_cnt <= refresh_cnt + 1;
        end if;
    end if;
  end process p_refresh_counter;

  p_toggle_count_proc: process(clk)
  begin
    if(rising_edge(clk)) then
        if(i_Button_RST = '1') then
            toggle <= toggle;
        elsif(refresh_cnt = refresh_max - 1) then
            toggle <=  toggle(2 downto 0) & toggle(3);
        end if;
    end if;
  end process p_toggle_count_proc;
  
  p_toggle_proc: process(toggle,Seg_0,Seg_1,Seg_2,Seg_3)
  begin
    if(toggle(0) = '0') then
        display <= Seg_0;
    elsif(toggle(1) = '0') then
        display <= Seg_1;
    elsif(toggle(2) = '0') then
        display <= Seg_2;
    elsif(toggle(3) = '0') then
        display <= Seg_3;
    else
        display <= (others => '0');
    end if;
  end process p_toggle_proc;
  -- When x"20" is received (Space on PC) do not change s_UART_RX -> because it would reset colors.
  p_UART_exception: process (clk)
  begin
    if rising_edge(clk) then
      if i_UART_DV = '1' then
        if i_UART_RX /= x"20" then
          s_UART_RX <= i_UART_RX;
        else 
          s_UART_RX <= s_UART_RX;
        end if;
      end if;
    end if;
  end process p_UART_exception;
  -- Assign Color outputs based on received data from UART
    p_Change_Color : process (clk)
    begin
      if rising_edge(clk) then
        case s_UART_RX is
          when x"31" => -- White
            if s_Draw_Any = '1' then
              o_Red_Video <= (others => '1');
              o_Blu_Video <= (others => '1');
              o_Grn_Video <= (others => '1');
            else
              o_Red_Video <= (others => '0');
              o_Blu_Video <= (others => '0');
              o_Grn_Video <= (others => '0');
            end if; 
          when x"32" => -- Red
            if s_Draw_Any = '1' then
              o_Red_Video <= (others => '1');
              o_Blu_Video <= (others => '0');
              o_Grn_Video <= (others => '0');
            else
              o_Red_Video <= (others => '0');
              o_Blu_Video <= (others => '0');
              o_Grn_Video <= (others => '0');
            end if; 
          when x"33" => -- Blue
            if s_Draw_Any = '1' then
              o_Red_Video <= (others => '0');
              o_Blu_Video <= (others => '1');
              o_Grn_Video <= (others => '0');
            else
              o_Red_Video <= (others => '0');
              o_Blu_Video <= (others => '0');
              o_Grn_Video <= (others => '0');
            end if; 
          when x"34" => -- Green
            if s_Draw_Any = '1' then
              o_Red_Video <= (others => '0');
              o_Blu_Video <= (others => '0');
              o_Grn_Video <= (others => '1');
            else
              o_Red_Video <= (others => '0');
              o_Blu_Video <= (others => '0');
              o_Grn_Video <= (others => '0');
            end if; 
          when x"35" => -- Magenta
            if s_Draw_Any = '1' then
              o_Red_Video <= (others => '1');
              o_Blu_Video <= (others => '1');
              o_Grn_Video <= (others => '0');
            else
              o_Red_Video <= (others => '0');
              o_Blu_Video <= (others => '0');
              o_Grn_Video <= (others => '0');
            end if; 
          when x"36" => -- Yellow
            if s_Draw_Any = '1' then
              o_Red_Video <= (others => '1');
              o_Blu_Video <= (others => '0');
              o_Grn_Video <= (others => '1');
            else
              o_Red_Video <= (others => '0');
              o_Blu_Video <= (others => '0');
              o_Grn_Video <= (others => '0');
            end if; 
          when x"37" => -- Cyan
            if s_Draw_Any = '1' then
              o_Red_Video <= (others => '0');
              o_Blu_Video <= (others => '1');
              o_Grn_Video <= (others => '1');
            else
              o_Red_Video <= (others => '0');
              o_Blu_Video <= (others => '0');
              o_Grn_Video <= (others => '0');
            end if; 
          when others => -- White
            if s_Draw_Any = '1' then
              o_Red_Video <= (others => '1');
              o_Blu_Video <= (others => '1');
              o_Grn_Video <= (others => '1');
            else
              o_Red_Video <= (others => '0');
              o_Blu_Video <= (others => '0');
              o_Grn_Video <= (others => '0');
            end if; 
        end case;
      end if;
    end process p_Change_Color;

end architecture rtl;