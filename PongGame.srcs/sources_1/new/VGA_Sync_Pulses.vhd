----------------------------------------------------------------------------------
-- Engineer: Filip Rydzewski (Wanils)
-- Create Date: 11.09.2021 14:00
-- Design Name: Pong_Game
-- Module Name: VGA_Sync_Pulses - rtl
-- Target Devices: Basys3 Board
-- Notes: Module based on the one created by Nandaland. It is designed for 640x480 
-- with a 25 MHz input clock. It is responsible for a proper HSync and VSync work.
-- Prefixes: g_ stands for Generic, o_ stands for Output signal, i_ stands for 
-- Input signal, s_ stands for Signal, c_ stands for constant, p_ stand for process.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA_Sync_Pulses is
  generic (
    g_Total_Columns  : integer;
    g_Total_Rows     : integer;
    g_Active_Columns : integer;
    g_Active_Rows    : integer);
  port (
    clk              : in  std_logic;
    o_HSync          : out std_logic;
    o_VSync          : out std_logic;
    o_Col_Count      : out std_logic_vector(9 downto 0);
    o_Row_Count      : out std_logic_vector(9 downto 0));
end entity VGA_Sync_Pulses;

architecture rtl of VGA_Sync_Pulses is

  signal s_Columns_Count : integer range 0 to g_Total_Columns-1 := 0;
  signal s_Rows_Count    : integer range 0 to g_Total_Rows-1 := 0;

begin

  Rows_and_Columns_count : process (clk) is
  begin
    if rising_edge(clk) then
      if s_Columns_Count = g_Total_Columns-1 then
        if s_Rows_Count = g_Total_Rows-1 then
          s_Rows_Count <= 0;
        else
          s_Rows_Count <= s_Rows_Count + 1;
        end if;
        s_Columns_Count <= 0;
      else
        s_Columns_Count <= s_Columns_Count + 1;
      end if;
    end if;
  end process Rows_and_Columns_count;

  o_HSync <= '1' when s_Columns_Count < g_Active_Columns else '0';
  o_VSync <= '1' when s_Rows_Count < g_Active_Rows else '0';

  o_Col_Count <= std_logic_vector(to_unsigned(s_Columns_Count, o_Col_Count'length));
  o_Row_Count <= std_logic_vector(to_unsigned(s_Rows_Count, o_Row_Count'length));
  
end architecture rtl;
