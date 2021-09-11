----------------------------------------------------------------------------------
-- Engineer: Filip Rydzewski (Wanils)
-- Create Date: 23.08.2021 19:00
-- Design Name: Pong_Game
-- Module Name: PLL_25M - rtl
-- Target Devices: Basys3 Board
-- Notes: Module responsible for chaning clock frequency from 100 MHz to 25 MHz
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;

entity PLL_25M is
    Port ( 
        clk     : in std_logic;
        rst     : in std_logic;
        PWRDWN  : in std_logic;
        clk25   : out std_logic;
        CLKOUT1 : out std_logic;
        CLKOUT2 : out std_logic;
        CLKOUT3 : out std_logic;
        CLKOUT4 : out std_logic;
        CLKOUT5 : out std_logic;
        LOCKED  : out std_logic);
end PLL_25M;

architecture rtl of PLL_25M is
    
    signal CLK_FEED : std_logic;
    signal clk_G    : std_logic;
    signal clk25_G  : std_logic;
begin

    
   -- PLLE2_BASE: Base Phase Locked Loop (PLL)
   --             Artix-7
   -- Xilinx HDL Language Template, version 2018.3

   PLLE2_BASE_inst : PLLE2_BASE
   generic map (
      BANDWIDTH => "OPTIMIZED",  -- OPTIMIZED, HIGH, LOW
      CLKFBOUT_MULT => 32,        -- Multiply value for all CLKOUT, (2-64)
      CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB, (-360.000-360.000).
      CLKIN1_PERIOD => 40.0,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
      CLKOUT0_DIVIDE => 128,
      CLKOUT1_DIVIDE => 32,
      CLKOUT2_DIVIDE => 32,
      CLKOUT3_DIVIDE => 32,
      CLKOUT4_DIVIDE => 32,
      CLKOUT5_DIVIDE => 32,
      -- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
      CLKOUT0_DUTY_CYCLE => 0.5,
      CLKOUT1_DUTY_CYCLE => 0.5,
      CLKOUT2_DUTY_CYCLE => 0.5,
      CLKOUT3_DUTY_CYCLE => 0.5,
      CLKOUT4_DUTY_CYCLE => 0.5,
      CLKOUT5_DUTY_CYCLE => 0.5,
      -- CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
      CLKOUT0_PHASE => 0.0,
      CLKOUT1_PHASE => 0.0,
      CLKOUT2_PHASE => 0.0,
      CLKOUT3_PHASE => 0.0,
      CLKOUT4_PHASE => 0.0,
      CLKOUT5_PHASE => 0.0,
      DIVCLK_DIVIDE => 1,        -- Master division value, (1-56)
      REF_JITTER1 => 0.0,        -- Reference input jitter in UI, (0.000-0.999).
      STARTUP_WAIT => "FALSE"    -- Delay DONE until PLL Locks, ("TRUE"/"FALSE")
   )
   port map (
      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
      CLKOUT0 => clk25_G,   -- 1-bit output: CLKOUT0
      CLKOUT1 => CLKOUT1,   -- 1-bit output: CLKOUT1
      CLKOUT2 => CLKOUT2,   -- 1-bit output: CLKOUT2
      CLKOUT3 => CLKOUT3,   -- 1-bit output: CLKOUT3
      CLKOUT4 => CLKOUT4,   -- 1-bit output: CLKOUT4
      CLKOUT5 => CLKOUT5,   -- 1-bit output: CLKOUT5
      -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
      CLKFBOUT => CLK_FEED, -- 1-bit output: Feedback clock
      LOCKED => LOCKED,     -- 1-bit output: LOCK
      CLKIN1 => clk_G,     -- 1-bit input: Input clock
      -- Control Ports: 1-bit (each) input: PLL control ports
      PWRDWN => PWRDWN,     -- 1-bit input: Power-down
      RST => rst,           -- 1-bit input: Reset
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN => CLK_FEED    -- 1-bit input: Feedback clock
    );

   iBUFG_inst : BUFG
   port map (
      O => clk_G, -- 1-bit output: Clock output
      I => clk  -- 1-bit input: Clock input
   );

   BUFG_inst : BUFG
   port map (
      O => clk25, -- 1-bit output: Clock output
      I => clk25_G  -- 1-bit input: Clock input
   );

end rtl;
