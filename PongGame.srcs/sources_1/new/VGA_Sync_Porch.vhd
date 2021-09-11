----------------------------------------------------------------------------------
-- Engineer: Filip Rydzewski (Wanils)
-- Create Date: 11.09.2021 14:00
-- Design Name: Pong_Game
-- Module Name: VGA_Sync_Porch - rtl
-- Target Devices: Basys3 Board
-- Notes: Module based on the one created by Nandaland. It is designed for 640x480 
-- with a 25 MHz input clock. It is responsible for modyfying the input HSync and
-- VSync signals to include some time for Front and Back porch.
-- Prefixes: g_ stands for Generic, o_ stands for Output signal, i_ stands for 
-- Input signal, s_ stands for Signal, c_ stands for constant, p_ stand for process.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA_Sync_Porch is
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
    i_Red_Video      : in std_logic_vector(g_Video_Width-1 downto 0);
    i_Grn_Video      : in std_logic_vector(g_Video_Width-1 downto 0);
    i_Blu_Video      : in std_logic_vector(g_Video_Width-1 downto 0);
    o_HSync          : out std_logic;
    o_VSync          : out std_logic;
    o_Red_Video      : out std_logic_vector(g_Video_Width-1 downto 0);
    o_Grn_Video      : out std_logic_vector(g_Video_Width-1 downto 0);
    o_Blu_Video      : out std_logic_vector(g_Video_Width-1 downto 0)    );
end entity VGA_Sync_Porch;

architecture rtl of VGA_Sync_Porch is

  -- Below constants may differ depending on the monitor. The best way is to
  -- experiment with these numbers and see if the screen is alligned correctly.
  constant c_H_Front_Porch : integer := 18;
  constant c_H_Back_Porch  : integer := 50;
  constant c_V_Front_Porch : integer := 10;
  constant c_V_Back_Porch  : integer := 33;  
  signal s_HSync           : std_logic;
  signal s_VSync           : std_logic;
  signal s_HSync_2         : std_logic := '0';
  signal s_VSync_2         : std_logic := '0';
  signal s_Columns_Count   : std_logic_vector(9 downto 0);
  signal s_Rows_Count      : std_logic_vector(9 downto 0);
  
begin

  Sync_To_Count_Porch_Mod : entity work.Sync_To_Count
    generic map (
      g_Total_Columns => g_Total_Columns,
      g_Total_Rows => g_Total_Rows)
    port map (
      clk         => clk,
      i_HSync     => i_HSync,
      i_VSync     => i_VSync,
      o_HSync     => s_HSync,
      o_VSync     => s_VSync,
      o_Col_Count => s_Columns_Count,
      o_Row_Count => s_Rows_Count);
	  
  p_Add_Porch : process (clk) is
  begin
    if rising_edge(clk) then
      if (to_integer(unsigned(s_Columns_Count)) < c_H_Front_Porch + g_Active_Columns or 
          to_integer(unsigned(s_Columns_Count)) > g_Total_Columns - c_H_Back_Porch - 1) then
        s_HSync_2 <= '1';
      else
        s_HSync_2 <= s_HSync;
      end if;

      if (to_integer(unsigned(s_Rows_Count)) < c_V_Front_Porch + g_Active_Rows or
          to_integer(unsigned(s_Rows_Count)) > g_Total_Rows - c_V_Back_Porch - 1) then
        s_VSync_2 <= '1';
      else
        s_VSync_2 <= s_VSync;
      end if;
    end if;
  end process p_Add_Porch;

  o_HSync <= s_HSync_2;
  o_VSync <= s_VSync_2;
  o_Red_Video <= i_Red_Video;
  o_Grn_Video <= i_Grn_Video;
  o_Blu_Video <= i_Blu_Video;
  
end architecture rtl;
