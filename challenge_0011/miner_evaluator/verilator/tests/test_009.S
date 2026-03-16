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

    nop
    vsrl.vi v10, v12, 4
    vsrl.vi v10, v12, 4
    add t2, t2, t3
    vand.vv v20, v16, v18
    vsll.vi v14, v8, 3
    vse8.v v12, (a0)
    vadd.vi v14, v8, 7
    or t3, t2, t3
    vse8.v v8, (a0)
    vadd.vv v16, v18, v20
    addi t2, t2, 1
    vadd.vi v10, v12, -1
    vadd.vi v8, v8, 1
    li t2, 1
    csrw vstart, t2
    vcompress.vm v4, v2, v1
    vle8.v v8, (a0)
    vand.vv v12, v10, v8
    vsrl.vi v12, v14, 1
    vle8.v v16, (a0)
    vadd.vi v20, v18, -2
    vsll.vi v16, v18, 1
    vadd.vi v12, v14, -3
    vle8.v v10, (a0)
    vmin.vv v8, v10, v12
    vminu.vv v12, v10, v14
    srli t3, t3, 1
    vsub.vv v10, v12, v14
    vle8.v v12, (a0)
    vadd.vv v16, v18, v20
    vadd.vi v20, v20, -5
    vsub.vv v12, v10, v8
    vsll.vi v16, v18, 1
    vadd.vi v8, v8, 1
    vsll.vi v14, v8, 3
    vand.vv v20, v16, v18
    vadd.vi v18, v16, 2
    vsll.vi v14, v8, 3
    vadd.vv v14, v8, v10
    vadd.vi v12, v14, -3
    vadd.vi v18, v18, 7
    vsrl.vi v20, v16, 2
    vse8.v v14, (a0)
    vadd.vi v18, v18, 7
    vand.vv v8, v10, v12
    vadd.vx v10, v12, t2
    vsll.vi v16, v18, 1
    vmaxu.vv v8, v12, v10
    vadd.vi v14, v8, 7
    vse8.v v18, (a0)
    vle8.v v8, (a0)
    vadd.vi v10, v10, 0
    vor.vv v10, v12, v14
    vsll.vi v16, v18, 1
    vand.vv v8, v10, v12
    vor.vv v16, v18, v20
    vadd.vv v16, v18, v20
    vsrl.vi v10, v12, 4
    vadd.vx v8, v8, t2
    vmin.vv v8, v10, v12
    vadd.vi v10, v12, -1
    vand.vv v12, v10, v8
    vsll.vi v8, v10, 2
    vxor.vv v14, v10, v8
    vsll.vi v14, v8, 3
    vor.vv v10, v12, v14
    vsub.vv v18, v20, v16
    vadd.vi v20, v18, -2
    vsll.vi v8, v10, 2
    addi t4, zero, 10
    vmaxu.vv v8, v12, v10
    vadd.vi v8, v8, 1
    vadd.vv v12, v8, v14
    and t2, t2, t3
    vxor.vv v10, v8, v14
    vadd.vi v14, v14, 5
    vadd.vv v16, v18, v20
    srli t3, t3, 1
    srli t3, t3, 1
    vsub.vv v12, v10, v8
    vse8.v v18, (a0)
    addi t2, t2, 1
    vor.vv v16, v18, v20
    sub t3, t2, t3
    vse8.v v12, (a0)
    vadd.vv v16, v18, v20
    vle8.v v12, (a0)
    vle8.v v16, (a0)
    vadd.vv v16, v18, v20
    vand.vv v12, v10, v8
    vsrl.vi v12, v14, 1
    vand.vv v8, v10, v12
    vxor.vv v14, v10, v8
    vsub.vv v10, v12, v14
    vsub.vv v8, v14, v10
    vsub.vv v8, v14, v10
    vsub.vv v10, v12, v14
    vadd.vi v8, v8, 1
    vsub.vv v8, v14, v10
    vsrl.vi v12, v14, 1
    vadd.vv v8, v10, v12
    vadd.vi v8, v10, 5
    vmin.vv v8, v10, v12
    addi t5, zero, -5
    vsub.vv v18, v20, v16
    vsub.vv v12, v10, v8
    vand.vv v12, v10, v8
    vmin.vv v8, v10, v12
    slli t2, t2, 1
    vsub.vv v8, v14, v10
    vse8.v v10, (a0)
    vadd.vi v16, v16, 3
    vand.vv v12, v10, v8
    vsrl.vi v20, v16, 2
    vadd.vi v12, v12, -1
    vxor.vv v10, v8, v14

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
    .word 0x186b2880
    .word 0xfb4fb88a
    .word 0x7a3a6e96
    .word 0xef9240b6
    .word 0x01bf9e73
    .word 0x6231ee73
    .word 0x546252e7
    .word 0x92a81713

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
