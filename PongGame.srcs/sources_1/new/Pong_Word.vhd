----------------------------------------------------------------------------------
-- Engineer: Filip Rydzewski (Wanils)
-- Create Date: 11.09.2021 14:00
-- Design Name: Pong_Game
-- Module Name: Pong_Words - rtl
-- Target Devices: Basys3 Board
-- Notes: Module designed for 640x480 with a 25 MHz input clock. It is responsible 
-- for drawing digits "3" - "2" - "1" as well as statement "P1 Wins" or "P2 Wins"
-- when one of the players reaches score limit and wins the game
-- Prefixes: g_ stands for Generic, o_ stands for Output signal, i_ stands for 
-- Input signal, s_ stands for Signal, c_ stands for constant, p_ stand for process.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.PONG_PKG.ALL;

entity Pong_Words is
port (
    clk                 : in  std_logic;
    i_Draw_State        : in  std_logic_vector(2 downto 0);
    i_Columns_Count_Div : in  std_logic_vector(5 downto 0);
    i_Rows_Count_Div    : in  std_logic_vector(5 downto 0);
    o_Draw_Word         : out std_logic);
end Pong_Words;

architecture rtl of Pong_Words is

  -- Integer representation of the above counters -> way easier to work with
  signal s_Columns_Index : integer range 0 to 2**i_Columns_Count_Div'length := 0;
  signal s_Rows_Index    : integer range 0 to 2**i_Rows_Count_Div'length := 0;
   
  -- X and Y location (Col, Row) for Pong Ball, also Previous Locations
  signal s_Draw_Word : std_logic := '0';

