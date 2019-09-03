# Eliza Poland
# cs270
# Asmt06 - String Builder
#
# This program creates a string builder object which maintains the data
# dynamically allocated buffer. The user can append to the buffer, display
# its contents, or clear the buffer and start over.
#
# This is run using the util.s file. This file should be assembled
# with the util.s file in the same directory.
#
# For clarity, there are 3 buffers involved here
# -- mysb.buffer (or just buffer), which is referenced using an address in the
#    sb object
# -- input_buffer, which has a size of BUF_MAX and is stored on the stack. Any input
#    from the user gets stored here.
# -- output_string, which holds the current output to be displayed during calls to
#    MessageDialogString. Whenever we are ready to output, we call mysb->toString() and
#    store the resulting address to this string in output_buffer


# *** Definition of Sb class: ***
# class Sb {
#    // the buffer is allocated in units of 2^chunk_nbits
#    int chunk_nbits;
#    // the size of the current buffer
#    int buffer_size;
#    // the number of characters in the current buffer
#    int len;
#    char *buffer;
#    // a call to resize with a integer value will ensure there is at least 
#    // that many bytes available in the buffer. If not, the buffer will be
#    // resized, rounding up to the next unit of 2^chunk_nbits)
#    void resize(int additional_bytes_wanted);
# public:
#    Sb(void);
#    void append(const char * str);
#    void append(char c);
#    char * toString(void);
#    void clear(void);
#    int length(void);
# };


    .data
input_prompt:	.asciiz "Input next string (q to quit, or empty string for result): "
clear_prompt:	.asciiz "Clear buffer (y/n/q): "
output_prompt:	.asciiz "Your string is: "
empty_str:	.asciiz ""
y:		.byte 'y'
BUF_MAX:	.word 100

    .text
    .globl main
main:
    # Setup stack
    addiu $sp,$sp,-152
    sw $ra,148($sp)
    sw $s0,144($sp)
    sw $s1,140($sp)
    sw $s2,136($sp)
    sw $s3,132($sp)
    
    # Load into s-registers
    la $s0,116($sp)	# Load address of mysb object in $s0
    la $s1,16($sp)	# Load address of input_buffer in $s1
    la $s2,empty_str	# Initialize output_string to be empty
    li $s3,1		# Flag - set to 0 after appending, else set to 1
    			# (necessary to avoid weird memory allocation bug)
    
    # Call constructor
    move $a0,$s0
    jal Sb$$v
    
.loop:
    # Get input from user
    la $a0,input_prompt
    move $a1,$s1
    lw $a2,BUF_MAX
    jal InputDialogString
    
    # Process input
    bltz $v0,.loop_end	# User entered 'q', goto .loop_end
    beqz $v0,.display	# User entered empty string, goto .display
    j .append		# User entered string of len>0, .goto append
    
.display:
    # if (flag != 0) goto .reuse_output
    # This prevents us from calling mysb.toString. Instead we can just 
    # reuse the contents of output_buffer in $s2 since nothing new has been appended
    bnez $s3,.reuse_output

    # Raise flag
    li $s3,1

    # output_string = mysb.toString()
    move $a0,$s0
    jal Sb$toString$v
    move $s2,$v0
    
.reuse_output:
    # Display the output_string
    la $a0,output_prompt
    move $a1,$s2
    jal MessageDialogString

    # Determine if we should clear the buffer or not
    la $a0,clear_prompt
    move $a1,$s1
    lw $a2,BUF_MAX
    jal InputDialogString
    
    # User entered 'q'
    bltz $v0,.loop_end
    
    # if (input_buffer[0] == 'y') mysb->clear();
    lb $t0,y		# $t0 = 'y'
    lb $t1,0($s1)	# $t1 = input_buffer[0]
    bne $t0,$t1,.retain_buffer
    
    move $a0,$s0
    jal Sb$clear$v	# Clear mysb buffer
    la $s2,empty_str	# Reset the output_buffer to an empty string
    
.retain_buffer:
    j .loop

.append:
    # Lower flag
    li $s3,0
    
    # Determine if we entered a char or a string
    li $t0,1
    beq $v0,$t0,.append_char	# Appending string of len=1
    b .append_str		# Appending string of len>1
    
.append_str:
    # Append the string
    move $a0,$s0
    move $a1,$s1
    jal Sb$append$C
    j .loop
    
.append_char:
    # Append the char
    move $a0,$s0
    move $a1,$s1
    jal Sb$append$c
    j .loop

.loop_end:
    # Restore stack
    lw $s3,132($sp)
    lw $s2,136($sp)
    lw $s1,140($sp)
    lw $s0,144($sp)
    lw $ra,148($sp)
    addiu $sp,$sp,152
    jr $ra
    


#Sb::Sb(void) {
    .globl Sb$$v
Sb$$v:
    addiu   $sp,$sp,-20
    sw      $ra,16($sp)
    sw      $a0,20($sp)
#    chunk_nbits=5;
    li      $t0,5
    sw      $t0,0($a0)
#    buffer_size=1<<chunk_nbits;
    li      $t0,1
    lw      $t1,0($a0)
    sllv    $t2,$t0,$t1
    sw      $t2,4($a0)
