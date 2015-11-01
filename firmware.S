.section .init
.global main

/* set stack pointer */
lui sp, %hi(8192)
addi sp, sp, %lo(8192)

/* call main */
jal ra, main

/* break */
sbreak
