.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#   If any file operation fails or doesn't read the proper number of bytes,
#   exit the program with exit code 1.
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
#
# If you receive an fopen error or eof, 
# this function exits with error code 50.
# If you receive an fread error or eof,
# this function exits with error code 51.
# If you receive an fclose error or eof,
# this function exits with error code 52.
# ==============================================================================
read_matrix:

    # Prologue
	addi sp, sp, -40
	sw ra, 36(sp)
	sw s8, 32(sp)
	sw s7, 28(sp)
	sw s6, 24(sp)
	sw s5, 20(sp)
	sw s4, 16(sp)
	sw s3, 12(sp)
	sw s2, 8(sp)
	sw s1, 4(sp)
	sw s0, 0(sp)

    # save arguments
    mv s0, a0               # filename
    mv s1, a1               # pointer to num rows
    mv s2, a2               # pointer to num columns

    # open file
    mv a1, s0
    li a2, 0                # 0: read only
    jal ra, fopen
    mv s3, a0               # f: file descriptor
    li t0, -1
    beq s3, t0, exit_50     # if error occurs, f will be -1

    # read #rows
    mv a0, s3
    mv a1, s1
    jal ra, read_single_int

    # read #columns
    mv a0, s3
    mv a1, s2
    jal ra, read_single_int

    # allocate memory on heap by calling malloc
    lw s4, 0(s1)            # rows
    lw s5, 0(s2)            # columns
    mul t0, s4, s5          # elements
    slli a0, t0, 2          # total bytes for matrix
    jal ra, malloc
    mv s6, a0               # pointer to matrix

   # read elements
    li s7, 0                # int i = 0
    mv t0, s6               # int *p = mat
outer_loop_start:           # for (i = 0; i < nrows; ++i)
    bge s7, s4, outer_loop_end
    li s8, 0                # int j = 0
inner_loop_start:           # for (j = 0; j < ncolumns; ++j)
    bge s8, s5, inner_loop_end
    mv a0, s3
    mv a1, t0
    jal ra, read_single_int # *p = read_int()

    addi t0, t0, 4          # ++p
    addi s8, s8, 1          # ++j
    j inner_loop_start

inner_loop_end:
    addi s7, s7, 1          # ++i
    j outer_loop_start

outer_loop_end:

    # close file
    mv a1, s3
    jal ra, fclose
    bnez a0, exit_52

    mv a0, s6               # return pointer to mat

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw ra, 36(sp)
    addi sp, sp, 40

    ret


# ===========================================
# Args:
#   a0: file descriptor
#   a1: buffer
# Return:
#   none
# ===========================================
read_single_int:
    addi sp, sp, -4
    sw ra, 0(sp)

    li a3, 4        # n bytes to read
    mv a2, a1       # pointer to buffer
    mv a1, a0       # file descriptor

    jal ra, fread
    bne a0, a3, exit_51

    lw ra, 0(sp)
    addi sp, sp, 4
    ret


exit_50:
    li a1, 50
    j exit2
exit_51:
    li a1, 51
    j exit2
exit_52:
    li a1, 52
    j exit2
