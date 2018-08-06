# board.s ... Game of Life on a 10x10 grid

   .data

N: .word 15  # gives board dimensions

board:
   .byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0
   .byte 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
   .byte 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0
   .byte 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0
   .byte 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1
   .byte 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0
   .byte 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0
   .byte 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0
   .byte 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0
   .byte 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0
   .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1
   .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0
   .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0
   .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
   .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0

newBoard: .space 225
# prog.s ... Game of Life on a NxN grid
#
# Needs to be combined with board.s
# The value of N and the board data
#N: .word 15  # gives board dimensions

# structures come from board.s
#
# Written by Liangde Li z5077896, August 2017

    .data
    .align 2
main_ret_save: 
    .space 4
msg1: 
    .asciiz "# Iterations: "
msg2:
    .asciiz "=== After iteration "
msg3:
    .asciiz " ===\n"
live:
    .asciiz "#"
dead:
    .asciiz "."
end_line:
    .asciiz "\n"

   
    .text
    .globl main
main:
    sw   $ra, main_ret_save

# Your main program code goes here

    la $a0, msg1                  # printf("# Iterations: ");
    li $v0, 4
    syscall

    li $v0, 5                     # scanf("%d", &maxiters);
    syscall
    move $s0, $v0                 # store maxiters in $s0
    lw $s1, N                     # store N in $s1
    
    li $s2, 1                     # int n = 1 = $s2    
for_one:
    bgt $s2, $s0, end_main        # for n <= maxiters
    
    move $s3, $0                  # int i = 0 = $s3
for_two:
    bge $s3, $s1, end_for_two     # for i < N
    
    move $s4, $0                  # int j = 0 = $s4
for_three:
    bge $s4, $s1, end_for_three   # for j < N
    
    move $a0, $s3                 # $a0 = i
    move $a1, $s4                 # $a1 = j
    
    j neighbours                  # int nn = neighbours(i,j), $v0 = nn
end_neighbours:
    
    mul $t0, $s3, $s1             # $t0 = i * N
    add $t0, $t0, $s4             # $t0 = i * N + j
    lb  $v1, board($t0)           # $v1 = board[i][j]
    
    li $t1, 1                     # $t1 = 1

if_start:
    beqz $v1, dead_case

live_case:                        #if (board[i][j] == 1) 
    li $t2, 2
    li $t3, 3
    blt $v0, $t2, less_than_2  
    bgt $v0, $t3, great_than_3
    sb $t1, newBoard($t0)         # (nn ==2 || nn == 3), newBoard[i][j] == 1
    addi $s4, $s4, 1
    j for_three

less_than_2:                      # (nn < 2)
great_than_3:                     # (nn > 3)
    sb $0, newBoard($t0)          # newBoard[i][j] == 0
    addi $s4, $s4, 1
    j for_three
    
dead_case:
    li $t7, 3  
    beq $v0, $t7, nn_3
    sb $0, newBoard($t0)          # nn != 3, newboard[i][j] = 0
    addi $s4, $s4, 1
    j for_three        

nn_3:                             # if nn == 3, newboard[i][j] = 1
    sb $t1, newBoard($t0)           
    addi $s4, $s4, 1
    j for_three        
            
end_for_three:
    addi $s3, $s3, 1 
    j for_two
        
   
end_for_two:
    la $a0, msg2                  # printf("=== After iteration %d ===\n", n);
    li $v0, 4
    syscall
    move $a0, $s2
    li $v0, 1
    syscall
    la $a0, msg3                  
    li $v0, 4
    syscall
    
    j copyBackAndShow
end_copy:
    addi $s2, $s2, 1
    j for_one


end_main:                         # return 
   lw   $ra, main_ret_save
   jr   $ra








# The other functions go here
# i = $a0, j = $a1
neighbours:                       
    li $t0, 1
    li $t1, -1                    # x = -1
    move $t3, $s1                 # $t3 = N
    addi $t3, $t3, -1             # $t3 = N-1
    li $v0, 0                     # $v0 = nn = 0
    
loop1:
    bgt $t1, $t0, end_neighbours
    li $t2, -1                    # y = -1
loop2:
    bgt $t2, $t0, end_loop1
    add $t4, $a0, $t1             # $t4 = i+x
    add $t5, $a1, $t2             # $t5 = j+y
    bltz $t4, end_loop2           # if i+x < 0
    bgt $t4, $t3, end_loop2       # if i+x > N-1
    bltz $t5, end_loop2           # if j+y < 0
    bgt $t5, $t3, end_loop2       # if j+y > N-1
    beqz $t1, check_y             # if x == 0
    j do
check_y:
    beqz $t2, end_loop2           # if (x == 0 && y == 0)
do:
    mul $t6, $t4, $s1             # $t0 = i * N
    add $t6, $t6, $t5             # $t0 = i * N + j
    lb  $v1, board($t6)           # $v1 = board[i][j]
    li $t7, 1
    beq $v1, $t7, increment
    j end_loop2
increment:
    addi $v0, $v0, 1              # nn++
    
end_loop2:

    addi $t2, $t2, 1              # y++
    j loop2
    
end_loop1:
    addi $t1, $t1, 1              # x++
    j loop1







    
# $s1 = N
copyBackAndShow:
    li $t0, 0                     # i = 0
while1:
    beq $t0, $s1, end_copy
    li $t1, 0                     # j = 0
while2:
    beq $t1, $s1, end_while2
    
    mul $t2, $t0, $s1             # $t2 = i * N
    add $t2, $t2, $t1             # $t2 = i * N + j
    lb  $t3, newBoard($t2)        # $t3 = board[i][j]
    sb $t3, board($t2)            # board[i][j] = newboard[i][j]
    beqz $t3, case0
    la $a0, live                  # putchar('#');
    li $v0, 4
    syscall
    addi $t1, $t1, 1
    j while2
case0:
    la $a0, dead                  # putchar('.');
    li $v0, 4
    syscall
    addi $t1, $t1, 1
    j while2
    
end_while2:
    la $a0, end_line              # putchar('\n');
    li $v0, 4
    syscall
    addi $t0, $t0, 1
    j while1

