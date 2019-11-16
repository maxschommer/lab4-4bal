# int double(x) -> returns 2*x

# Main (test)
# a = double(5)
# b = double(7)


main:

# Save any registers I need to keep in $t*
addi $sp, $sp, -4
sw $t0, 0($sp)
# Set up arguments in $a0
li $a0, 12 # Should equal 78


# Call function
jal add_n
move $s0, $v0
# Restore saved rgisters from before call
lw $t0, 0($sp)
addi $sp, $sp, 4

beq $s0, 78, pass
addi $v0, $zero, 0 ## failed
j passEnd
pass:
addi $v0, $zero, 1 ## succeeded

passEnd:
syscall



add_n: # A label
# Assume argument is in a0 by convention
# Save any registers in s* or ra that I might overwrite
ble $a0, 1, end

# Push ra and a0 to stack
addi $sp, $sp, -8
sw $ra, 4($sp)
sw $a0, 0($sp)

# Do the work
addi $a0, $a0, -1 # Calculate n-1, and put it in a0. 

jal add_n
# Some runction call (for argument)


# Pop ra and a0
lw $ra, 4($sp)
lw $a0, 0($sp)
addi $sp, $sp, 8


# Restore any registers that I saved back to their initial register
# Return
add $v0, $v0, $a0
jr $ra

end:
addi $v0, $zero, 1
jr $ra

