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

    vsrl.vi v12, v14, 1
    addi t2, t2, 1
    vxor.vv v14, v10, v8
    vor.vv v16, v18, v20
    vadd.vi v10, v10, 0
    vsrl.vi v10, v12, 4
    vor.vv v16, v18, v20
    vadd.vi v14, v14, 5
    vsub.vv v12, v10, v8
    vsll.vi v14, v8, 3
    and t2, t2, t3
    or t3, t2, t3
    vadc.vvm v0, v1, v2, v0
    vse8.v v8, (a0)
    vadd.vx v10, v12, t2
    vadd.vx v10, v12, t2
    vsub.vv v8, v14, v10
    vadd.vv v12, v8, v14
    addi t3, t3, -1
    vse8.v v10, (a0)
    vadd.vi v14, v14, 5
    add t2, t2, t3
    add t4, t4, t5
    vse8.v v10, (a0)
    vse8.v v14, (a0)
    vadd.vx v10, v12, t2
    vadd.vi v12, v14, -3
    vadd.vi v8, v8, 1
    vadd.vv v12, v8, v14
    vadd.vv v12, v8, v14
    vse8.v v18, (a0)
    vand.vv v20, v16, v18
    vsrl.vi v12, v14, 1
    vsrl.vi v12, v14, 1
    vadd.vi v16, v16, 3
    vle8.v v18, (a0)
    vadd.vi v14, v14, 5
    vadd.vi v12, v14, -3
    vsub.vv v10, v12, v14
    vle8.v v16, (a0)
    vle8.v v8, (a0)
    vxor.vv v14, v10, v8
    vxor.vv v10, v8, v14
    vse8.v v16, (a0)
    srli t3, t3, 1
    nop
    addi t2, t2, 1
    vse8.v v14, (a0)
    vxor.vv v10, v8, v14
    vadd.vi v8, v8, 1
    or t3, t2, t3
    vand.vv v20, v16, v18
    vminu.vv v12, v10, v14
    vadd.vi v12, v12, -1
    vminu.vv v12, v10, v14
    vse8.v v10, (a0)
    vadd.vi v14, v14, 5
    vxor.vv v10, v8, v14
    slli t2, t2, 1
    vadd.vi v10, v10, 0
    vsrl.vi v12, v14, 1
    vadd.vi v12, v12, -1
    vadd.vi v10, v10, 0
    vle8.v v18, (a0)
    vadd.vv v12, v8, v14
    vor.vv v16, v18, v20
    vor.vv v14, v8, v12
    vadd.vi v18, v18, 7
    vxor.vv v10, v8, v14
    vsll.vi v8, v10, 2
    vadd.vi v20, v18, -2
    vadd.vi v16, v16, 3
    nop
    vadd.vi v20, v18, -2
    vsll.vi v14, v8, 3
    vsll.vi v14, v8, 3
    vadd.vx v8, v8, t2
    nop
    vse8.v v8, (a0)
    vsrl.vi v20, v16, 2
    vadd.vv v16, v18, v20
    vse8.v v16, (a0)
    vsub.vv v18, v20, v16
    vadd.vi v14, v8, 7
    vse8.v v8, (a0)
    vor.vv v14, v8, v12
    vminu.vv v12, v10, v14
    vadd.vi v12, v12, -1
    vsrl.vi v20, v16, 2
    vadd.vi v12, v14, -3
    vadd.vi v16, v16, 3
    vse8.v v8, (a0)
    addi t2, t2, 1
    vse8.v v14, (a0)
    vle8.v v12, (a0)
    vse8.v v10, (a0)
    vmax.vv v14, v8, v10
    vse8.v v8, (a0)
    vor.vv v14, v8, v12
    vsrl.vi v20, v16, 2
    addi t3, t3, -1
    vadd.vx v10, v12, t2
    vsrl.vi v10, v12, 4

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
    .word 0x4d131338
    .word 0xb0377c52
    .word 0x947defcf
    .word 0xd2c4c286
    .word 0x034d42fd
    .word 0x84a6d693
    .word 0x7c2257a0
    .word 0xe92966be

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
