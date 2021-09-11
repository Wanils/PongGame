----------------------------------------------------------------------------------
-- Engineer: Filip Rydzewski (Wanils)
-- Create Date: 11.09.2021 14:00
-- Design Name: Pong_Game
-- Module Name: Sync_to_count - rtl
-- Target Devices: Basys3 Board
-- Notes: Module based on the one created by Nandaland. It is designed for 640x480 
-- with a 25 MHz input clock. It is responsible for creating rows and columns
-- counters based on the input sync pulses.
-- Prefixes: g_ stands for Generic, o_ stands for Output signal, i_ stands for 
-- Input signal, s_ stands for Signal, c_ stands for constant, p_ stand for process.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Sync_To_Count is
  generic (
    g_Total_Columns : integer;
    g_Total_Rows    : integer);
  port (
    clk             : in std_logic;
    i_HSync         : in std_logic;
    i_VSync         : in std_logic;
    o_HSync         : out std_logic;
    o_VSync         : out std_logic;
    o_Col_Count     : out std_logic_vector(9 downto 0);
    o_Row_Count     : out std_logic_vector(9 downto 0));
end entity Sync_To_Count;

architecture rtl of Sync_To_Count is

  signal s_VSync         : std_logic := '0';
  signal s_Hsync         : std_logic := '0';
  signal s_FrameStart    : std_logic;
  signal s_Columns_Count : unsigned(9 downto 0) := (others => '0');
  signal s_Rows_Count    : unsigned(9 downto 0) := (others => '0');

begin

  p_Reg_Syncs : process (clk) is
  begin
    if rising_edge(clk) then
      s_VSync <= i_VSync;
      s_Hsync <= i_HSync;
    end if;
  end process p_Reg_Syncs; 

  -- Rows and columns counters
  p_Row_Col_Count : process (clk) is
  begin
    if rising_edge(clk) then
      if s_FrameStart  = '1' then -- Reset counters
        s_Columns_Count <= (others => '0');
        s_Rows_Count    <= (others => '0');
      else
        if s_Columns_Count = to_unsigned(g_Total_Columns-1, s_Columns_Count'length) then
          if s_Rows_Count = to_unsigned(g_Total_Rows-1, s_Rows_Count'length) then
            s_Rows_Count <= (others => '0');
          else
            s_Rows_Count <= s_Rows_Count + 1;
          end if;
          s_Columns_Count <= (others => '0');
        else
          s_Columns_Count <= s_Columns_Count + 1;
        end if;
      end if;
    end if;
  end process p_Row_Col_Count;
  
    
  -- Reset counters when found rising edge of Vertical Sync
  s_FrameStart  <= '1' when s_VSync = '0' and i_VSync = '1' else '0';
  o_VSync <= s_VSync;
  o_HSync <= s_Hsync;
  o_Row_Count <= std_logic_vector(s_Rows_Count);
  o_Col_Count <= std_logic_vector(s_Columns_Count);
  
end architecture rtl;
