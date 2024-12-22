
.globl argmax

.text
# =================================================================
# FUNCTION: Maximum Element First Index Finder
#
# Scans an integer array to find its maximum value and returns the
# position of its first occurrence. In cases where multiple elements
# share the maximum value, returns the smallest index.
#
# Arguments:
#   a0 (int *): Pointer to the first element of the array
#   a1 (int):  Number of elements in the array
#
# Returns:
#   a0 (int):  Position of the first maximum element (0-based index)
#
# Preconditions:
#   - Array must contain at least one element
#
# Error Cases:
#   - Terminates program with exit code 36 if array length < 1
# =================================================================
argmax:
    # Input validation: check if length (a1) >= 1
    li t6, 1
    blt a1, t6, handle_error

    # Initialize variables
    lw t0, 0(a0)        # t0 = current maximum value
    li t1, 0           # t1 = index of current maximum (return value)
    li t2, 1           # t2 = current index in loop

loop_start:
    # Check loop termination
    beq t2, a1, loop_end    # if current index == length, exit loop
    
    # Load current element
    slli t3, t2, 2          # t3 = t2 * 4 (byte offset)
    add t4, a0, t3          # t4 = base address + offset
    lw t5, 0(t4)           # t5 = current element
    
    # Compare with current maximum
    ble t5, t0, skip        # if current <= max, skip update
    
    # Update maximum and index
    mv t0, t5              # update maximum value
    mv t1, t2              # update index of maximum
    
skip:
    # Increment counter and continue loop
    addi t2, t2, 1         # increment index
    j loop_start           # continue loop
    
loop_end:
    # Return index of maximum
    mv a0, t1              # move result to return register
    ret

handle_error:
    li a0, 36              # load error code
    j exit
