
.globl dot

.text
# =======================================================
# FUNCTION: Strided Dot Product Calculator
#
# Calculates sum(arr0[i * stride0] * arr1[i * stride1])
# where i ranges from 0 to (element_count - 1)
#
# Args:
#   a0 (int *): Pointer to first input array
#   a1 (int *): Pointer to second input array
#   a2 (int):   Number of elements to process
#   a3 (int):   Skip distance in first array
#   a4 (int):   Skip distance in second array
#
# Returns:
#   a0 (int):   Resulting dot product value
#
# Preconditions:
#   - Element count must be positive (>= 1)
#   - Both strides must be positive (>= 1)
#
# Error Handling:
#   - Exits with code 36 if element count < 1
#   - Exits with code 37 if any stride < 1
# =======================================================
dot:
    # Input validation
    li t0, 1
    blt a2, t0, error_terminate   # check if element count < 1
    blt a3, t0, error_terminate   # check if stride1 < 1
    blt a4, t0, error_terminate   # check if stride2 < 1

    # Initialize accumulator and counter
    li t0, 0            # t0 = dot product result
    li t1, 0           # t1 = loop counter
    li t2, 0           # t2 = index for first array
    li t3, 0           # t3 = index for second array

loop_start:
    bge t1, a2, loop_end    # if counter >= element_count, exit loop

    # Calculate addresses and load values
    slli t4, t2, 2          # t4 = first array offset (index * 4)
    add t4, a0, t4          # t4 = address of first array element
    lw t5, 0(t4)           # t5 = value from first array

    slli t4, t3, 2          # t4 = second array offset (index * 4)
    add t4, a1, t4          # t4 = address of second array element
    lw t6, 0(t4)           # t6 = value from second array

    # Prepare for multiplication
    li t4, 0               # t4 will hold multiplication result
    beq t5, zero, skip_mult  # if t5 is 0, skip multiplication

    # Handle negative multiplication
    bgez t5, mult_pos
    neg t5, t5             # make t5 positive
    neg t6, t6             # negate other number to maintain sign

mult_pos:
    beqz t5, skip_mult     # if counter reaches 0, multiplication is done
    add t4, t4, t6         # add t6 to result
    addi t5, t5, -1        # decrement counter
    j mult_pos

skip_mult:
    add t0, t0, t4         # add multiplication result to accumulator

    # Update indices using strides
    add t2, t2, a3         # increment first array index by stride1
    add t3, t3, a4         # increment second array index by stride2
    addi t1, t1, 1         # increment counter

    j loop_start

loop_end:
    mv a0, t0              # move result to return register
    ret

error_terminate:
    blt a2, t0, set_error_36
    li a0, 37              # error code for invalid stride
    j exit

set_error_36:
    li a0, 36              # error code for invalid length
    j exit
