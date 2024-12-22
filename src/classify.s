.globl classify

.text
# =====================================
# NEURAL NETWORK CLASSIFIER
# =====================================
# Description:
#   Command line program for matrix-based classification
#
# Command Line Arguments:
#   1. M0_PATH      - First matrix file location
#   2. M1_PATH      - Second matrix file location
#   3. INPUT_PATH   - Input matrix file location
#   4. OUTPUT_PATH  - Output file destination
#
# Register Usage:
#   a0 (int)        - Input: Argument count
#                   - Output: Classification result
#   a1 (char **)    - Input: Argument vector
#   a2 (int)        - Input: Silent mode flag
#                     (0 = verbose, 1 = silent)
#
# Error Codes:
#   31 - Invalid argument count
#   26 - Memory allocation failure
#
# Usage Example:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
# =====================================

classify:
    # Error handling
    li t0, 5
    blt a0, t0, error_args
    
    # Prologue
    addi sp, sp, -48
    sw ra, 0(sp)
    sw s0, 4(sp)  # m0 matrix
    sw s1, 8(sp)  # m1 matrix
    sw s2, 12(sp) # input matrix
    sw s3, 16(sp) # m0 matrix rows
    sw s4, 20(sp) # m0 matrix cols
    sw s5, 24(sp) # m1 matrix rows
    sw s6, 28(sp) # m1 matrix cols
    sw s7, 32(sp) # input matrix rows
    sw s8, 36(sp) # input matrix cols
    sw s9, 40(sp) # h
    sw s10, 44(sp) # o
    
    # Read pretrained m0
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    li a0, 4
    jal malloc     # malloc for rows
    beq a0, x0, error_malloc
    mv s3, a0     # save m0 rows pointer
    
    li a0, 4
    jal malloc     # malloc for cols
    beq a0, x0, error_malloc
    mv s4, a0     # save m0 cols pointer
    
    lw a1, 4(sp)  # restore argument pointer
    lw a0, 4(a1)  # get M0_PATH
    mv a1, s3     # rows pointer
    mv a2, s4     # cols pointer
    jal read_matrix
    mv s0, a0     # save m0 matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12

    # Read pretrained m1
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    li a0, 4
    jal malloc     # malloc for rows
    beq a0, x0, error_malloc
    mv s5, a0     # save m1 rows pointer
    
    li a0, 4
    jal malloc     # malloc for cols
    beq a0, x0, error_malloc
    mv s6, a0     # save m1 cols pointer
    
    lw a1, 4(sp)  # restore argument pointer
    lw a0, 8(a1)  # get M1_PATH
    mv a1, s5     # rows pointer
    mv a2, s6     # cols pointer
    jal read_matrix
    mv s1, a0     # save m1 matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12

    # Read input matrix
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    li a0, 4
    jal malloc     # malloc for rows
    beq a0, x0, error_malloc
    mv s7, a0     # save input rows pointer
    
    li a0, 4
    jal malloc     # malloc for cols
    beq a0, x0, error_malloc
    mv s8, a0     # save input cols pointer
    
    lw a1, 4(sp)  # restore argument pointer
    lw a0, 12(a1) # get INPUT_PATH
    mv a1, s7     # rows pointer
    mv a2, s8     # cols pointer
    jal read_matrix
    mv s2, a0     # save input matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12

    # Compute h = matmul(m0, input)
    addi sp, sp, -28
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    
    # Calculate size for h (m0_rows * input_cols)
    lw t0, 0(s3)    # Load m0 rows
    lw t1, 0(s8)    # Load input cols
    li a0, 0        # Initialize result
    mv t2, t0       # Use t0 as counter
mult_loop1:
    beqz t2, mult_done1
    add a0, a0, t1
    addi t2, t2, -1
    j mult_loop1
