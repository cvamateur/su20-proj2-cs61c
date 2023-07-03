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
    li t0, 5
    bne a0, t0, exit_49

    # Prologue
    addi sp, sp, ?
    sw ra, ?(sp)
    sw s0, ?(sp)

    # Read arguments
    lw s0, 4(a1)        # char* p_m0 = argv[1]
    lw s1, 8(a1)        # char* p_m1 = argv[2]
    lw s2, 12(a1)       # char* p_inp = argv[3]
    lw s3, 16(a1)       # char* p_out = argv[4]

	# =====================================
    # LOAD MATRICES
    # =====================================
    # Allocate memory on stack to save #rows and #column
    addi sp, sp, -24
    addi s4, sp, 0      # int *pr_m0 = &rows
    addi s5, sp, 4      # int *pc_m0 = &columns
    addi s6, sp, 8      # int *pr_m1 = &rows
    addi s7, sp, 12     # int *pc_m1 = &columns
    addi s8, sp, 16     # int *pr_inp = &rows
    addi s9, sp, 20     # int *pc_inp = &column

    # Load pretrained m0
    mv a0, s0
    mv a1, s4
    mv a2, s5
    jal ra, read_matrix
    mv s0, a0           # int *p_m0 = m0

    # Load pretrained m1
    mv a0, s1
    mv a1, s6
    mv a2, s7
    jal ra, read_matrix
    mv s1, a0           # int *p_m1 = m1

    # Load input matrix
    mv a0, s2
    mv a1, s8
    mv a2, s9
    jal ra, read_matrix
    mv s2, a0           # int *p_inp = input

    # =====================================
    # RUN LAYERS
    # =====================================
    addi sp, sp, -8
    # 0(sp): h0
    # 4(sp): h1

    # 1. LINEAR LAYER:  m0 * input
    # Allocate memory on heap to store hidden layer (h0)
    # m0: (*s4) x (*s5)
    # inp: (*s8) x (*s9)
    # h0: (*s4) x (*s9)
    lw t0, 0(s4)
    lw t1, 0(s9)
    mul a0, t0, t1
    slli a0, a0, 2     # total bytes to allocate
    jal ra, malloc
    sw a0, 0(sp)       # int *p_h0 = h0

    # call matmal:  m0 * input
    mv a0, s0
    mv a1, s4
    mv a2, s5
    mv a3, s2
    mv a4, s6
    mv a5, s7
    lw a6, 0(sp)
    jal ra, matmal


    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    lw a0, 0(sp)        # h0
    mul a1, s4, s7      # num elements
    jal relu


    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)
    # Allocate memory on heap to store hidden layer (out)
    # m1: s6xs7
    # h0: s4xs9
    # out: s6xs9
    mul a0, s6, s9
    slli a0, a0, 2
    jal malloc
    sw a0, 4(sp)        # out

    # call matmul: m1 * h0
    mv a0, s1
    mv a1, s6
    mv a2, s7
    lw a3, 0(sp)
    mv a4, s4
    mv a5, s9
    lw a6, 4(sp)
    jal matmal
    sw a0, 4(sp)


    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix





    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax




    # Print classification
    



    # Print newline afterwards for clarity




    ret


exit_49:
    li a1, 49
    j exit2