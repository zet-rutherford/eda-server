    .attribute arch, "rv32imv_zicsr"
    .section .text.init
    .align 2
    .globl _start
_start:
    la t0, _trap_handler
    csrw mtvec, t0
    li s0, 0

    li t0, 0x600
    csrs mstatus, t0

    vsetvli t0, zero, e8, m1, ta, ma

    la a0, _data

    li t2, 0x55
    li t3, 0xAA
    li t4, 0
    li t5, 0

    xor t2, t2, t3
    addi t4, zero, 10
    vadd.vx v8, v8, t2
    vse8.v v18, (a0)
    vle8.v v16, (a0)
    addi t2, t2, 1
    vadd.vi v12, v14, -3
    vle8.v v14, (a0)
    vadd.vi v18, v18, 7
    vand.vv v12, v10, v8
    vsrl.vi v10, v12, 4
    addi t3, t3, -1
    vadd.vi v8, v10, 5
    xor t2, t2, t3
    vmaxu.vv v8, v12, v10
    vsetvli t0, zero, e32, m1, ta, ma
    vwadd.vv v4, v10, v18
    vsetvli t0, zero, e8, m1, ta, ma
    vadd.vi v12, v12, -1
    vle8.v v18, (a0)
    vmaxu.vv v8, v12, v10
    vadd.vx v8, v8, t2
    vsrl.vi v20, v16, 2
    vsll.vi v8, v10, 2
    add t2, t2, t3
    vand.vv v8, v10, v12
    addi t3, t3, -1
    vadd.vx v8, v8, t2
    or t3, t2, t3
    and t2, t2, t3
    vsrl.vi v20, v16, 2
    vadd.vx v10, v12, t2
    vadd.vi v20, v18, -2
    vxor.vv v10, v8, v14
    vsub.vv v18, v20, v16
    vor.vv v10, v12, v14
    vadd.vx v8, v8, t2
    add t4, t4, t5
    vadd.vi v14, v8, 7
    xor t2, t2, t3
    addi t4, zero, 10
    vadd.vi v16, v16, 3
    vadd.vi v10, v10, 0
    vsub.vv v10, v12, v14
    vand.vv v20, v16, v18
    vle8.v v16, (a0)
    vadd.vi v8, v10, 5
    vxor.vv v10, v8, v14
    vadd.vv v8, v10, v12
    vadd.vi v10, v10, 0
    vsub.vv v12, v10, v8
    vadd.vi v14, v8, 7
    vxor.vv v10, v8, v14
    vsll.vi v14, v8, 3
    slli t2, t2, 1
    vadd.vi v18, v18, 7
    vadd.vx v8, v8, t2
    vadd.vi v8, v8, 1
    nop
    vsrl.vi v20, v16, 2
    vse8.v v16, (a0)
    vse8.v v18, (a0)
    vsub.vv v10, v12, v14
    nop
    vsll.vi v16, v18, 1
    vor.vv v10, v12, v14
    vxor.vv v10, v8, v14
    vmin.vv v8, v10, v12
    vand.vv v8, v10, v12
    vminu.vv v12, v10, v14
    vadd.vi v12, v14, -3
    vadd.vx v8, v8, t2
    vminu.vv v12, v10, v14
    vadd.vi v20, v18, -2
    vadd.vi v20, v18, -2
    vor.vv v10, v12, v14
    vadd.vi v14, v8, 7
    vadd.vv v16, v18, v20
    vadd.vi v18, v18, 7
    vor.vv v10, v12, v14
    vsrl.vi v10, v12, 4
    vsll.vi v8, v10, 2
    vadd.vi v12, v12, -1
    addi t3, t3, -1
    vadd.vi v14, v14, 5
    vor.vv v16, v18, v20
    vadd.vv v16, v18, v20
    vadd.vi v18, v16, 2
    vminu.vv v12, v10, v14
    vor.vv v14, v8, v12
    slli t2, t2, 1

    li a0, 0
    la t0, _tohost
    li t1, 1
    sw t1, 0(t0)
    wfi
    j .-4

_fail:
    la t0, _tohost
    li t1, 3
    sw t1, 0(t0)
    wfi
    j .-4

    .align 2
_trap_handler:
    csrr t0, mcause
    li t1, 2
    bne t0, t1, _fail
    addi s0, s0, 1
    csrr t0, mepc
    addi t0, t0, 4
    csrw mepc, t0
    csrw vstart, zero
    mret

    .section .data
    .align 4
_data:
    .word 0x1659ddcc
    .word 0x2dc69c90
    .word 0x13b2d1ab
    .word 0x2a2e1e6a
    .word 0x25e050f6
    .word 0x05cf079e
    .word 0xee854c72
    .word 0x7951d52b

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
