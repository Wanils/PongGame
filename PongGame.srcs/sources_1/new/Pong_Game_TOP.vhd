----------------------------------------------------------------------------------
-- Engineer: Filip Rydzewski (Wanils)
-- Create Date: 11.09.2021 14:00
-- Design Name: Pong_Game
-- Module Name: Pong_Game_TOP - rtl
-- Target Devices: Basys3 Board
-- Notes: Module based on the one created by Nandaland. It is designed for 640x480 
-- with a 25 MHz input clock.
-- Prefixes: g_ stands for Generic, o_ stands for Output signal, i_ stands for 
-- Input signal, s_ stands for Signal, c_ stands for constant, p_ stand for process.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
Library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
 
entity VGA_TOP is
  port (
    -- Main Clock (100 MHz)
    i_Clk          : in std_logic;
    -- Reset for PLL
    rst            : in std_logic;
    -- UART Data
    UART_RX        : in  std_logic;
    -- INPUT BUTTONS
    i_Switch_1     : in std_logic;
    i_Switch_2     : in std_logic;
    i_Switch_3     : in std_logic;
    i_Switch_4     : in std_logic;
    i_Button_Start : in std_logic;
    -- Reset for the Pong Game
    i_Button_RST   : in std_logic;
    -- 7 Segment display OUTPUTS
    display        : out std_logic_vector (6 downto 0);
    enable         : out std_logic_vector (3 downto 0);
    -- VGA OUTPUTS
    VGA_HSync      : out std_logic;
    VGA_VSync      : out std_logic;
    VGA_Red        : out std_logic_vector(3 downto 0);
    VGA_Blue       : out std_logic_vector(3 downto 0);
    VGA_Green      : out std_logic_vector(3 downto 0));
end VGA_TOP;
 
architecture rtl of VGA_TOP is
  -- UART signals
  signal UART_RX_VALID : std_logic;
  signal UART_RX_BYTE  : std_logic_vector(7 downto 0);
  -- PLL signals
  signal  PWRDWN  : std_logic := '0'; 
  signal  clk25   : std_logic;
  signal  CLKOUT1 : std_logic; 
  signal  CLKOUT2 : std_logic; 
  signal  CLKOUT3 : std_logic; 
  signal  CLKOUT4 : std_logic; 
  signal  CLKOUT5 : std_logic; 
  signal  LOCKED  : std_logic; 
  -- INPUT SIGNALS
  signal s_Switch_1     : std_logic;
  signal s_Switch_2     : std_logic;
  signal s_Switch_3     : std_logic;
  signal s_Switch_4     : std_logic;
  signal s_Button_Start : std_logic;
  signal s_Button_RST   : std_logic;
  -- VGA Constants to set Frame Size
  constant c_Video_Width    : integer := 4;
  constant c_Total_Columns  : integer := 800;
  constant c_Total_Rows     : integer := 525;
  constant c_Active_Columns : integer := 640;
  constant c_Active_Rows    : integer := 480;
  -- VGA Signals
  signal s_HSync_VGA        : std_logic;
  signal s_VSync_VGA        : std_logic;
  signal s_Red_Video_Porch  : std_logic_vector(c_Video_Width-1 downto 0);
  signal s_Grn_Video_Porch  : std_logic_vector(c_Video_Width-1 downto 0);
  signal s_Blue_Video_Porch : std_logic_vector(c_Video_Width-1 downto 0);
  signal s_HSync_Pong       : std_logic;
  signal s_VSync_Pong       : std_logic;
  signal s_Red_Video_Pong   : std_logic_vector(c_Video_Width-1 downto 0);
  signal s_Grn_Video_Pong   : std_logic_vector(c_Video_Width-1 downto 0);
  signal s_Blu_Video_Pong   : std_logic_vector(c_Video_Width-1 downto 0);


   
begin
----------------------------------------------------------------------------------
------------------------------MODULES INSTANTIATION-------------------------------
----------------------------------------------------------------------------------
-- UART Receive module
  UART_Recieve_Mod : entity work.UART_Receive
    generic map (
      Clock_Frequency => 25000000,
      UART_Baud_Rate  => 115200)
    port map (
      clk             => clk25,
      UART_RX         => UART_RX,
      UART_RX_VALID   => UART_RX_VALID,
      UART_RX_BYTE    => UART_RX_BYTE);
