
addi $t0, $zero, 5
add $t1, $t0, $zero
addi $t5, $zero, 1
addi $t4, $zero, 1
addi $t3, $zero, 1
addi $t2, $zero, 1
addi $t1, $zero, 0
$FOR:
beq $t5, $t0, $ENDFOR
addi $t1, $t4, 0
add  $t4, $t3, $t2
addi $t3, $t2, 0
addi $t2, $t1, 0
addi $t5, $t5, 1
j $FOR

$ENDFOR:
