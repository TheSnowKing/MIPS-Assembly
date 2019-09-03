# ***
# Eliza Poland
# ***
	.text
	.globl initRandom
initRandom:
	addiu $sp,$sp,-20
	sw $ra,16($sp)
	
	move $a0,$zero
	jal time	#unsigned int curTime = time(NULL);

	move $a0,$v0
	jal srandom	#srand(curTime);
        
        lw $ra,16($sp)
	addiu $sp,$sp,20
	jr $ra
