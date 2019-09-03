#
# Eliza Poland
# substitute.s - substitute one character for another in a string
#
    .data
string: .space 80
orig:   .space 1
new:    .space 1
sprompt: .asciiz    "Enter string:"
oprompt: .asciiz    "Enter character you want to replace:"
nprompt: .asciiz    "Enter replacement character:"
rprompt: .asciiz    "The string with replacements: "
cprompt: .asciiz    "Number of replacements: "

    .text
    .globl  main
main:
    # get string
    la      $a0,sprompt
    la      $a1,string
    li      $a2,80
    li      $v0,54
    syscall
    # get original character
    # since there is no 'inputdialogchar' syscall, use an inputdialogstring
    # syscall. This will read a string but we will just use the first character
    la      $a0,oprompt
    la      $a1,orig
    li      $a2,4
    li      $v0,54
    syscall
    la      $a0,nprompt
    la      $a1,new
    li      $a2,4
    li      $v0,54
    syscall

    la $a0,string	# Load address of string to $a0
    lb $a1,orig		# Load original char
    lb $a2,new		# Load new char
    li $a3,0		# Initialize numReplacements to zero 
    
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
    addi $a3,$a3,1	# numReplacements++
    j loop		# goto loop
done:


    # this code will output the string.  now, it will be the string entered.
    # once you've added your code, you should see the string with replacements
    li   $v0,4
    la   $a0,rprompt
    syscall
    
    li   $v0, 4       
    la   $a0,string
    syscall
    
    # this code will output the count of replacements, 
    # which must be stored in $a3    
    li   $v0, 4
    la   $a0,cprompt
    syscall  
    
    li   $v0, 1       
    move $a0, $a3
    syscall
    
    
# OUTPUT (using input string "sassy", replace s->p)
#
# The string with replacements: pappy
# Number of replacements: 3
# -- program is finished running (dropped off bottom) --
#
