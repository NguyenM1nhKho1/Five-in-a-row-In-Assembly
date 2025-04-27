.data
player1_input: .asciiz "Player 1, please input your coordinates (x,y): "
player2_input: .asciiz "Player 2, please imput your coordinates (x,y): "
incorrect_format: .asciiz "Incorrect input format! Please try again.\n"
player1_win: .asciiz "Player 1 wins!\n"
player2_win: .asciiz "Player 2 wins!\n"
out_of_range: .asciiz "Input must be in range of 0 and 14!\n"
wrong_input: .asciiz "Wrong input format, please try again\n"
already_input: .asciiz "Player 1 already used this coordinates!\n"
already_taken: .asciiz "This space is already occupied!\n"
tie_msg: .asciiz "Tie\n"
the_board: .space 225
input_buffer: .space 20
nl: .asciiz "\n"
comma: .byte ','
result_file: .asciiz "result.txt"
char_buf: .space 1

.text

#--------initialize the board-----------#

main:
	la $t0, the_board
	li $t1, 225
	li $t2, '.'
	
	li $t3, 0
	
init_loop:
	beq $t3, $t1, init_done
	
	sb $t2, 0($t0)
	addi $t0, $t0, 1
	addi $t3, $t3, 1
	j init_loop

#----------Display the board--------------#

init_done:
	la $t0, the_board
	li $t1, 0
	
print_loop:
	beq $t1, 225, print_done
	
	lb $a0, 0($t0)
	li $v0, 11
	syscall
	
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	
	rem $t2, $t1, 15
	bnez $t2, skip_newline
	
	la $a0, nl
	li $v0, 4
	syscall

skip_newline:
	j print_loop

#-------Display Current board----#
go_back:
	jr $ra
load_board:
	la $t0, the_board
	li $t1, 0
	
display_loop:
	beq $t1, 225, go_back
	
	lb $a0, 0($t0)
	li $v0, 11
	syscall
	
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	
	rem $t2, $t1, 15
	bnez $t2, skip_newline_1
	
	la $a0, nl
	li $v0, 4
	syscall

skip_newline_1:
	j display_loop

#---------Gameplay Loop---------#

print_done:
player1_turn:
player1_retry:
	jal player1_coor
	jal mark_X
	jal load_board
	jal check_win_X
player2_turn:
player2_retry:
	jal player2_coor
	jal mark_O
	jal load_board
	jal check_win_O
win_con:
	jal tie_check
	j print_done
	
#--------Player 1 Coordinates--------#

player1_coor:
	la $a0, player1_input
	li $v0, 4
	syscall
	
	#TODO: take coordinates of player 1 (in the format of "x,y")
	la $a0, input_buffer
	li $a1, 20
	li $v0, 8
	syscall
	
	la $t1, input_buffer
	li $t2, 0			#t2 = x

parse_x_p1:
	lb $t3, 0($t1)
	beq $t3, 44, parse_y_p1		#44 = ','
	beq $t3, 10, wrong_format_p1	#10 = 'newline'
	blt $t3, 48, wrong_format_p1 	#not a digit
	bgt $t3, 57, wrong_format_p1	#not a digit
	subu $t3, $t3, 48		#convert char to int
	mul $t2, $t2, 10
	add $t2, $t2, $t3
	addiu $t1, $t1, 1
	j parse_x_p1

parse_y_p1:
	addiu $t1, $t1, 1		#skip comma
	li $t4, 0			#t4 = y
parse_y_p1_loop:
	lb $t3, 0($t1)
	beqz $t3, input_done_p1
	beq $t3, 10, input_done_p1
	blt $t3, 48, wrong_format_p1
	bgt $t3, 57, wrong_format_p1
	subu $t3, $t3, 48
	mul $t4, $t4, 10
	add $t4, $t4, $t3
	addiu $t1, $t1, 1
	j parse_y_p1_loop

input_done_p1:
	blt $t2, 0, out_of_range_p1
	bgt $t2, 14, out_of_range_p1
	blt $t4, 0, out_of_range_p1	
	bgt $t4, 14, out_of_range_p1
	
	move $s0, $t2	#save coordinates for board
	move $s1, $t4	#s0 = x, s1 = y
	
	jr $ra
	
out_of_range_p1:
	la $a0, out_of_range
	li $v0, 4
	syscall
	
	j player1_coor
	
wrong_format_p1:
	la $a0, incorrect_format
	li $v0, 4
	syscall
	
	j player1_coor	
	
#---------Player 2 Coordinates--------#

player2_coor:
	la $a0, player2_input
	li $v0, 4
	syscall
	
	la $a0, input_buffer
	li $a1, 20
	li $v0, 8
	syscall
	
	la $t1, input_buffer
	li $t2, 0
	
