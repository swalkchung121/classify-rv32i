.globl abs

.text
# =================================================================
# FUNCTION: Absolute Value Converter
#
# Transforms any integer into its absolute (non-negative) value by
# modifying the original value through pointer dereferencing.
# For example: -5 becomes 5, while 3 remains 3.
#
# Args:
#   a0 (int *): Memory address of the integer to be converted
#
# Returns:
#   None - The operation modifies the value at the pointer address
# =================================================================
abs:
    # Load number from memory
    lw t0, 0(a0)        # Load value from memory address in a0
    
    # Check if number is negative
    bge t0, zero, done  # If t0 >= 0, skip negation
    
    # If negative, negate it
    neg t0, t0          # t0 = -t0
    sw t0, 0(a0)        # Store the absolute value back to memory

done:
    jr ra