----------------------------------------------------------------------------------
-- Engineer: Filip Rydzewski (Wanils)
-- Create Date: 11.09.2021 14:00
-- Design Name: Pong_Game
-- Module Name: Pong_Paddle - rtl
-- Target Devices: Basys3 Board
-- Notes: Module based on the one created by Nandaland. It is designed for 640x480 
-- with a 25 MHz input clock. It is responsible for paddle movement and its drawing.
-- Prefixes: g_ stands for Generic, o_ stands for Output signal, i_ stands for 
-- Input signal, s_ stands for Signal, c_ stands for constant, p_ stand for process.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.PONG_PKG.ALL;
 
entity Pong_Paddle is
  generic (
    g_Player_Paddle_X   : integer);
  port (
    clk                 : in std_logic;
    i_Columns_Count_Div : in std_logic_vector(5 downto 0);
    i_Rows_Count_Div    : in std_logic_vector(5 downto 0);
    -- Player Paddle Control
    i_Paddle_Move       : in std_logic;
    i_Paddle_Lock       : in std_logic;
    o_Draw_Paddle       : out std_logic;
    o_Paddle_Y          : out std_logic_vector(5 downto 0));
end entity Pong_Paddle;
 
architecture rtl of Pong_Paddle is
 
  -- Integer representation of the above counters -> way easier to work with
  signal s_Columns_Index     : integer range 0 to 2**i_Columns_Count_Div'length := 0;
  signal s_Rows_Index        : integer range 0 to 2**i_Rows_Count_Div'length := 0;
  signal s_Paddle_Counter_EN : std_logic;
  signal s_Paddle_Counter    : integer range 0 to c_Paddle_Speed := 0;
  -- Start Location of Paddles - Middle
  signal s_Paddle_Y          : integer range 0 to c_Game_Height-c_Paddle_Height-1 := c_Game_Height/2;
  signal s_Draw_Paddle       : std_logic := '0';
   
begin
 
  s_Columns_Index <= to_integer(unsigned(i_Columns_Count_Div));
  s_Rows_Index    <= to_integer(unsigned(i_Rows_Count_Div));  
 
  -- Only allow paddles to move if i_Paddle_Lock is low
  s_Paddle_Counter_EN <= not i_Paddle_Lock;
 
  -- Controls how the paddles are moved. Sets s_Paddle_Y.
  p_Move_Paddles : process (clk) is
  begin
    if rising_edge(clk) then
      -- Update the paddle counter when either switch is up or down while i_Paddle_Lock is low.
      if s_Paddle_Counter_EN = '1' then
        if s_Paddle_Counter = c_Paddle_Speed then
          s_Paddle_Counter <= 0;
        else
          s_Paddle_Counter <= s_Paddle_Counter + 1;
        end if;
      else
        s_Paddle_Counter <= 0;
      end if;
      -- Update the Paddle when Paddle Counter reaches its limit
      if (i_Paddle_Move = '1' and s_Paddle_Counter = c_Paddle_Speed) then
        -- If Paddle is already at the top, do not update it
        if s_Paddle_Y /= 0 then
          s_Paddle_Y <= s_Paddle_Y - 1;
        end if;
      elsif (i_Paddle_Move = '0' and s_Paddle_Counter = c_Paddle_Speed) then
        -- If Paddle is already at the bottom, do not update it
        if s_Paddle_Y /= c_Game_Height-c_Paddle_Height-1 then
          s_Paddle_Y <= s_Paddle_Y + 1;
        end if;
      end if;
    end if;
  end process p_Move_Paddles;
 
   
  -- Draws the Paddles
  p_Draw_Paddles : process (clk) is
  begin
    if rising_edge(clk) then
      -- Draws in a single column and in a range of rows.
      -- Range of rows is determined by c_Paddle_Height
      if (s_Columns_Index = g_Player_Paddle_X and
          s_Rows_Index >= s_Paddle_Y and
          s_Rows_Index <= s_Paddle_Y + c_Paddle_Height) then
          s_Draw_Paddle <= '1';
      else
          s_Draw_Paddle <= '0';
      end if;
    end if;
  end process p_Draw_Paddles;
 
  o_Draw_Paddle <= s_Draw_Paddle;
  o_Paddle_Y    <= std_logic_vector(to_unsigned(s_Paddle_Y, o_Paddle_Y'length));
   
end architecture rtl;