parse_x_p2:
	lb $t3, 0($t1)
	beq $t3, 44, parse_y_p2		#44 = ','
	beq $t3, 10, wrong_format_p2	#10 = 'newline'
	blt $t3, 48, wrong_format_p2 	#not a digit
	bgt $t3, 57, wrong_format_p2	#not a digit
	subu $t3, $t3, 48		#convert char to int
	mul $t2, $t2, 10
	add $t2, $t2, $t3
	addiu $t1, $t1, 1
	j parse_x_p2

parse_y_p2:
	addiu $t1, $t1, 1		#skip comma
	li $t4, 0			#t4 = y
parse_y_p2_loop:
	lb $t3, 0($t1)
	beqz $t3, input_done_p2
	beq $t3, 10, input_done_p2
	blt $t3, 48, wrong_format_p2
	bgt $t3, 57, wrong_format_p2
	subu $t3, $t3, 48
	mul $t4, $t4, 10
	add $t4, $t4, $t3
	addiu $t1, $t1, 1
	j parse_y_p2_loop

input_done_p2:
	beq $t2, $s0, check_p2_col
	j final_input_p2
check_p2_col:
	beq $t4, $s1, coor_already_inputted
final_input_p2:
	blt $t2, 0, out_of_range_p2
	bgt $t2, 14, out_of_range_p2
	blt $t4, 0, out_of_range_p2
	bgt $t4, 14, out_of_range_p2
	
	move $s0, $t2	#save coordinates for board
	move $s1, $t4	#s0 = x, s1 = y

	jr $ra

out_of_range_p2:
	la $a0, out_of_range
	li $v0, 4
	syscall
	
	j player1_coor
	
wrong_format_p2:
	la $a0, incorrect_format
	li $v0, 4
	syscall
	
	j player1_coor	
	
#------Same cooridinates (input)-------#	
	
coor_already_inputted:
	la $a0, already_input
	li $v0, 4
	syscall
	
	j player2_coor

#------Mark X on the board----------#

mark_X:
	la $t0, the_board
	mul $t1, $s0, 15 	# x (row)
	add $t1, $t1, $s1	# y (column)
	li $t3, 0
mark_X_loop:
	beq $t3, $t1, mark_X_store
	addi $t0, $t0, 1
	addi $t3, $t3, 1
	j mark_X_loop
mark_X_store:
	li $t5, '.'
	lb $t6, 0($t0)
	bne $t5, $t6, space_taken_p1
	li $t2, 'X'
	sb $t2, 0($t0)
	jr $ra

#------In case of occupied square-----#

space_taken_p1:
	la $a0, already_taken
	li $v0, 4
	syscall
	
	j player1_retry
	
#--------Mark O on the board--------#
	
mark_O:
	la $t0, the_board
	mul $t1, $s0, 15 
	add $t1, $t1, $s1	# y
	li $t3, 0
mark_O_loop:
	beq $t3, $t1, mark_O_store
	addi $t0, $t0, 1
	addi $t3, $t3, 1
	j mark_O_loop
mark_O_store:
	li $t5, '.'
	lb $t6, 0($t0)
	bne $t5, $t6, space_taken_p2
	li $t2, 'O'
	sb $t2, 0($t0)
	jr $ra
	
#------In case of occupied square-----#

space_taken_p2:
	la $a0, already_taken
	li $v0, 4
	syscall
	
	j player2_retry
	
#--------Check win condition---------#
	
check_win_X:
	li $t4, 'X'
	la $a0, player1_win
	j check_win_condition
	
check_win_O:
	li $t4, 'O'
	la $a0, player2_win
	j check_win_condition
	
check_win_condition:
	mul $t0, $s0, 15
	add $t0, $t0, $s1
	la $t1, the_board
	add $t0, $t0, $t1	# t2 = &the_board[x*15 + y]
	
	# horizontal check
	li $t5, 1		# count = 1
	move $t6, $t0		# index for left
	move $t7, $s1		# y for left

#------------Horizontal------------#
check_left:
	beqz $t7, check_right
	addi $t7, $t7, -1
	addi $t6, $t6, -1
	lb $t9, 0($t6)
	bne $t9, $t4, check_right
	addi $t5, $t5, 1
	beq $t5, 5, win_check_done
	j check_left
check_right:
	move $t7, $s1
	move $t6, $t0
check_right_loop:
	addi $t7, $t7, 1
	bgt $t7, 14, check_vertical
	addi $t6, $t6, 1
	lb $t9, 0($t6)
	bne $t9, $t4, check_vertical
	addi $t5, $t5, 1
	beq $t5, 5, win_check_done
	j check_right_loop

#------------Vertical------------#

check_vertical:
	li $t5, 1
	move $t7, $s0
	move $t6, $t0
check_up:
	beqz $t7, check_down
	addi $t6, $t6, -15		# move up
	addi $t7, $t7, -1
	lb $t9, 0($t6)
	bne $t9, $t4, check_down
	addi $t5, $t5, 1
	beq $t5, 5, win_check_done
	j check_up
check_down:
	move $t7, $s0
	move $t6, $t0
