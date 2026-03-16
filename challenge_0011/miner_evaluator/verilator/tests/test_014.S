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

    vadd.vi v16, v16, 3
    vand.vv v20, v16, v18
    vand.vv v8, v10, v12
    nop
    vsub.vv v10, v12, v14
    vse8.v v14, (a0)
    vsll.vi v14, v8, 3
    vadd.vi v20, v18, -2
    vminu.vv v12, v10, v14
    addi t4, zero, 10
    vnsrl.wi v5, v4, 0
    vadd.vi v14, v8, 7
    vadd.vi v18, v18, 7
    vand.vv v12, v10, v8
    vadd.vi v18, v16, 2
    vadd.vi v14, v8, 7
    vse8.v v12, (a0)
    vle8.v v16, (a0)
    vadd.vv v8, v10, v12
    vadd.vv v8, v10, v12
    vsll.vi v14, v8, 3
    vle8.v v16, (a0)
    vadd.vi v10, v10, 0
    vand.vv v8, v10, v12
    vadd.vv v12, v8, v14
    vxor.vv v10, v8, v14
    vle8.v v14, (a0)
    vor.vv v16, v18, v20
    vminu.vv v12, v10, v14
    vxor.vv v10, v8, v14
    vand.vv v20, v16, v18
    vse8.v v12, (a0)
    vle8.v v18, (a0)
    vse8.v v16, (a0)
    and t2, t2, t3
    vadd.vi v8, v8, 1
    vsrl.vi v10, v12, 4
    vsll.vi v8, v10, 2
    vle8.v v14, (a0)
    vle8.v v18, (a0)
    vle8.v v10, (a0)
    slli t2, t2, 1
    vadd.vi v18, v16, 2
    vor.vv v10, v12, v14
    vadd.vx v8, v8, t2
    addi t3, t3, -1
    vse8.v v16, (a0)
    vadd.vi v20, v20, -5
    vse8.v v10, (a0)
    vse8.v v18, (a0)
    or t3, t2, t3
    vand.vv v8, v10, v12
    nop
    vadd.vv v14, v8, v10
    vadd.vi v14, v14, 5
    vadd.vi v20, v18, -2
    slli t2, t2, 1
    vle8.v v12, (a0)
    vle8.v v8, (a0)
    vxor.vv v14, v10, v8
    xor t2, t2, t3
    vsrl.vi v20, v16, 2
    vxor.vv v10, v8, v14
    vadd.vi v10, v12, -1
    vle8.v v10, (a0)
    addi t5, zero, -5
    vsub.vv v12, v10, v8
    vmin.vv v8, v10, v12
    vse8.v v14, (a0)
    vle8.v v18, (a0)
    vadd.vi v8, v8, 1
    vmaxu.vv v8, v12, v10
    vsub.vv v8, v14, v10
    vsub.vv v8, v14, v10
    slli t2, t2, 1
    vsub.vv v10, v12, v14
    vadd.vi v14, v8, 7
    vsub.vv v18, v20, v16
    vadd.vi v20, v18, -2
    vxor.vv v10, v8, v14
    add t2, t2, t3
    vor.vv v16, v18, v20
    nop
    vmaxu.vv v8, v12, v10
    vmax.vv v14, v8, v10
    vsub.vv v18, v20, v16
    vadd.vi v16, v16, 3
    vmaxu.vv v8, v12, v10
    addi t2, t2, 1
    vxor.vv v14, v10, v8
    vsll.vi v8, v10, 2
    vse8.v v14, (a0)
    vadd.vi v18, v18, 7
    vadd.vi v8, v10, 5
    sub t3, t2, t3
    nop
    vand.vv v8, v10, v12
    vmaxu.vv v8, v12, v10
    vsub.vv v8, v14, v10
    addi t4, zero, 10
    vmax.vv v14, v8, v10
    vse8.v v18, (a0)
    vadd.vi v16, v16, 3

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
    .word 0x904883c1
    .word 0x4f1e1a37
    .word 0x7d8d3ddd
    .word 0x171b1b80
    .word 0x3803dcee
    .word 0x86c5547c
    .word 0x002ccb25
    .word 0x2167c35e

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
