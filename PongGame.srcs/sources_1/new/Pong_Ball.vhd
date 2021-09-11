----------------------------------------------------------------------------------
-- Engineer: Filip Rydzewski (Wanils)
-- Create Date: 11.09.2021 14:00
-- Design Name: Pong_Game
-- Module Name: Pong_Ball - rtl
-- Target Devices: Basys3 Board
-- Notes: Module based on the one created by Nandaland. It is designed for 640x480 
-- with a 25 MHz input clock. It is responsible for ball movement and its drawing.
-- Prefixes: g_ stands for Generic, o_ stands for Output signal, i_ stands for 
-- Input signal, s_ stands for Signal, c_ stands for constant, p_ stand for process.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.PONG_PKG.ALL;
 
entity Pong_Ball is
  port (
    clk                 : in  std_logic;
    i_Game_Active       : in  std_logic;
    i_Columns_Count_Div : in  std_logic_vector(5 downto 0);
    i_Rows_Count_Div    : in  std_logic_vector(5 downto 0);
    o_Draw_Ball         : out std_logic;
    o_Ball_X            : out std_logic_vector(5 downto 0);
    o_Ball_Y            : out std_logic_vector(5 downto 0));
end entity Pong_Ball;
 
architecture rtl of Pong_Ball is
 
  -- Integer representation of the above counters -> way easier to work with
  signal s_Columns_Index : integer range 0 to 2**i_Columns_Count_Div'length := 0;
  signal s_Rows_Index : integer range 0 to 2**i_Rows_Count_Div'length := 0;
  signal s_Ball_Counter  : integer range 0 to c_Ball_Speed := 0;
   
  -- X and Y location (Col, Row) for Pong Ball, also Previous Locations
  signal s_Ball_X        : integer range 0 to 2**i_Columns_Count_Div'length := 0;
  signal s_Ball_Y        : integer range 0 to 2**i_Rows_Count_Div'length := 0;
  signal s_Ball_X_Prev   : integer range 0 to 2**i_Columns_Count_Div'length := 0;
  signal s_Ball_Y_Prev   : integer range 0 to 2**i_Rows_Count_Div'length := 0;
  signal s_Draw_Ball     : std_logic := '0';

  -- State machine used to randomize where will the ball go at the start of the game
  type t_SM_Ball is (s_One,s_Two,s_Three,s_Four);
  signal r_SM_Ball : t_SM_Ball := s_One;
   
begin
 
  s_Columns_Index <= to_integer(unsigned(i_Columns_Count_Div));
  s_Rows_Index    <= to_integer(unsigned(i_Rows_Count_Div));  
 
     
  p_Move_Ball : process (clk) is
  begin
    if rising_edge(clk) then
      if i_Game_Active = '0' then
        -- Ball stays in the middle of the screen until one of the buttons is pressed
        s_Ball_X <= c_Game_Width/2;
        s_Ball_Y <= c_Game_Height/2;
        case r_SM_Ball is
          when s_One => -- Ball goes towards bottom left corner
            s_Ball_X_Prev <= c_Game_Width/2 + 1; 
            s_Ball_Y_Prev <= c_Game_Height/2 - 1;
            r_SM_Ball <= s_Two;
          when s_Two => -- Ball goes towards top right corner
            s_Ball_X_Prev <= c_Game_Width/2 - 1; 
            s_Ball_Y_Prev <= c_Game_Height/2 + 1;
            r_SM_Ball <= s_Three;
          when s_Three => -- Ball goes towards top left corner
            s_Ball_X_Prev <= c_Game_Width/2 + 1; 
            s_Ball_Y_Prev <= c_Game_Height/2 + 1;
            r_SM_Ball <= s_Four;
          when s_Four => -- Ball goes towards bottom right corner
            s_Ball_X_Prev <= c_Game_Width/2 - 1; 
            s_Ball_Y_Prev <= c_Game_Height/2 - 1;
            r_SM_Ball <= s_One;
        end case;
      else
        -- Update the ball counter.
        if s_Ball_Counter = c_Ball_Speed then
          s_Ball_Counter <= 0;
        else
          s_Ball_Counter <= s_Ball_Counter + 1;
        end if;
        if s_Ball_Counter = c_Ball_Speed then -- X Position
          -- Store Previous Location
          s_Ball_X_Prev <= s_Ball_X;
          -- Ball is moving right.
          if s_Ball_X_Prev < s_Ball_X then
            if s_Ball_X = c_Game_Width-1 then -- Checking if there was collision.
              s_Ball_X <= s_Ball_X - 1;
            else
              s_Ball_X <= s_Ball_X + 1;
            end if;
          -- Ball is moving left.
          elsif s_Ball_X_Prev > s_Ball_X then
            if s_Ball_X = 0 then  -- Checking if there was collision.
              s_Ball_X <= s_Ball_X + 1;
            else
              s_Ball_X <= s_Ball_X - 1;
            end if;
          end if;
        end if;

        if s_Ball_Counter = c_Ball_Speed then
          -- Store Previous Location
          s_Ball_Y_Prev <= s_Ball_Y;
          -- Ball is moving up.
          if s_Ball_Y_Prev < s_Ball_Y then
            if s_Ball_Y = c_Game_Height-1 then -- Checking if there was collision.
              s_Ball_Y <= s_Ball_Y - 1;
            else
              s_Ball_Y <= s_Ball_Y + 1;
            end if;
          -- Ball is moving down.
          elsif s_Ball_Y_Prev > s_Ball_Y then
            if s_Ball_Y = 0 then -- Checking if there was collision.
              s_Ball_Y <= s_Ball_Y + 1;
            else
              s_Ball_Y <= s_Ball_Y - 1;
            end if;
          end if;
        end if;
      end if;                          
    end if;                           
  end process p_Move_Ball;

  -- Draws a ball.
  p_Draw_Ball : process (clk) is
  begin
    if rising_edge(clk) then
      if (s_Columns_Index = s_Ball_X and s_Rows_Index = s_Ball_Y) then
        s_Draw_Ball <= '1';
      else
        s_Draw_Ball <= '0';
      end if;
    end if;
  end process p_Draw_Ball;
 
  o_Draw_Ball <= s_Draw_Ball;
  o_Ball_X    <= std_logic_vector(to_unsigned(s_Ball_X, o_Ball_X'length));
  o_Ball_Y    <= std_logic_vector(to_unsigned(s_Ball_Y, o_Ball_Y'length));
   
end architecture rtl;