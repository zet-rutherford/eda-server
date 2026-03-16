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

    vle8.v v8, (a0)
    vadd.vi v8, v10, 5
    vmin.vv v8, v10, v12
    vxor.vv v10, v8, v14
    slli t2, t2, 1
    vadd.vi v14, v14, 5
    vsll.vi v14, v8, 3
    vadd.vi v14, v8, 7
    vse8.v v18, (a0)
    srli t3, t3, 1
    vle8.v v8, (a0)
    vse8.v v8, (a0)
    vadd.vi v10, v10, 0
    vle8.v v14, (a0)
    vse8.v v12, (a0)
    vsetvli t0, zero, e8, m8, ta, ma
    vle8.v v7, (a0)
    vsetvli t0, zero, e8, m1, ta, ma
    vsrl.vi v12, v14, 1
    addi t5, zero, -5
    vadd.vi v12, v14, -3
    vadd.vi v12, v14, -3
    vse8.v v8, (a0)
    vsll.vi v16, v18, 1
    vminu.vv v12, v10, v14
    vxor.vv v10, v8, v14
    vsub.vv v8, v14, v10
    vmin.vv v8, v10, v12
    vadd.vi v12, v12, -1
    vsll.vi v14, v8, 3
    vsrl.vi v12, v14, 1
    vadd.vi v8, v10, 5
    slli t2, t2, 1
    vadd.vi v10, v12, -1
    vor.vv v14, v8, v12
    vadd.vv v12, v8, v14
    vadd.vv v12, v8, v14
    vmaxu.vv v8, v12, v10
    vadd.vv v16, v18, v20
    vadd.vi v12, v14, -3
    vsll.vi v8, v10, 2
    vle8.v v12, (a0)
    xor t2, t2, t3
    vsub.vv v18, v20, v16
    vadd.vi v10, v10, 0
    vmin.vv v8, v10, v12
    vse8.v v16, (a0)
    vmaxu.vv v8, v12, v10
    vsub.vv v18, v20, v16
    vsub.vv v18, v20, v16
    vxor.vv v14, v10, v8
    vadd.vi v18, v18, 7
    vadd.vi v16, v16, 3
    vxor.vv v14, v10, v8
    vadd.vi v14, v8, 7
    vor.vv v10, v12, v14
    vadd.vv v14, v8, v10
    vadd.vv v16, v18, v20
    vadd.vi v12, v14, -3
    vse8.v v10, (a0)
    vsub.vv v12, v10, v8
    add t2, t2, t3
    vadd.vi v20, v18, -2
    vadd.vi v10, v10, 0
    nop
    vle8.v v12, (a0)
    vse8.v v18, (a0)
    vmaxu.vv v8, v12, v10
    vadd.vi v12, v12, -1
    vle8.v v10, (a0)
    vor.vv v14, v8, v12
    vadd.vi v20, v20, -5
    vadd.vv v14, v8, v10
    vle8.v v12, (a0)
    addi t2, t2, 1
    vadd.vi v10, v10, 0
    vle8.v v12, (a0)
    vor.vv v16, v18, v20
    vsll.vi v14, v8, 3
    vmin.vv v8, v10, v12
    vadd.vv v8, v10, v12
    add t2, t2, t3
    vse8.v v16, (a0)
    vsub.vv v8, v14, v10
    vadd.vv v8, v10, v12
    vadd.vi v12, v12, -1
    vadd.vx v8, v8, t2
    vadd.vi v10, v12, -1
    vand.vv v20, v16, v18
    vxor.vv v14, v10, v8
    vadd.vx v10, v12, t2
    addi t3, t3, -1
    vsub.vv v12, v10, v8
    vadd.vi v8, v8, 1

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
    .word 0x9e79a6fe
    .word 0x380a402d
    .word 0xd77a80b8
    .word 0x77eb6d89
    .word 0xa452f530
    .word 0xd3c6e5a0
    .word 0x2a31edfd
    .word 0xcda7a451

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
