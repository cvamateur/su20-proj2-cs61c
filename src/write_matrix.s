.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
#   If any file operation fails or doesn't write the proper number of bytes,
#   exit the program with exit code 1.
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
#
# If you receive an fopen error or eof, 
# this function exits with error code 53.
# If you receive an fwrite error or eof,
# this function exits with error code 54.
# If you receive an fclose error or eof,
# this function exits with error code 55.
# ==============================================================================
write_matrix:

    # Prologue
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s6, 24(sp)
    sw s5, 20(sp)
    sw s4, 16(sp)
    sw s3, 12(sp)
    sw s2, 8(sp)
    sw s1, 4(sp)
    sw s0, 0(sp)

    # copy parameters
    mv s0, a0       # filename
    mv s1, a1       # pointer to matrix
    mv s2, a2       # rows
    mv s3, a3       # columns

    # open file
    mv a1, s0
    li a2, 1
    jal ra, fopen
    addi t0, a0, 1
    beqz t0, exit_53
    mv s0, a0       # f: file descriptor

    # write nrows and ncolumns
    addi sp, sp, -8
    sw s2, 0(sp)
    sw s3, 4(sp)
    addi t0, sp, 0  # address of #rows
    addi t1, sp, 4  # address of #columns

    # write rows
    mv a1, s0
    mv a2, t0
    li a3, 1
    li a4, 4
    jal ra, fwrite
    blt a0, a3, exit_54

    # write columns
    mv a1, s0
    mv a2, t1
    li a3, 1
    li a4, 4
    jal ra, fwrite
    blt a0, a3, exit_54
    addi sp, sp, 8

    # write matrix elements
    mv s6, s1           # int *p = mat
    li s4, 0            # int i = 0
outer_loop_start:
    bge s4, s2, outer_loop_end

    li s5, 0            # int j = 0
inner_loop_start:
    bge, s5, s3, inner_loop_end

    mv a1, s0
    mv a2, s6
    li a3, 1
    li a4, 4
    jal ra, fwrite
    blt a0, a3, exit_54

    addi s5, s5, 1      # ++j
    addi s6, s6, 4      # ++p
    j inner_loop_start

inner_loop_end:
    addi s4, s4, 1      # ++i
    j outer_loop_start

outer_loop_end:

    # close file
    mv a1, s0
    jal ra, fclose
    bnez a0, exit_55

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32

    ret

exit_53:
    li a1, 53
    j exit2
exit_54:
    li a1, 54
    j exit2
exit_55:
    li a1, 55
    j exit2