#    buffer = new char[buffer_size];
    move    $a0,$t2
    jal     malloc
    lw      $a0,20($sp)
    sw      $v0,12($a0)
#    len=0;
    sw      $zero,8($a0)
    lw      $ra,16($sp)
    addiu   $sp,$sp,20
    jr      $ra
#}


# void append(char* C)
    .globl Sb$append$C
Sb$append$C:
    # $a0 has address of mysb object
    # $a1 has address of input_buffer
    addiu $sp,$sp,-24
    sw $ra,20($sp)
    sw $s0,16($sp)	# Use $s0 to save destination pointer for copy
    
    # Home args
    sw $a0,24($sp)
    sw $a1,28($sp)
    
    # Get number of bytes on input_buffer, then 
    # resize if more room on the buffer is needed
    move $a0,$a1
    jal strlen
    
    lw $a0,24($sp)
    move $a1,$v0
    jal Sb$resize$i
    
    # Reload buffers
    lw $a0,24($sp)
    lw $a1,28($sp)
    
    # Get destination pointer which points to the address that we are copying to
    # This destination pointer will be in $s0
    lw $t0,8($a0)	# $t0 = sb.len
    lw $t2,12($a0)	# $t2 = &buffer[0]
    add $s0,$t2,$t0	# $s0 = &buffer[0] + mysb.len
    
    # Call strcpy(sb.buffer, input_buffer);
    # input_buffer already in $a1
    move $a0,$s0
    jal strcpy
    
    # Now we need to modify the length in our mysb object
    
    # Call strlen(input_buffer)
    lw $a0,28($sp)
    jal strlen
    
    lw $t0,24($sp)	# $t0 = mysb
    lw $t1,8($t0)	# $t1 = mysb.len
    add $t2,$t1,$v0	# $t2 = mysb.len + strlen(input_buffer)
    sw $t2,8($t0)
    
    # Reset stack
    lw $s0,16($sp)
    lw $ra,20($sp)
    addiu $sp,$sp,24
    jr $ra
    

# void append(char c)
    .globl Sb$append$c
Sb$append$c:
    # $a0 has address of mysb object
    # $a1 has address of input_buffer
    addiu $sp,$sp,-20
    sw $ra,16($sp)

    # Just call append for char* - it works for both
    jal Sb$append$C

    lw $ra,16($sp)
    addiu $sp,$sp,20
    jr $ra


# char* toString(void)
    .globl Sb$toString$v
Sb$toString$v:
    # $a0 has address of mysb object
    addiu $sp,$sp,-20
    sw $ra,16($sp)
    
    # Home args
    sw $a0,20($sp)
    
    # Create new string with the size of our current sb string
    lw $t0,8($a0)	# $t0 = mysb.len
    addi $t1,$t1,1	# Extra byte for null terminator
    move $a0,$t1
    jal malloc
    
    # strncpy(newStr, buffer, buffer.len)
    move $a0,$v0	# $a0 = &newStr[0]
    lw $t0,20($sp)	# Reload object from stack
    lw $a1,12($t0)	# $a1 = buffer
    lw $a2,4($t0)	# $a2 = buffer_size
    jal strncpy
    
    lw $ra,16($sp)
    addiu $sp,$sp,20
    jr $ra  
    
    
# void clear(void)
    .globl Sb$clear$v
Sb$clear$v:
    sw $zero,8($a0)
    jr $ra


# int length(void)
    .globl Sb$length$v
Sb$length$v:
    lw $v0,8($a0)
    jr $ra


#void Sb::resize(int additional_bytes_wanted) {
    .globl      Sb$resize$i
Sb$resize$i:
    addiu   $sp,$sp,-28
    sw      $ra,24($sp)
    sw      $s1,20($sp) # used for newbuf
    sw      $s0,16($sp) # used for this
    move    $s0,$a0
#    // need at least additional_bytes_wanted more bytes in buffer to
#    // hold resulting string.
#   size_needed = additional_bytes_wanted + len;
    # $t9 is size_needed
    lw      $t9,8($s0)
    add     $t9,$t9,$a1
#    if (size_needed < buffer_size) return;
    lw      $t2,4($s0)  # buffer_size
    blt     $t9,$t2,.Sb$resize$irtn
#    int size_needed_round = ((size_needed >> chunk_nbits) + 1) << chunk_nbits;
    lw      $t0,0($s0)  # chunk_nbits
    srlv     $t1,$t9,$t0
    addi    $t1,$t1,1
    sllv     $t1,$t1,$t0 # size_needed_round
#    buffer_size=size_needed_round;
    sw      $t1,4($s0)
#    char * newbuf= new char[size_needed_round];
    move    $a0,$t1
    jal     malloc
    move    $s1,$v0
#    strncpy(newbuf,buffer,len);
    move    $a0,$s1
    lw      $a1,12($s0)
    lw      $a2,8($s0)
    jal     strncpy
#    free (buffer);
    lw      $a0,12($s0)
    jal     free
#    buffer=newbuf;
    sw      $s1,12($s0)
#}
.Sb$resize$irtn:
    lw      $s0,16($sp)
    lw      $s1,20($sp)
    lw      $ra,24($sp)
    addiu   $sp,$sp,28
    jr      $ra
#