begin
    s_Columns_Index <= to_integer(unsigned(i_Columns_Count_Div));
    s_Rows_Index    <= to_integer(unsigned(i_Rows_Count_Div));
    
  p_Draw_Word : process (clk) is
  begin
    if rising_edge(clk) then
      case i_Draw_State is
        when "011" => -- Draw "3"
            if (((s_Rows_Index = 5 or s_Rows_Index = 7 or s_Rows_Index = 9) and (s_Columns_Index = 19 or s_Columns_Index = 20 or s_Columns_Index = 21)) 
            or ((s_Rows_Index = 6 or s_Rows_Index = 8) and s_Columns_Index = 21)) then
                s_Draw_Word <= '1';
            else
                s_Draw_Word <= '0';
            end if;
        when "010" => -- Draw "2"
            if (((s_Rows_Index = 5 or s_Rows_Index = 7 or s_Rows_Index = 9) and (s_Columns_Index = 19 or s_Columns_Index = 20 or s_Columns_Index = 21)) 
            or (s_Rows_Index = 6 and s_Columns_Index = 21) or (s_Rows_Index = 8 and s_Columns_Index = 19)) then
                s_Draw_Word <= '1';
            else
                s_Draw_Word <= '0';
            end if;
        when "001" => -- Draw "1"
            if ((s_Rows_Index = 5 or s_Rows_Index = 6 or s_Rows_Index = 7 or s_Rows_Index = 8 or s_Rows_Index = 9) and s_Columns_Index = 20) then
                s_Draw_Word <= '1';
            else
                s_Draw_Word <= '0';
            end if;
        when "100" => -- Draw "P1 WINS"
            if    ((s_Rows_Index = 5 and (s_Columns_Index = 7 or s_Columns_Index = 8 or s_Columns_Index = 9 or s_Columns_Index = 12 or s_Columns_Index = 15 or s_Columns_Index = 19 or s_Columns_Index = 21 or s_Columns_Index = 23 or s_Columns_Index = 27 or s_Columns_Index = 29 or s_Columns_Index = 30 or s_Columns_Index = 31)) 
                or (s_Rows_Index = 6 and (s_Columns_Index = 7 or s_Columns_Index = 9 or s_Columns_Index = 12 or s_Columns_Index = 15 or s_Columns_Index = 19 or s_Columns_Index = 21 or s_Columns_Index = 23 or s_Columns_Index = 24 or s_Columns_Index = 27 or s_Columns_Index = 29))
                or (s_Rows_Index = 7 and (s_Columns_Index = 7 or s_Columns_Index = 8 or s_Columns_Index = 9 or s_Columns_Index = 12 or s_Columns_Index = 15 or s_Columns_Index = 17 or s_Columns_Index = 19 or s_Columns_Index = 21 or s_Columns_Index = 23 or s_Columns_Index = 25 or s_Columns_Index = 27 or s_Columns_Index = 29 or s_Columns_Index = 30 or s_Columns_Index = 31))
                or (s_Rows_Index = 8 and (s_Columns_Index = 7 or s_Columns_Index = 12 or s_Columns_Index = 15 or s_Columns_Index = 16 or s_Columns_Index = 18 or s_Columns_Index = 19 or s_Columns_Index = 21 or s_Columns_Index = 23 or s_Columns_Index = 26 or s_Columns_Index = 27 or s_Columns_Index = 31))
                or (s_Rows_Index = 9 and (s_Columns_Index = 7 or s_Columns_Index = 12 or s_Columns_Index = 15 or s_Columns_Index = 19 or s_Columns_Index = 21 or s_Columns_Index = 23 or s_Columns_Index = 27 or s_Columns_Index = 29 or s_Columns_Index = 30 or s_Columns_Index = 31))) then
                s_Draw_Word <= '1';
            else 
                s_Draw_Word <= '0';
            end if;
        when "110" => -- Draw "P2 WINS"
            if    ((s_Rows_Index = 5 and (s_Columns_Index = 7 or s_Columns_Index = 8 or s_Columns_Index = 9  or s_Columns_Index = 11 or s_Columns_Index = 12  or s_Columns_Index = 13 or s_Columns_Index = 15 or s_Columns_Index = 19 or s_Columns_Index = 21 or s_Columns_Index = 23 or s_Columns_Index = 27 or s_Columns_Index = 29 or s_Columns_Index = 30 or s_Columns_Index = 31)) 
                or (s_Rows_Index = 6 and (s_Columns_Index = 7 or s_Columns_Index = 9 or s_Columns_Index = 13 or s_Columns_Index = 15 or s_Columns_Index = 19 or s_Columns_Index = 21 or s_Columns_Index = 23 or s_Columns_Index = 24 or s_Columns_Index = 27 or s_Columns_Index = 29))
                or (s_Rows_Index = 7 and (s_Columns_Index = 7 or s_Columns_Index = 8 or s_Columns_Index = 9 or s_Columns_Index = 11 or s_Columns_Index = 12  or s_Columns_Index = 13 or s_Columns_Index = 15 or s_Columns_Index = 17 or s_Columns_Index = 19 or s_Columns_Index = 21 or s_Columns_Index = 23 or s_Columns_Index = 25 or s_Columns_Index = 27 or s_Columns_Index = 29 or s_Columns_Index = 30 or s_Columns_Index = 31))
                or (s_Rows_Index = 8 and (s_Columns_Index = 7 or s_Columns_Index = 11 or s_Columns_Index = 15 or s_Columns_Index = 16 or s_Columns_Index = 18 or s_Columns_Index = 19 or s_Columns_Index = 21 or s_Columns_Index = 23 or s_Columns_Index = 26 or s_Columns_Index = 27 or s_Columns_Index = 31))
                or (s_Rows_Index = 9 and (s_Columns_Index = 7 or s_Columns_Index = 11 or s_Columns_Index = 12  or s_Columns_Index = 13 or s_Columns_Index = 15 or s_Columns_Index = 19 or s_Columns_Index = 21 or s_Columns_Index = 23 or s_Columns_Index = 27 or s_Columns_Index = 29 or s_Columns_Index = 30 or s_Columns_Index = 31))) then
                s_Draw_Word <= '1';
            else 
                s_Draw_Word <= '0';
            end if;
        when others => -- Draw nothing
            s_Draw_Word <= '0';
      end case;
    end if;
  end process p_Draw_Word;
 
  o_Draw_Word <= s_Draw_Word;

end rtl;