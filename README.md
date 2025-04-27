Five in a row

This is an implementation of the game "Caro", otherwise known as Vietnamese Gomoku in MIPS Assembly.

How it works:
The rules of the game have been modified for the sake of simplicity in Assembly, the gameplay flow is as follows:
- The game is played on a 15x15 board, which translates to a 255 bytes array in Assembly. Each element will be a character, with the size of 1 byte.
- 2 players (each representing 'X' and 'O', respectively) will enter their coordinates in the format of x,y with comma as the seperator, to determine the position of their piece on the board
- The game ends when one of two conditions are satisfied:
  - A player gets 5 pieces in a line (either horizontally, vertically, or diagonally), resulting in a win
  - The board is filled but none of the players found the win condition, resulting in a tie.
- Repeat step 1 until all of the squares on the board is played.

  References:
  Gomoku Wikipedia: https://en.wikipedia.org/wiki/Gomoku
  