check_down_loop:
	addi $t7, $t7, 1
	bgt $t7, 14, check_diag1
	addi $t6, $t6, 15
	lb $t9, 0($t6)
	bne $t9, $t4, check_diag1
	addi $t5, $t5, 1
	beq $t5, 5, win_check_done
	j check_down_loop

#------------Diagonal (top-left to bottom-right)------------#

check_diag1:	# offset = +- 16, top left to bottom right
	li $t5, 1
	move $t7, $s0
	move $t8, $s1
	move $t6, $t0
diag1_up:
	or $t9, $t7, $t8
	beqz $t9, diag1_down
	addi $t7, $t7, -1
	addi $t8, $t8, -1
	bltz $t7, diag1_down
	bltz $t8, diag1_down
	addi $t6, $t6, -16
	lb $t9, 0($t6)
	bne $t9, $t4, diag1_down
	addi $t5, $t5, 1
	beq $t5, 5, win_check_done
	j diag1_up
	
diag1_down:
	move $t7, $s0
	move $t8, $s1
	move $t6, $t0
diag1_down_loop:
	addi $t7, $t7, 1
	addi $t9, $t8, 1
	bgt $t7, 14, check_diag2
	bgt $t8, 14, check_diag2
	addi $t6, $t6, 16
	lb $t9, 0($t6)
	bne $t9, $t4, check_diag2
	addi $t5, $t5, 1
	beq $t5, 5, win_check_done
	j diag1_down_loop
	
#------------Diagonal (top-right to bottom left)------------#

check_diag2: 	#offset = +- 14, Top right to Bottom left
	li $t5, 1
	move $t7, $s0
	move $t8, $s1
	move $t6, $t0

diag2_up:
	addi $t7, $t7, -1
	addi $t8, $t8, 1
	bltz $t7, diag2_down
	bgt $t8, 14, diag2_down
	addi $t6, $t6, -14
	lb $t9, 0($t6)
	bne $t9, $t4, diag2_down
	addi $t5, $t5, 1
	beq $t5, 5, win_check_done
	j diag2_up

diag2_down:
	move $t7, $s0
	move $t8, $s1
	move $t6, $t0
diag2_down_loop:
	addi $t7, $t7, 1
	addi $t8, $t8, -1
	bgt $t7, 14, win_check_done
	bltz $t8, win_check_done
	addi $t6, $t6, 14
	lb $t9, 0($t6)
	bne $t9, $t4, win_check_done
	addi $t5, $t5, 1
	beq $t5, 5, win_check_done
	j diag2_down_loop
	
win_check_done:
	li $t9, 5
	bge $t5, $t9, win_player
	jr $ra
win_player:
	li $v0, 4
	syscall
	move $s4, $a0
	j print_file
	
#----------Check tie condition----------#	
	
tie_check:
	la $t0, the_board
	li $t1, 0
	li $t2, 225
tie_check_loop:
	beq $t1, $t2, tie_output
	lb $t3, 0($t0)
	li $t4, '.'
	beq $t3, $t4, go_back	# not a tie
	addi $t1, $t1, 1
	addi $t0, $t0, 1
	j tie_check_loop
tie_output:
	la $a0, tie_msg
	li $v0, 4
	syscall
	move $s4, $a0
	j print_file
	
#------------Print into file---------#
print_file:
	# Open file (write)
	li $v0, 13
	la $a0, result_file
	li $a1, 1
	li $a2, 0
	syscall
	move $t8, $v0
	
grab_the_board:
	la $t0, the_board
	li $t1, 0
	
board_to_file_loop:
	beq $t1, 225, done_writing_board
	
	lb $t3, 0($t0)
	sb $t3, char_buf	#store the element into a buffer
	
	li $v0, 15
	move $a0, $t8
	la $a1, char_buf
	li $a2, 1
	syscall
	
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	
	rem $t2, $t1, 15
	bnez $t2, skip_newline_file
	
	li $v0, 15			# print newline to simulate a 15x15 visual
	move $a0, $t8
	la $a1, nl
	la $a2, 1
	syscall

skip_newline_file:
	j board_to_file_loop

done_writing_board:		# write the final message (win or tie)
	li $v0, 15
	move $a0, $t8
	la $a1, nl
	la $a2, 1
	syscall
	
	li $v0, 15
	move $a0, $t8
	move $a1, $s4
	move $t0, $a1
	jal get_string_length
	move $a2, $v1
	syscall
	
	li $v0, 16		# close the file
	move $a0, $t8
	syscall
	
	li $v0, 10
	syscall

get_string_length:
	li $v1, 0
	loop:
		lb   $t9, 0($t0)    # Load byte from string
        	beq  $t9, $zero, done # If byte is null terminator (0), break loop
        	addi $v1, $v1, 1     # Increment length counter
        	addi $t0, $t0, 1     # Move to the next character
        	j loop               # Repeat the loop

    	done:
       	 	jr   $ra              # Return to caller
