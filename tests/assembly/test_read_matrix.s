.import ../../src/read_matrix.s
.import ../../src/utils.s

.data
file_path: .asciiz "inputs/test_read_matrix/test_input.bin"

.text
main:

    addi sp, sp, -24
    sw, ra, 20(sp)
    sw  s4, 16(sp)
    sw  s3, 12(sp)
    sw, s2, 8(sp)
    sw, s1, 4(sp)
    sw, s0, 0(sp)

    # Allocate stack memory
    addi s0, sp, 0  # pointer to matrix
    addi s1, sp, 4  # pointer to #rows
    addi s2, sp, 8  # pointer ti #columns
    addi s3, x0, 0  # rows
    addi s4, x0, 0  # columns

    # Read matrix into memory
    la a0, file_path
    mv a1, s1
    mv a2, s2
    jal ra, read_matrix
    mv s0, a0
    lw s3, 0(s1)
    lw s4, 0(s2)

    # --------------------------------------------------------
    ## Print rows and columns
    # mv a1, s3
    # jal ra, print_int
    # li a1, ' '
    # jal ra, print_char
    # mv a1, s4
    # jal ra, print_int
    # li a1, '\n'
    # jal ra, print_char

    # Print out elements of matrix
    mv a0, s0
    mv a1, s3
    mv a2, s4
    jal ra, print_int_array

    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw ra, 20(sp)
    addi sp, sp, 24

    # Terminate the program
    jal exit
