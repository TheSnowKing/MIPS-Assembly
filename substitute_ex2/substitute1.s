#
# substitute1.s - substitute one character for another in a string
#  -- the syscalls have been translated to calls to functions 
#     in util.s
#
    .data
sprompt: .asciiz    "Enter string:"
oprompt: .asciiz    "Enter character you want to replace:"
nprompt: .asciiz    "Enter replacement character:"
resultmsg:  .asciiz "Resulting string:\n"
nsubsmsg:   .asciiz "Number of substitutions: "
    .text
    .globl  main
main:
    # we need a stack from with room for
    # - argument area (16 bytes)
    # - a 4-byte buffer for the 'orig' char (at 16($sp))
    # - a 4-byte buffer for the 'new' char (at 20($sp))
    # - a word for the 'number of substitutions' (nsubs) (at 24($sp))
    # - a 80-byte buffer (at 28($sp))
    # - the return address register (at 108($sp))
    # total: 112 bytes
    add     $sp,$sp,-112
    sw      $ra,108($sp)

# this program simply does one substitute call then exits, so we will 
# ignore the return value of InputDialogString (IDS)
#

    # call InputDialogString to get string
    # InputDialogString(sprompt,buffer,80);
    la      $a0,sprompt
    add     $a1,$sp,28
    li      $a2,80
    jal     InputDialogString

    # get original character
    # InputDialogString(oprompt,&orig,4);
    la      $a0,oprompt
    add     $a1,$sp,16
    li      $a2,4
    jal     InputDialogString

    # get replacement character
    # InputDialogString(nprompt,&new,4);
    la      $a0,nprompt
    add     $a1,$sp,20
    li      $a2,4
    jal     InputDialogString
    
    # now call substitute(buffer,orig,new)
    # - we simply extract the first character from the buffer for each char
    add     $a0,$sp,28
    lb      $a1,16($sp)
    lb      $a2,20($sp)
    jal     substitute
    # the number of substitutions is in $v0

    # now output the number of substitutions
    # MessageDialogInt(nsubsmsg,nsubs)
    la      $a0,nsubsmsg
    move    $a1,$v0         
    jal     MessageDialogInt

    # and output a message with the resultant string
    # MessageDialogString(resultmsg,buffer)
    la      $a0,resultmsg
    add     $a1,$sp,28
    jal     MessageDialogString

# unwind the stack and return
    lw      $ra,108($sp)
    add     $sp,$sp,112
    jr      $ra

#
# If you recall, I suggested the following for the original substitute.s:
# HINT: before you start, initialize the following registers:
# $a0 = address of the string
# $a1 = char to look for
# $a2 = char to replace with
# 
# If you did this, the code should be simple to change to a function!
#
#   int substitute(char *cptr, char orig, char new) ;
#
    .globl  substitute
substitute:
# put your code for substitute here. Don't forget to return!


    la $a0,28($sp)	# Load address of string to $a0
    lb $a1,16($sp)	# Load original char
    lb $a2,20($sp)	# Load new char
    
    li $v0,0		# Initalize numReplacements to zero  
    li $t0,0		# Counter i   
loop:
    # Get current char into $t2
    add $t1,$t0,$a0	# Add i to base address of string
    lb $t2,0($t1)	# Load current char into $t2
    
    # Determine if we are done
    beq $t2,$zero,done	# if (string[i] == 0) goto done
    addi $t0,$t0,1	# i++
    
    # Determine if a replacement must be made
    bne $t2,$a1,loop	# if (string[i] != orig) goto loop
    sb $a2,0($t1)	# string[i] = new
    addi $v0,$v0,1	# numReplacements++
    j loop		# goto loop
done:
    
    jr $ra


.include "/home/conor/Programs/Courses/cs270/util.s"