mult_done1:
    slli a0, a0, 2  # Multiply by 4 for bytes
    
    jal malloc 
    beq a0, x0, error_malloc
    mv s9, a0     # save h pointer
    mv a6, a0     # h pointer for matmul
    
    mv a0, s0     # m0 matrix
    lw a1, 0(s3)  # m0 rows
    lw a2, 0(s4)  # m0 cols
    mv a3, s2     # input matrix
    lw a4, 0(s7)  # input rows
    lw a5, 0(s8)  # input cols
    jal matmul
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    addi sp, sp, 28
    
    # Compute h = relu(h)
    addi sp, sp, -8
    sw a0, 0(sp)
    sw a1, 4(sp)
    
    mv a0, s9     # h matrix
    # Calculate length (m0_rows * input_cols)
    lw t0, 0(s3)  # Load m0 rows
    lw t1, 0(s8)  # Load input cols
    li a1, 0      # Initialize result
    mv t2, t0     # Use t0 as counter
mult_loop2:
    beqz t2, mult_done2
    add a1, a1, t1
    addi t2, t2, -1
    j mult_loop2
mult_done2:
    
    jal relu
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    addi sp, sp, 8
    
    # Compute o = matmul(m1, h)
    addi sp, sp, -28
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    
    # Calculate size for o (m1_rows * input_cols)
    lw t0, 0(s5)  # Load m1 rows
    lw t1, 0(s8)  # Load input cols
    li a0, 0      # Initialize result
    mv t2, t0     # Use t0 as counter
mult_loop3:
    beqz t2, mult_done3
    add a0, a0, t1
    addi t2, t2, -1
    j mult_loop3
mult_done3:
    slli a0, a0, 2  # Multiply by 4 for bytes
    
    jal malloc 
    beq a0, x0, error_malloc
    mv s10, a0    # save o pointer
    mv a6, a0     # o pointer for matmul
    
    mv a0, s1     # m1 matrix
    lw a1, 0(s5)  # m1 rows
    lw a2, 0(s6)  # m1 cols
    mv a3, s9     # h matrix
    lw a4, 0(s3)  # h rows
    lw a5, 0(s8)  # h cols
    jal matmul
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    addi sp, sp, 28
    
    # Write output matrix o
    addi sp, sp, -16
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    
    lw a1, 4(sp)  # restore argument pointer
    lw a0, 16(a1) # get OUTPUT_PATH
    mv a1, s10    # o matrix
    lw a2, 0(s5)  # rows
    lw a3, 0(s8)  # cols
    jal write_matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    addi sp, sp, 16
    
    # Compute and return argmax(o)
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    mv a0, s10    # o matrix
    # Calculate length (m1_rows * input_cols)
    lw t0, 0(s5)  # Load m1 rows
    lw t1, 0(s8)  # Load input cols
    li a1, 0      # Initialize result
    mv t2, t0     # Use t0 as counter
mult_loop4:
    beqz t2, mult_done4
    add a1, a1, t1
    addi t2, t2, -1
    j mult_loop4
mult_done4:
    
    jal argmax
    mv t0, a0     # save argmax result
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12
    
    mv a0, t0

    # Print result if not in silent mode
    bne a2, x0, epilogue
    
    addi sp, sp, -4
    sw a0, 0(sp)
    jal print_int
    li a0, '\n'
    jal print_char
    lw a0, 0(sp)
    addi sp, sp, 4
    
epilogue:
    # Save return value
    addi sp, sp, -4
    sw a0, 0(sp)
    
    # Free all allocated memory
    mv a0, s0
    jal free
    mv a0, s1
    jal free
    mv a0, s2
    jal free
    mv a0, s3
    jal free
    mv a0, s4
    jal free
    mv a0, s5
    jal free
    mv a0, s6
    jal free
    mv a0, s7
    jal free
    mv a0, s8
    jal free
    mv a0, s9
    jal free
    mv a0, s10
    jal free
    
    # Restore return value
    lw a0, 0(sp)
    addi sp, sp, 4

    # Restore saved registers
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    lw s9, 40(sp)
    lw s10, 44(sp)
    addi sp, sp, 48
    
    jr ra

error_args:
    li a0, 31
    j exit

error_malloc:
    li a0, 26
    j exit