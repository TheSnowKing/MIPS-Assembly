# ***
#
# Conor Poland
# Homework 5 - Guessing Game
# CS 270
#
# ***

#
#
# createQuestion.s
# implements a function to assemble a question string from three parts
#
#   char * createQuestion(char * first, char * second, char * third);
#
# allocates space for a new string on the heap large enough to hold the 
# question, then fills the space by copying first, second and third, creating
# the concatenated question.
#
#  char * createQuestion( char * first, char * second, char * third) {
    .text
    .globl createQuestion
createQuestion:
    addiu  $sp,$sp,-40
# home args
    sw  $a0,40($sp)
    sw  $a1,44($sp)
    sw  $a2,48($sp)
    sw  $ra,36($sp)
#  int len1, len2, len3, len ;
#  char * question;
    # question - $s0
    # len1 - $s1
    # len2 - $s2
    # len3 - $s3
    # len - $s4
    sw  $s4,32($sp)
    sw  $s3,28($sp)
    sw  $s2,24($sp)
    sw  $s1,20($sp)
    sw  $s0,16($sp)
#
#  TRANSLATE THE FOLLOWING C CODE TO MIPS ASSEMBLER:

    lw $a0,40($sp)
    jal strlen
    move $s1,$v0
    
    lw $a0,44($sp)
    jal strlen
    move $s2,$v0
    
    lw $a0,48($sp)
    jal strlen
    move $s3,$v0
    
    # get len into $s4
    add $s4,$s1,$s2
    add $s4,$s4,$s3
    
    addi $s4,$s4,1	# extra byte for null terminator
    
    move $a0,$s4
    jal malloc		# question = malloc(len + 1);
    move $s0,$v0	# Move base address of memory to $s0
    
    move $a0,$s0
    lw $a1,40($sp)
    jal strcpy		# strcpy(question,first);
    
    add $a0,$s0,$s1
    lw $a1,44($sp)
    jal strcpy		# strcpy(question+len1, second);
    
    add $a0,$s0,$s1
    add $a0,$a0,$s2
    lw $a1,48($sp)
    jal strcpy		# strcpy(question+len1, second);

#
#  len1 = strlen(first);
#  len2 = strlen(second);
#  len3 = strlen(third);
#  len = len1 + len2 + len3;
# 
#  question = malloc(len + 1);
#  strcpy(question,first);
#  strcpy(question+len1, second);
#  strcpy(question+len1+len2,third);
#
#  return(question);
    move $v0,$s0
    lw  $s4,32($sp)
    lw  $s3,28($sp)
    lw  $s2,24($sp)
    lw  $s1,20($sp)
    lw  $s0,16($sp)
    lw  $ra,36($sp)
    addiu  $sp,$sp,40
    jr  $ra
# }
