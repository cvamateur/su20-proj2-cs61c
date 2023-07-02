.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
#
# If the length of the vector is less than 1, 
# this function exits with error code 7.
# =================================================================
argmax:

    # Prologue
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s2, 8(sp)
    sw s1, 4(sp)
    sw s0, 0(sp)

loop_start:
    addi s0, x0, 0    # num elements offset
    addi s1, x0, 0    # hold the return index value
    lw s2, 0(a0)      # hold the maximum value

loop_continue:
    bge s0, a1, loop_end
    slli t0, s0, 2    # offset address
    add t1, a0, t0    # current position
    lw t2, 0(t1)      # current value
    bge s2, t2, skip  # if current value is larger, skip to next
    mv s1, s0         # update index
    mv s2, t2         # update maximum
skip:
    addi s0, s0, 1    # step to next entry
    jal x0, loop_continue

loop_end:
    mv a0, s1  # move return index to a0 register

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16

    ret