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

    vand.vv v8, v10, v12
    vadd.vx v8, v8, t2
    vadd.vi v8, v8, 1
    vsll.vi v14, v8, 3
    vsrl.vi v20, v16, 2
    vxor.vv v14, v10, v8
    add t2, t2, t3
    vadd.vx v8, v8, t2
    vadd.vi v20, v20, -5
    vadd.vi v20, v18, -2
    vor.vv v10, v12, v14
    vadd.vi v20, v20, -5
    vxor.vv v10, v8, v14
    vor.vv v16, v18, v20
    vor.vv v14, v8, v12
    vadd.vi v12, v14, -3
    vand.vv v20, v16, v18
    srli t3, t3, 1
    vse8.v v10, (a0)
    vor.vv v10, v12, v14
    vsub.vv v18, v20, v16
    vle8.v v16, (a0)
    vand.vv v8, v10, v12
    vand.vv v20, v16, v18
    vadd.vi v16, v16, 3
    vse8.v v14, (a0)
    vadd.vv v14, v8, v10
    vadd.vv v8, v10, v12
    vadd.vi v18, v18, 7
    vse8.v v12, (a0)
    vor.vv v14, v8, v12
    vand.vv v8, v10, v12
    vor.vv v14, v8, v12
    vadd.vv v16, v18, v20
    add t2, t2, t3
    vadd.vi v10, v10, 0
    vmaxu.vv v8, v12, v10
    vmaxu.vv v8, v12, v10
    vadd.vi v18, v16, 2
    vse8.v v10, (a0)
    vle8.v v16, (a0)
    vsub.vv v12, v10, v8
    vxor.vv v14, v10, v8
    vsll.vi v14, v8, 3
    vadd.vi v18, v16, 2
    vmaxu.vv v8, v12, v10
    or t3, t2, t3
    sub t3, t2, t3
    vadd.vi v12, v14, -3
    vse8.v v16, (a0)
    vadd.vv v14, v8, v10
    addi t3, t3, -1
    vle8.v v8, (a0)
    vand.vv v8, v10, v12
    addi t2, t2, 1
    .word 0x6C110257
    sub t3, t2, t3
    vand.vv v8, v10, v12
    vse8.v v8, (a0)
    add t4, t4, t5
    vadd.vi v16, v16, 3
    vsrl.vi v10, v12, 4
    vadd.vv v12, v8, v14
    vor.vv v16, v18, v20
    and t2, t2, t3
    srli t3, t3, 1
    vsub.vv v8, v14, v10
    vadd.vi v12, v12, -1
    vand.vv v8, v10, v12
    vmaxu.vv v8, v12, v10
    vsrl.vi v10, v12, 4
    vadd.vi v10, v10, 0
    vse8.v v12, (a0)
    vadd.vv v16, v18, v20
    sub t3, t2, t3
    vadd.vv v12, v8, v14
    vand.vv v8, v10, v12
    vadd.vi v10, v10, 0
    vsub.vv v12, v10, v8
    vadd.vi v10, v12, -1
    addi t5, zero, -5
    vse8.v v14, (a0)
    vxor.vv v10, v8, v14
    vand.vv v12, v10, v8
    addi t5, zero, -5
    vsub.vv v10, v12, v14
    vand.vv v12, v10, v8
    vadd.vi v20, v18, -2
    sub t3, t2, t3
    vmin.vv v8, v10, v12
    vadd.vv v8, v10, v12
    sub t3, t2, t3
    vadd.vi v12, v14, -3
    vadd.vv v16, v18, v20
    vor.vv v10, v12, v14
    vadd.vi v14, v8, 7
    vsrl.vi v12, v14, 1
    vadd.vi v18, v16, 2

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
    .word 0xa6129a1c
    .word 0x4ef4c34d
    .word 0xe1fff6c0
    .word 0x774c0afa
    .word 0xb8f0188e
    .word 0x340029c3
    .word 0x501ba851
    .word 0xdd34aa18

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
