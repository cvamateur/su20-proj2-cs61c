.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
#   The order of error codes (checked from top to bottom):
#   If the dimensions of m0 do not make sense, 
#   this function exits with exit code 2.
#   If the dimensions of m1 do not make sense, 
#   this function exits with exit code 3.
#   If the dimensions don't match, 
#   this function exits with exit code 4.
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# =======================================================
matmul:

    # Error checks
    addi t0, a1, -1
    blt t0, x0, exit_2   # n < 1, exit
    addi t0, a2, -1
    blt t0, x0, exit_2   # m < 1, exit
    addi t0, a4, -1
    blt t0, x0, exit_3   # p < 1, exit
    addi t0, a5, -1
    blt t0, x0, exit_3   # q < 1, exit
    bne a2, a4, exit_4   # m != p, exit

    # Prologue
    addi sp, sp, -40
    sw, ra, 20(sp)
    sw, s8, 16(sp)
    sw, s7, 16(sp)
    sw, s6, 16(sp)
    sw, s5, 16(sp)
    sw, s4, 16(sp)
    sw, s3, 12(sp)
    sw, s2, 8(sp)
    sw, s1, 4(sp)
    sw, s0, 0(sp)


# ==============================================
# int *p0 = m0;
# int *p1 = m1;
# int *pd = d;
# for (int i = 0; i < N; ++i) {
#   for (int j = 0; j < P; ++j) {
#       *pd = dot(p0, p1, m, 1, q)
#       ++p1;
#       ++pd;
#   }
#   p0 += M;
#   p1 = m1;
# }
# ==============================================

    mv s0, a0       # m0
    mv s1, a3       # m1
    mv s2, a1       # N: num rows of m0
    mv s3, a5       # P: num columns of m1
    mv s4, a6       # int *pd = d
    mv s5, s0       # int *p0 = m0
    mv s6, s1       # int *p1 = m1

    mv s7, x0       # int i = 0
outer_loop_start:
    bge s7, s2, outer_loop_end

    mv s8, x0       # int j = 0
inner_loop_start:
    bge s8, s3, inner_loop_end

    # prepare arguments and call dot product
    mv a0, s5
    mv a1, s6
    li a3, 1
    mv a4, a5
    jal ra dot

    # assign to destination matrix
    sw a0, 0(s4)
    addi s6, s6, 4  # ++p1
    addi s4, s4, 4  # ++pd
    addi s8, s8, 1  # ++j
    j inner_loop_start


inner_loop_end:
    slli t0, a2, 2
    add s5, s5, t0  # p0 += M
    mv s6, s1       # p1 = m1
    addi s7, s7, 1  # ++i
    j outer_loop_start

outer_loop_end:

    # Epilogue
    lw, s0, 0(sp)
    lw, s1, 4(sp)
    lw, s2, 8(sp)
    lw, s3, 12(sp)
    lw, s4, 16(sp)
    lw, s5 16(sp)
    lw, s6, 16(sp)
    lw, s7, 16(sp)
    lw, s8, 16(sp)
    lw, ra, 20(sp)
    addi sp, sp, 40

    ret


exit_2:
    addi a1, x0, 2
    j exit2
exit_3:
    addi a1, x0, 3
    j exit2
exit_4:
    addi a1, x0, 4
    j exit2
