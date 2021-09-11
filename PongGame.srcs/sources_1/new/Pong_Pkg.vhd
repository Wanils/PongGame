----------------------------------------------------------------------------------
-- Engineer: Filip Rydzewski (Wanils)
-- Create Date: 11.09.2021 14:00
-- Design Name: Pong_Game
-- Module Name: Pong_Pkg - library
-- Target Devices: Basys3 Board
-- Notes: Module based on the one created by Nandaland. It consists of constants
-- that can be changed to modify how the game works.
-- Prefixes: c_ stands for constant.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
package Pong_Pkg is
-----------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------
  -- Set the Width and Height of the Game Board
  constant c_Game_Width    : integer := 40;
  constant c_Game_Height   : integer := 30;
  -- Set the number of points to play to
  constant c_Score_Limit : integer := 9;
  -- Set the Height (in board game units) of the paddle.
  constant c_Paddle_Height : integer := 6;
  -- Set the Speed of the paddle movement.  In this case, the paddle will move
  -- one board game unit every 50 milliseconds that the button is held down.
  constant c_Paddle_Speed : integer := 1250000;
  -- Set the Speed of the ball movement.  In this case, the ball will move
  -- one board game unit every 50 milliseconds that the button is held down.   
  constant c_Ball_Speed : integer  := 1250000;
  -- Sets Column index to draw Player 1 & Player 2 Paddles.
  constant c_Paddle_Col_Location_P1 : integer := 0;
  constant c_Paddle_Col_Location_P2 : integer := c_Game_Width-1;
 
end package Pong_Pkg; 