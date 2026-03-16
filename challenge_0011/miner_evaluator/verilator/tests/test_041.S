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

    vadd.vi v20, v20, -5
    vadd.vi v18, v18, 7
    vsub.vv v12, v10, v8
    vadd.vi v12, v12, -1
    vadd.vi v10, v12, -1
    vadd.vx v10, v12, t2
    vxor.vv v10, v8, v14
    vadd.vv v12, v8, v14
    vor.vv v14, v8, v12
    vsll.vi v8, v10, 2
    vand.vv v12, v10, v8
    vadd.vi v16, v16, 3
    vand.vv v20, v16, v18
    vadd.vi v10, v10, 0
    vsrl.vi v10, v12, 4
    vadd.vi v12, v12, -1
    vadd.vi v20, v20, -5
    and t2, t2, t3
    vle8.v v10, (a0)
    vadd.vi v10, v10, 0
    vxor.vv v10, v8, v14
    vmin.vv v8, v10, v12
    vadd.vv v12, v8, v14
    addi t3, t3, -1
    vxor.vv v14, v10, v8
    vadd.vi v8, v10, 5
    vadd.vi v12, v14, -3
    vsll.vi v14, v8, 3
    vsub.vv v18, v20, v16
    vse8.v v10, (a0)
    vsrl.vi v12, v14, 1
    addi t3, t3, -1
    vadd.vx v10, v12, t2
    vmaxu.vv v8, v12, v10
    nop
    vadd.vi v18, v16, 2
    vadd.vi v8, v8, 1
    vsub.vv v12, v10, v8
    vle8.v v16, (a0)
    vsub.vv v12, v10, v8
    vle8.v v18, (a0)
    vand.vv v8, v10, v12
    vsrl.vi v20, v16, 2
    vadd.vi v14, v8, 7
    vadd.vi v10, v10, 0
    vsub.vv v8, v14, v10
    vmax.vv v14, v8, v10
    vand.vv v20, v16, v18
    xor t2, t2, t3
    vxor.vv v14, v10, v8
    vxor.vv v10, v8, v14
    vadd.vi v10, v10, 0
    vxor.vv v10, v8, v14
    vse8.v v18, (a0)
    addi t3, t3, -1
    addi t2, t2, 1
    vse8.v v8, (a0)
    vsub.vv v18, v20, v16
    vadd.vv v8, v10, v12
    vadd.vi v12, v12, -1
    vsub.vv v12, v10, v8
    vrgather.vv v8, v8, v10
    vadd.vi v18, v16, 2
    vadd.vi v8, v8, 1
    vle8.v v14, (a0)
    vadd.vv v8, v10, v12
    vadd.vi v18, v16, 2
    vadd.vi v14, v8, 7
    vor.vv v16, v18, v20
    vsub.vv v10, v12, v14
    vadd.vx v10, v12, t2
    vor.vv v16, v18, v20
    vsub.vv v8, v14, v10
    vle8.v v12, (a0)
    vand.vv v8, v10, v12
    vmaxu.vv v8, v12, v10
    addi t3, t3, -1
    vadd.vi v14, v8, 7
    vadd.vi v12, v14, -3
    slli t2, t2, 1
    sub t3, t2, t3
    vse8.v v16, (a0)
    vsll.vi v14, v8, 3
    vand.vv v20, v16, v18
    vsub.vv v10, v12, v14
    vsll.vi v16, v18, 1
    vand.vv v8, v10, v12
    vsll.vi v16, v18, 1
    vsll.vi v14, v8, 3
    vse8.v v10, (a0)
    vsub.vv v8, v14, v10
    vadd.vv v8, v10, v12
    vse8.v v14, (a0)
    srli t3, t3, 1
    vadd.vi v10, v10, 0
    vse8.v v14, (a0)
    vse8.v v16, (a0)
    slli t2, t2, 1
    vsll.vi v14, v8, 3
    vsub.vv v8, v14, v10
    vsll.vi v8, v10, 2
    vadd.vi v14, v14, 5
    or t3, t2, t3
    vadd.vv v8, v10, v12
    vand.vv v12, v10, v8
    vse8.v v8, (a0)
    vse8.v v12, (a0)
    vmin.vv v8, v10, v12
    vadd.vx v10, v12, t2
    slli t2, t2, 1
    vsll.vi v8, v10, 2
    vse8.v v14, (a0)
    vsub.vv v12, v10, v8
    vadd.vi v8, v8, 1
    vmaxu.vv v8, v12, v10
    vle8.v v10, (a0)
    vsub.vv v12, v10, v8

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
    .word 0x27d19990
    .word 0x80000fac
    .word 0x3c8b966c
    .word 0x57968d64
    .word 0xbcc8509b
    .word 0x6f302743
    .word 0x4a1a7c2e
    .word 0x7c65dbfb

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
