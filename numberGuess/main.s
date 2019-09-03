# ***
# Eliza Poland
# ***
	.data
max:		.word 100  # Max value for the random number generator

str1:		.asciiz "Guess must be between 1 and 0x"
str3:		.asciiz "\nEnter your guess (q to quit): "
low_str:	.asciiz "Too low!"
high_str:	.asciiz "Too high!"
correct_str:	.asciiz "You got it!"
empty_str:	.asciiz ""

	.text
	.globl main
main:
	addiu $sp,$sp,-52
	sw $ra,48($sp)
	
	# Save s-registers
	sw $s0,44($sp)	# save $s0, use to store question
	sw $s1,40($sp)	# save $s1, use to store low
	sw $s2,36($sp)	# save $s2, use to store high
	sw $s3,32($sp)	# save $s3, use to store secretNum
	sw $s4,28($sp)	# save $s4, use to store guess
	
	# Give 12 bytes on stack to store the max value as a string
	# This string is stored starting at 16($sp)
	
	# Convert our maximum number (stored as string) into a hex value
	lw $a0,max
	la $a1,16($sp)
	jal itoax
	
	li $s1,1	# low
        lw $s2,max	# high
	
        # char* question = createQuestion(str1, str2, str3);
        la $a0,str1
        la $a1,16($sp)
        la $a2,str3
        jal createQuestion
        move $s0,$v0
        
        jal initRandom	# initRandom();
        move $a0,$s1
        move $a1,$s2
        jal randomIntRange	# int secretNum = randomIntRange(low, high); 
	move $s3,$v0
	
	# *** uncomment to display the secret number! ***
	#la $a0,empty_str
	#move $a1,$s3
	#jal MessageDialogInt
	

still_guessing:
	move $a0,$s0
	move $a1,$s1
	move $a2,$s2
	jal getGuess	# guess = getGuess(question, low, high);
	move $s4,$v0
	
	#la $a0,empty_str
	#move $a1,$s4
	#jal MessageDialogInt
	
	blt $s4,$zero,done_guessing	#if (guess < 0) goto done_guessing;
        blt $s4,$s3,too_low		#if (guess < secretNum) goto too_low
        bgt $s4,$s3,too_high		#if (guess > secretNum) goto too_high
        beq $s4,$s3,correct		#if (guess == secretNum) goto correct;
        j correct

too_low:
	la $a0,low_str
	la $a1,empty_str
	jal MessageDialogString
	j still_guessing
	
too_high:
	la $a0,high_str
	la $a1,empty_str
	jal MessageDialogString
	j still_guessing
	
correct:
        la $a0,correct_str
	la $a1,empty_str
	jal MessageDialogString

done_guessing:

	# Restore s-registers
	lw $s0,44($sp)	# question
	lw $s1,40($sp)	# low
	lw $s2,36($sp)	# high
	lw $s3,32($sp)	# secretNum
	lw $s4,28($sp)	# guess
	
	lw $ra,48($sp)
	addiu $sp,$sp,52
	# jr $ra 	# Removing this in favor of exit syscall
	
	# Exit syscalll
	li $v0, 10
   	syscall

