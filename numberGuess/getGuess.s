# ***
# Eliza Poland
# ***
	.data 
empty_str:	.asciiz ""
invalid_str:	.asciiz "Input is invalid"
quit:		.byte 'q'
buffer:		.space 100
bufferend:
	
	.text
	.globl getGuess
getGuess:
	addiu $sp,$sp,-128
	sw $ra,124($sp)
	sw $s0,120($sp)	# save $s0, use to store guess
	
	# Home a-registers:
	sw $a0,128($sp)	# Store question
	sw $a1,132($sp)	# Store low
	sw $a2,136($sp)	# Store high
	
	# 4 bytes reserved at 16($sp) for axtoi conversion
        # Char buffer[96] starts at 20($sp)
        
getting_input:
	li $s0,-1	# set guess = -1;
	
	# Load question, buffer, and then get input
	lw $a0,128($sp)
     	la $a1,20($sp)
   	li $a2,100
   	jal InputDialogString

	lb $t0,20($sp)		# load byte at beginning of buffer into $t0
	lb $t1,quit		# load 'q' into $t1
	beq $t0,$t1,valid_input	# if (buffer[0] == quit) goto valid_input;
	
	# Convert input string on buffer into a hex digit
	la $a0,16($sp)
	la $a1,20($sp)
	jal axtoi
	lw $s0,16($sp)		# Our guess in now saved at 16($sp)


	lw $t0,132($sp)		# load low
	lw $t1,136($sp)		# load high
	bgt $s0,$t1,out_of_bounds	# if (guess > high) goto out_of_bounds;
	blt $s0,$t0,out_of_bounds	# if (guess < low) goto out_of_bounds;
	
	j valid_input

out_of_bounds:
	# Load and display error messages, then return to loop
        la $a0,invalid_str
        la $a1,empty_str
        jal MessageDialogString
        j getting_input

valid_input:
        move $v0,$s0	# Save guess in $v0
        
        # Restore stack and return
        lw $s0,120($sp)
        lw $ra,124($sp)
        addiu $sp,$sp,128
        jr $ra
        

