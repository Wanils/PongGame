# PongGame
Pong Game written in VHDL Vivado for Basys 3 board. The design was based on the one created by Nandland for GO Board. It allows however to implement the same pong game on the basys 3 board using made in PLL module to lower the frequency from 100 MHz to 25 MHz. It also consist additions such as:
- random destination of the ball at the start of the game
- result shown on the 7 segment displays
- 3 second count down to the game start which is also shown on the screen
- post game screen showing which player have won
- changed control of the paddles -> 2 most left switches are for the player 1. The leftmost switch allows you to select the direction (up, down), and the second button locks the current position of the pad if its high. 2 most right switches are for the player 2 and do the same thing. The rightmost is for the direction and the second one is for locking the paddle position.
Design architecture:
!(https://github.com/Wanils/PongGame/blob/main/Pong_Architecture.drawio.png?raw=true)
