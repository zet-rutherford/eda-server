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

    vor.vv v14, v8, v12
    vsll.vi v8, v10, 2
    vsrl.vi v10, v12, 4
    nop
    vle8.v v8, (a0)
    vmin.vv v8, v10, v12
    nop
    slli t2, t2, 1
    vle8.v v14, (a0)
    vsub.vv v18, v20, v16
    vle8.v v16, (a0)
    vor.vv v10, v12, v14
    vadd.vi v8, v10, 5
    vadd.vi v10, v12, -1
    vle8.v v10, (a0)
    vse8.v v18, (a0)
    vadd.vv v14, v8, v10
    vadd.vv v12, v8, v14
    vadd.vv v8, v10, v12
    vmaxu.vv v8, v12, v10
    add t4, t4, t5
    vadd.vi v16, v16, 3
    vse8.v v18, (a0)
    vsub.vv v18, v20, v16
    vadd.vi v8, v8, 1
    vor.vv v14, v8, v12
    xor t2, t2, t3
    vadd.vv v16, v18, v20
    vle8.v v16, (a0)
    vmax.vv v14, v8, v10
    vsll.vi v14, v8, 3
    vsrl.vi v20, v16, 2
    vxor.vv v10, v8, v14
    vmin.vv v8, v10, v12
    vse8.v v14, (a0)
    vsrl.vi v12, v14, 1
    vsub.vv v8, v14, v10
    vmaxu.vv v8, v12, v10
    add t4, t4, t5
    vadc.vvm v0, v1, v2, v0
    vmax.vv v14, v8, v10
    vsrl.vi v20, v16, 2
    vand.vv v12, v10, v8
    vle8.v v8, (a0)
    vadd.vi v18, v18, 7
    xor t2, t2, t3
    vle8.v v16, (a0)
    vadd.vi v18, v16, 2
    vadd.vi v14, v14, 5
    vadd.vv v14, v8, v10
    vle8.v v8, (a0)
    vsub.vv v10, v12, v14
    vor.vv v10, v12, v14
    vor.vv v16, v18, v20
    vadd.vi v18, v16, 2
    vxor.vv v14, v10, v8
    vsub.vv v10, v12, v14
    vsub.vv v18, v20, v16
    vadd.vv v16, v18, v20
    vse8.v v18, (a0)
    vadd.vv v8, v10, v12
    addi t2, t2, 1
    vadd.vi v8, v10, 5
    vadd.vx v10, v12, t2
    vor.vv v14, v8, v12
    vadd.vi v8, v10, 5
    vsll.vi v16, v18, 1
    nop
    or t3, t2, t3
    vsrl.vi v10, v12, 4
    vse8.v v16, (a0)
    vsub.vv v12, v10, v8
    vor.vv v10, v12, v14
    vadd.vi v18, v18, 7
    addi t3, t3, -1
    vle8.v v12, (a0)
    vadd.vx v10, v12, t2
    vadd.vx v10, v12, t2
    vadd.vi v18, v18, 7
    vle8.v v10, (a0)
    vsrl.vi v20, v16, 2
    vadd.vx v10, v12, t2
    vse8.v v14, (a0)
    vnsrl.wi v5, v4, 0
    vle8.v v12, (a0)
    vadd.vi v18, v18, 7
    vadd.vi v10, v10, 0
    vadd.vv v16, v18, v20
    vor.vv v10, v12, v14
    vse8.v v8, (a0)
    vadd.vi v10, v10, 0
    add t2, t2, t3
    vsub.vv v10, v12, v14
    vsub.vv v18, v20, v16
    vxor.vv v10, v8, v14
    vsll.vi v14, v8, 3
    vadd.vv v8, v10, v12
    vand.vv v12, v10, v8
    vle8.v v16, (a0)

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
    .word 0xfa0f01a4
    .word 0x9e719a56
    .word 0x81ee30e4
    .word 0x35469cb1
    .word 0x0d95ee72
    .word 0xe9570a2a
    .word 0x7f5d21f2
    .word 0xec344cf0

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
