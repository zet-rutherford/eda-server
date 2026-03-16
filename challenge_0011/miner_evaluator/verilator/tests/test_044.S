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

    addi t3, t3, -1
    vle8.v v18, (a0)
    vmin.vv v8, v10, v12
    vse8.v v8, (a0)
    vor.vv v14, v8, v12
    addi t2, t2, 1
    vsll.vi v14, v8, 3
    sub t3, t2, t3
    vadd.vi v14, v8, 7
    addi t4, zero, 10
    vadd.vi v16, v16, 3
    vadd.vv v16, v18, v20
    vse8.v v10, (a0)
    vse8.v v8, (a0)
    vse8.v v10, (a0)
    vadd.vi v8, v8, 1
    nop
    vmax.vv v14, v8, v10
    vadd.vi v8, v10, 5
    vand.vv v20, v16, v18
    vle8.v v12, (a0)
    vse8.v v12, (a0)
    vsub.vv v10, v12, v14
    addi t5, zero, -5
    vsrl.vi v20, v16, 2
    vse8.v v18, (a0)
    sub t3, t2, t3
    vadd.vv v12, v8, v14
    srli t3, t3, 1
    vadd.vi v20, v20, -5
    vmin.vv v8, v10, v12
    vsub.vv v12, v10, v8
    vminu.vv v12, v10, v14
    vadd.vi v12, v12, -1
    vse8.v v18, (a0)
    vmaxu.vv v8, v12, v10
    addi t4, zero, 10
    vadd.vv v12, v8, v14
    vsub.vv v18, v20, v16
    vle8.v v8, (a0)
    vsll.vi v14, v8, 3
    vxor.vv v10, v8, v14
    vadd.vx v8, v8, t2
    vsrl.vi v12, v14, 1
    vle8.v v18, (a0)
    vxor.vv v10, v8, v14
    vse8.v v18, (a0)
    vadd.vi v10, v12, -1
    vadc.vvm v0, v1, v2, v0
    vadd.vi v14, v14, 5
    vsub.vv v12, v10, v8
    vadd.vi v16, v16, 3
    vminu.vv v12, v10, v14
    vadd.vi v8, v8, 1
    vsub.vv v12, v10, v8
    vand.vv v20, v16, v18
    vsrl.vi v10, v12, 4
    vadd.vi v10, v10, 0
    vadd.vi v10, v12, -1
    vsub.vv v10, v12, v14
    vand.vv v8, v10, v12
    vadd.vi v14, v8, 7
    vadd.vi v20, v18, -2
    vle8.v v10, (a0)
    add t2, t2, t3
    vor.vv v14, v8, v12
    nop
    vmax.vv v14, v8, v10
    vadd.vi v18, v16, 2
    vadd.vx v8, v8, t2
    vle8.v v12, (a0)
    vadd.vi v8, v8, 1
    vand.vv v12, v10, v8
    vsrl.vi v10, v12, 4
    vadd.vi v20, v20, -5
    vadd.vv v16, v18, v20
    vse8.v v14, (a0)
    vle8.v v12, (a0)
    vadd.vv v12, v8, v14
    addi t4, zero, 10
    vle8.v v18, (a0)
    vand.vv v8, v10, v12
    vminu.vv v12, v10, v14
    vadd.vv v16, v18, v20
    sub t3, t2, t3
    vadd.vi v12, v12, -1
    addi t5, zero, -5
    vle8.v v10, (a0)
    addi t3, t3, -1
    add t4, t4, t5
    vadd.vi v10, v10, 0
    and t2, t2, t3
    addi t2, t2, 1
    vse8.v v12, (a0)
    vsll.vi v14, v8, 3
    or t3, t2, t3
    vadd.vv v16, v18, v20
    vadd.vx v10, v12, t2
    vadd.vi v16, v16, 3
    vadd.vv v8, v10, v12
    vadd.vi v20, v20, -5
    add t4, t4, t5
    vsll.vi v16, v18, 1
    vse8.v v16, (a0)
    vsrl.vi v10, v12, 4
    vse8.v v14, (a0)
    vsrl.vi v10, v12, 4
    vse8.v v16, (a0)
    vor.vv v16, v18, v20
    vadd.vi v14, v14, 5

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
    .word 0xdb75dada
    .word 0xa261078d
    .word 0x94108438
    .word 0x09572517
    .word 0x300a491a
    .word 0xc63e0e47
    .word 0x99d76c9c
    .word 0x3754c5ec

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
