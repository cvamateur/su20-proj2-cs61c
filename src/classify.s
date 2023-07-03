.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # 
    # If there are an incorrect number of command line args,
    # this function returns with exit code 49.
    #
    # Usage:
    #   main.s -m -1 <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    # check the number of command line arguments
    addi a0, a0, -5
    bnez a0, exit_49

    # Prologue
    addi sp, sp, -56        # 32 bytes + 24 bytes
    sw ra, 52(sp)
    sw s0, 48(sp)
    sw s1, 44(sp)
    sw s2, 40(sp)
    sw s3, 36(sp)
    sw s4, 32(sp)
    sw s5, 28(sp)
    sw s6, 24(sp)
    # #rows and #column     # 24 bytes
    #      20(sp): ci: input columns
    #      16(sp): ri: input rows
    #      12(sp): c1:    m1 columns
    #       8(sp): r1:    m1 rows
    #       4(sp): c0:    m0 columns
    #       0(sp): r0:    m0 rows

    # Read arguments
    lw s0, 4(a1)        # char* p_m0 = argv[1]
    lw s1, 8(a1)        # char* p_m1 = argv[2]
    lw s2, 12(a1)       # char* p_inp = argv[3]
    lw s3, 16(a1)       # char* p_out = argv[4]

	# =====================================
    # LOAD MATRICES
    # =====================================
    # Load pretrained m0
    mv a0, s0
    addi a1, sp, 0      # r0
    addi a2, sp, 4      # c0
    jal ra, read_matrix
    mv s0, a0           # m0

    # Load pretrained m1
    mv a0, s1
    addi a1, sp, 8      # r1
    addi a2, sp, 12     # c1
    jal ra, read_matrix
    mv s1, a0           # m1

    # Load input matrix
    mv a0, s2
    addi a1, sp, 16     # ri
    addi a2, sp, 20     # ci
    jal ra, read_matrix
    mv s2, a0           # input

    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:  m0 * input
    # Allocate memory on heap to store hidden layer (h0)
    #    m0: [r0, c0]
    # input: [ri, ci]
    #    h0: [r0, ci]
    lw t0, 0(sp)        # r0
    lw t1, 20(sp)       # ci
    mul a0, t0, t1      # r0 * ci
    slli a0, a0, 2      # r0 * ci * 4
    jal ra, malloc
    mv s4, a0           # h0

    # calculate m0 * input
    mv a0, s0           # m0
    lw a1, 0(sp)        # r0
    lw a2, 4(sp)        # c0
    mv a3, s2           # input
    lw a4, 16(sp)       # ri
    lw a5, 20(sp)       # ci
    mv a6, s4           # h0
    jal ra, matmul

    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    mv a0, s4           # h0
    lw t0, 0(sp)        # r0
    lw t1, 20(sp)       # ci
    mul a1, t0, t1
    jal relu

    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)
    # Allocate memory on heap to store hidden layer (out)
    #     m1: [r1, c1]
    #     h0: [r0, ci]
    # scores: [r1, ci]
    lw t0, 8(sp)        # r1
    lw t1, 20(sp)       # ci
    mul a0, t0, t1
    slli a0, a0, 2
    jal malloc
    mv s5, a0           # scores

    # calculate m1 * h0
    mv a0, s1           # m1
    lw a1, 8(sp)        # r1
    lw a2, 12(sp)       # c1
    mv a3, s4           # h0
    lw a4, 0(sp)        # r0
    lw a5, 20(sp)       # ci
    mv a6, s5           # scores
    jal matmul

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
    mv a0, s3
    mv a1, s5
    lw a2, 8(sp)
    lw a3, 20(sp)
    jal write_matrix

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    mv a0, s5
    lw t0, 8(sp)        # r1
    lw t1, 20(sp)       # ci
    mul a1, t0, t1
    jal argmax
    mv s6, a0           # predicted class label

    # Print classification
    mv a1, s6
    jal print_int

    # Print newline afterwards for clarity
    li a1, '\n'
    jal print_char

    # final result
    mv a0, s6

    # Epilogue
    lw s6, 24(sp)
    lw s5, 28(sp)
    lw s4, 32(sp)
    lw s3, 36(sp)
    lw s2, 40(sp)
    lw s1, 44(sp)
    lw s0, 48(sp)
    lw ra, 52(sp)
    addi sp, sp, 56

    ret


exit_49:
    li a1, 49
    j exit2


# ===============================================
# args:
#   a0 is the pointer to the start of the array
#   a1 is the pointer to the rows in the array
#   a2 is the pointer to the columns in the array
# return:
#   void
# ===============================================
print_matrix:
    lw a1, 0(a1)
    lw a2, 0(a2)
    j print_int_array
