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

    vadd.vv v12, v8, v14
    vsub.vv v8, v14, v10
    slli t2, t2, 1
    vsrl.vi v12, v14, 1
    vadd.vi v20, v20, -5
    vle8.v v12, (a0)
    vand.vv v12, v10, v8
    sub t3, t2, t3
    vle8.v v16, (a0)
    vminu.vv v12, v10, v14
    vadd.vi v10, v10, 0
    vminu.vv v12, v10, v14
    vsll.vi v14, v8, 3
    vadd.vi v18, v18, 7
    vle8.v v8, (a0)
    vadd.vi v12, v14, -3
    vadd.vi v16, v16, 3
    xor t2, t2, t3
    vmax.vv v14, v8, v10
    vsub.vv v18, v20, v16
    vminu.vv v12, v10, v14
    vse8.v v12, (a0)
    vadd.vi v14, v8, 7
    addi t2, t2, 1
    vminu.vv v12, v10, v14
    vadd.vv v14, v8, v10
    vadd.vv v12, v8, v14
    slli t2, t2, 1
    vadd.vv v12, v8, v14
    vsetvli t0, zero, e32, m1, ta, ma
    .word 0x08061057
    vsetvli t0, zero, e8, m1, ta, ma
    vmerge.vvm v0, v1, v2, v0
    vadd.vx v10, v12, t2
    vle8.v v10, (a0)
    vmaxu.vv v8, v12, v10
    vadd.vi v18, v18, 7
    vxor.vv v10, v8, v14
    vand.vv v12, v10, v8
    vadd.vx v10, v12, t2
    and t2, t2, t3
    vadd.vi v18, v16, 2
    vmaxu.vv v8, v12, v10
    vadd.vi v10, v10, 0
    vxor.vv v10, v8, v14
    vle8.v v18, (a0)
    vsll.vi v8, v10, 2
    vadd.vi v8, v8, 1
    vadd.vv v8, v10, v12
    vsub.vv v18, v20, v16
    vle8.v v10, (a0)
    vadd.vi v10, v10, 0
    vadd.vi v12, v12, -1
    or t3, t2, t3
    add t2, t2, t3
    add t2, t2, t3
    vadd.vi v12, v14, -3
    vor.vv v10, v12, v14
    addi t2, t2, 1
    nop
    nop
    vsrl.vi v20, v16, 2
    vadd.vi v8, v10, 5
    vadd.vx v10, v12, t2
    vle8.v v10, (a0)
    vsll.vi v8, v10, 2
    vle8.v v8, (a0)
    slli t2, t2, 1
    vadd.vi v8, v10, 5
    vse8.v v8, (a0)
    vadd.vv v8, v10, v12
    vsub.vv v10, v12, v14
    vle8.v v16, (a0)
    vmaxu.vv v8, v12, v10
    vsll.vi v8, v10, 2
    vadd.vv v16, v18, v20
    vadd.vi v20, v20, -5
    vminu.vv v12, v10, v14
    vmin.vv v8, v10, v12
    vadd.vi v14, v8, 7
    vadd.vi v8, v8, 1
    vmax.vv v14, v8, v10
    vadd.vi v8, v10, 5
    vse8.v v18, (a0)
    vsub.vv v12, v10, v8
    vle8.v v10, (a0)
    vsll.vi v8, v10, 2
    vadd.vi v14, v8, 7
    vsll.vi v16, v18, 1
    vadd.vv v16, v18, v20
    vand.vv v12, v10, v8
    vse8.v v16, (a0)
    vsrl.vi v10, v12, 4
    vse8.v v10, (a0)
    vsrl.vi v10, v12, 4
    vsetvli t0, zero, e8, m2, ta, ma
    vadd.vv v15, v6, v14
    vsetvli t0, zero, e8, m1, ta, ma
    vxor.vv v10, v8, v14
    vadd.vv v16, v18, v20
    vadd.vi v8, v10, 5
    vsrl.vi v12, v14, 1
    vadd.vv v12, v8, v14
    vadd.vi v16, v16, 3
    vsub.vv v12, v10, v8
    vxor.vv v10, v8, v14
    vadd.vi v20, v18, -2
    vadd.vx v8, v8, t2
    slli t2, t2, 1
    vadd.vv v16, v18, v20
    vadd.vi v14, v8, 7
    add t2, t2, t3
    vadd.vi v8, v10, 5
    vadd.vv v14, v8, v10

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
    .word 0xedd0ce02
    .word 0xe713f930
    .word 0xc42cd0ba
    .word 0xb9b4c225
    .word 0xb118cad6
    .word 0xdf377ff8
    .word 0x99c6207f
    .word 0xa4dc4d4e

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
