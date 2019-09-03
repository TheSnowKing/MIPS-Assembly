# ***
# Eliza Poland
# ***
        .data
value:	.asciiz "Value: "

        .text
	.globl randomIntRange
randomIntRange:
        addiu $sp,$sp,-32
	sw $ra,28($sp)
	
	# Save s-registers
	sw $s0,24($sp)	# save $s0, use to store random value
	sw $s1,20($sp)	# save $s1, use to store low
	sw $s2,16($sp)	# save $s2, use to store high
		
	# Move args into s registers
	move $s1,$a0
	move $s2,$a1
	
	jal random	# int rand = random();
	move $s0,$v0
	
	# Use $t0 to store the range that our random number will be in
	sub $t0,$s2,$s1	# int range = high - low;
	divu $s0,$t0	# rand = rand / range;
	mfhi $s0	# Move remainder of calculation into $s0
	add $s0,$s0,$s1	# rand = rand + low;
	move $v0,$s0
        
        # Restore s-registers
        lw $s0,24($sp)	
	lw $s1,20($sp)
	lw $s2,16($sp)
        
        lw $ra,28($sp)
	addiu $sp,$sp,32
	jr $ra
	
	
