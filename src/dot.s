.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
#
# If the length of the vector is less than 1, 
# this function exits with error code 5.
# If the stride of either vector is less than 1,
# this function exits with error code 6.
# =======================================================
dot:
   addi t0, x0, 1
   blt a2, t0, exit_5
   blt a3, t0, exit_6
   blt a4, t0, exit_6

    # Prologue
    addi sp, sp, -12
    sw ra, 8(sp)
    sw s1, 4(sp)
    sw s0, 0(sp)

loop_start:
    addi s0, x0, 0   # number elements counter
    addi s1, x0, 0   # result value

loop_continue:
    bge s0, a2, loop_end

    # get current value in v0
    mul t0, s0, a3
    slli t0, t0, 2
    add t0, a0, t0
    lw t1, 0(t0)

    # get current value in v1
    mul t2, s0, a4
    slli t2, t2, 2
    add t2, a1, t2
    lw t3, 0(t2)

    # accumulate multiply to result
    mul t4, t1, t3
    add s1, s1, t4

    # move to next element
    addi s0, s0, 1
    j loop_continue

loop_end:
    mv a0, s1

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw ra, 8(sp)
    addi sp, sp, 12

    ret


exit_5:
    li a1, 5
    j exit2

exit_6:
    li a1, 6
    j exit2