-- PLL module
  PLL_Mod : entity work.PLL_25M
    port map(
      clk     => i_Clk,
      rst     => rst,
      PWRDWN  => PWRDWN,
      clk25   => clk25,
      CLKOUT1 => CLKOUT1,
      CLKOUT2 => CLKOUT2,
      CLKOUT3 => CLKOUT3,
      CLKOUT4 => CLKOUT4,
      CLKOUT5 => CLKOUT5,
      LOCKED  => LOCKED);
-- Buttons and switches debouncing modules
  deb_switch_1 : entity work.Debounce
    port map(
      clk        => clk25,
      button_in  => i_Switch_1,
      button_out => s_Switch_1);
  deb_switch_2 : entity work.Debounce
    port map(
      clk        => clk25,
      button_in  => i_Switch_2,
      button_out => s_Switch_2);
  deb_switch_3 : entity work.Debounce
    port map(
      clk        => clk25,
      button_in  => i_Switch_3,
      button_out => s_Switch_3);
  deb_switch_4 : entity work.Debounce
    port map(
      clk        => clk25,
      button_in  => i_Switch_4,
      button_out => s_Switch_4);
  deb_button_Start : entity work.Debounce
    port map(
      clk        => clk25,
      button_in  => i_Button_Start,
      button_out => s_Button_Start);
  deb_button_Restart : entity work.Debounce
    port map(
      clk        => clk25,
      button_in  => i_Button_RST,
      button_out => s_Button_RST);
-- VGA Sync Pulses module
  VGA_Sync_Pulses_Mod : entity work.VGA_Sync_Pulses
    generic map (
      g_Total_Columns  => c_Total_Columns,
      g_Total_Rows     => c_Total_Rows,
      g_Active_Columns => c_Active_Columns,
      g_Active_Rows    => c_Active_Rows)
    port map (
      clk              => clk25,
      o_HSync          => s_HSync_VGA,
      o_VSync          => s_VSync_VGA,
      o_Col_Count      => open,
      o_Row_Count      => open);
-- Pong Top module
  Pong_Top_Mod: entity work.Pong_Top
    generic map (
      g_Video_Width    => c_Video_Width,
      g_Total_Columns  => c_Total_Columns, 
      g_Total_Rows     => c_Total_Rows, 
      g_Active_Columns => c_Active_Columns,
      g_Active_Rows    => c_Active_Rows) 
    port map (
      clk              => clk25,
      i_HSync          => s_HSync_VGA,
      i_VSync          => s_VSync_VGA,
      i_UART_RX        => UART_RX_BYTE,
      i_UART_DV        => UART_RX_VALID,
      i_Button_Start   => s_Button_Start,
      i_Button_RST     => s_Button_RST,
      i_Paddle_Move_P1 => s_Switch_1,
      i_Paddle_Lock_P1 => s_Switch_2,
      i_Paddle_Move_P2 => s_Switch_3,
      i_Paddle_Lock_P2 => s_Switch_4,
      display          => display,
      enable           => enable,
      o_HSync          => s_HSync_Pong,
      o_VSync          => s_VSync_Pong,
      o_Red_Video      => s_Red_Video_Pong,
      o_Blu_Video      => s_Blu_Video_Pong,
      o_Grn_Video      => s_Grn_Video_Pong);
-- VGA Sync Porch module
  VGA_Sync_Porch_Mod : entity work.VGA_Sync_Porch
    generic map (
      g_Video_Width    => c_Video_Width,
      g_Total_Columns  => c_Total_Columns,
      g_Total_Rows     => c_Total_Rows,
      g_Active_Columns => c_Active_Columns,
      g_Active_Rows    => c_Active_Rows)
    port map (
      clk              => clk25,
      i_HSync          => s_HSync_Pong,
      i_VSync          => s_VSync_Pong,
      i_Red_Video      => s_Red_Video_Pong,
      i_Grn_Video      => s_Blu_Video_Pong,
      i_Blu_Video      => s_Grn_Video_Pong,
      o_HSync          => VGA_HSync,
      o_VSync          => VGA_VSync,
      o_Red_Video      => s_Red_Video_Porch,
      o_Grn_Video      => s_Blue_Video_Porch,
      o_Blu_Video      => s_Grn_Video_Porch);
----------------------------------------------------------------------------------
-------------------------------SIGNALS ASSIGNMENT---------------------------------
----------------------------------------------------------------------------------
  VGA_Red   <= s_Red_Video_Porch;
  VGA_Blue  <= s_Blue_Video_Porch;
  VGA_Green <= s_Grn_Video_Porch;

end rtl;