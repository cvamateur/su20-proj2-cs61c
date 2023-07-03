.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
#
# If the length of the vector is less than 1, 
# this function exits with error code 8.
# ==============================================================================
relu:
    # Prologue
    addi sp, sp, -8
    sw s1, 4(sp)
    sw s0, 0(sp)

loop_start:
    addi s0, x0, 0      # #elements offset
    addi s1, x0, 0      # hold value of each entry

loop_continue:
    bge s0, a1, loop_end
    slli t0, s0, 2
    add t1, a0, t0  # address at current position
    lw s1, 0(t1)    # load current value

    # t2 = x > 0 ? 1: 0
    slt, t2, x0, s1
    mul s1, s1, t2  # set all negative values to 0 while keep positive values unchanged
    sw s1, 0(t1)    # save the negated value
    addi s0, s0, 1  # step to next element
    j loop_continue

loop_end:
    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 8
    
	ret