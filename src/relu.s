.globl relu

.text
# ==============================================================================
# FUNCTION: Array ReLU Activation
#
# Applies ReLU (Rectified Linear Unit) operation in-place:
# For each element x in array: x = max(0, x)
#
# Arguments:
#   a0: Pointer to integer array to be modified
#   a1: Number of elements in array
#
# Returns:
#   None - Original array is modified directly
#
# Validation:
#   Requires non-empty array (length ≥ 1)
#   Terminates (code 36) if validation fails
#
# Example:
#   Input:  [-2, 0, 3, -1, 5]
#   Result: [ 0, 0, 3,  0, 5]
# ==============================================================================
relu:
    # Prologue (not needed as we don't use any callee-saved registers)
    
    # Input validation: check if length (a1) >= 1
    li t0, 1             
    blt a1, t0, error     # if a1 < 1, branch to error
    
    # Initialize loop counter
    li t0, 0             # t0 = 0 (loop counter)

loop_start:
    # Check loop termination condition
    beq t0, a1, loop_end # if counter == length, exit loop
    
    # Load current element from array
    slli t1, t0, 2       # t1 = t0 * 4 (convert index to byte offset)
    add t2, a0, t1       # t2 = base address + offset
    lw t3, 0(t2)        # t3 = current element
    
    # Apply ReLU: if value < 0, set to 0
    bge t3, zero, skip   # if value >= 0, skip setting to 0
    sw zero, 0(t2)      # store 0 at current position
    
skip:
    # Increment counter and continue loop
    addi t0, t0, 1      # increment counter
    j loop_start        # continue loop
    
loop_end:
    # Epilogue (not needed as we don't use any callee-saved registers)
    ret

error:
    li a0, 36           # load error code 36
    j exit              # exit program with error