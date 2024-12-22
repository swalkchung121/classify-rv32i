.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication Implementation
#
# Performs operation: D = M0 × M1
# Where:
#   - M0 is a (rows0 × cols0) matrix
#   - M1 is a (rows1 × cols1) matrix
#   - D is a (rows0 × cols1) result matrix
#
# Arguments:
#   First Matrix (M0):
#     a0: Memory address of first element
#     a1: Row count
#     a2: Column count
#
#   Second Matrix (M1):
#     a3: Memory address of first element
#     a4: Row count
#     a5: Column count
#
#   Output Matrix (D):
#     a6: Memory address for result storage
#
# Validation (in sequence):
#   1. Validates M0: Ensures positive dimensions
#   2. Validates M1: Ensures positive dimensions
#   3. Validates multiplication compatibility: M0_cols = M1_rows
#   All failures trigger program exit with code 38
#
# Output:
#   None explicit - Result matrix D populated in-place
# =======================================================
matmul:
    # Error checks
    li t0, 1
    blt a1, t0, error    # rows0 < 1
    blt a2, t0, error    # cols0 < 1
    blt a4, t0, error    # rows1 < 1
    blt a5, t0, error    # cols1 < 1
    bne a2, a4, error    # cols0 != rows1

    # Prologue
    addi sp, sp, -28
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    
    # Initialize counters and pointers
    li s0, 0            # i: outer loop counter (rows of M0)
    mv s3, a6          # result matrix pointer
    mv s4, a0          # base pointer for M0
    mv s5, a3          # base pointer for M1

outer_loop_start:
    bge s0, a1, outer_loop_end    # if i >= rows0, end
    li s1, 0                      # j: inner loop counter (cols of M1)

inner_loop_start:
    bge s1, a5, inner_loop_end    # if j >= cols1, end

    # Prepare for dot product
    addi sp, sp, -24
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)

    # Calculate starting addresses for dot product
    # M0 row address: s4 + (s0 * cols0 * 4)
    mv a0, s4                  # row pointer for M0
    
    # M1 column address: s5 + (s1 * 4)
    slli t1, s1, 2            # j * 4
    add a1, s5, t1            # column pointer for M1
    
    mv a2, a2                 # length = cols0 = rows1
    li a3, 1                  # stride for M0 = 1
    mv a4, a5                 # stride for M1 = cols1

    jal ra, dot              # call dot product

    # Store result in output matrix
    sw a0, 0(s3)             # store dot product result
    addi s3, s3, 4           # increment result pointer

    # Restore saved registers
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    addi sp, sp, 24

    addi s1, s1, 1           # increment j
    j inner_loop_start

inner_loop_end:
    # Move to next row of M0
    slli t0, a2, 2           # cols0 * 4
    add s4, s4, t0           # increment M0 pointer to next row
    addi s0, s0, 1           # increment i
    j outer_loop_start

outer_loop_end:
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28
    ret

error:
    li a0, 38
    j exit