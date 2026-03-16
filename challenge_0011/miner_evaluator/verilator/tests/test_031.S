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

    vsll.vi v14, v8, 3
    vadd.vx v10, v12, t2
    vsub.vv v12, v10, v8
    vmaxu.vv v8, v12, v10
    vadd.vi v12, v14, -3
    vsub.vv v18, v20, v16
    vadd.vi v18, v16, 2
    vadd.vv v16, v18, v20
    vand.vv v20, v16, v18
    vse8.v v8, (a0)
    vmaxu.vv v8, v12, v10
    vmax.vv v14, v8, v10
    vsrl.vi v12, v14, 1
    vadd.vv v14, v8, v10
    vsub.vv v12, v10, v8
    vadd.vi v18, v18, 7
    vse8.v v16, (a0)
    vadd.vi v8, v10, 5
    vmax.vv v14, v8, v10
    vand.vv v8, v10, v12
    sub t3, t2, t3
    vadd.vi v18, v18, 7
    vse8.v v18, (a0)
    vse8.v v8, (a0)
    vle8.v v12, (a0)
    vse8.v v10, (a0)
    vse8.v v16, (a0)
    vadd.vi v16, v16, 3
    vsll.vi v8, v10, 2
    vse8.v v14, (a0)
    vsrl.vi v10, v12, 4
    vmaxu.vv v8, v12, v10
    vadd.vi v8, v10, 5
    vadd.vi v8, v10, 5
    vor.vv v10, v12, v14
    vmin.vv v8, v10, v12
    and t2, t2, t3
    vadd.vi v12, v12, -1
    addi t5, zero, -5
    vor.vv v14, v8, v12
    and t2, t2, t3
    vle8.v v18, (a0)
    vxor.vv v14, v10, v8
    vxor.vv v10, v8, v14
    vadd.vi v18, v18, 7
    vse8.v v10, (a0)
    addi t4, zero, 10
    vor.vv v10, v12, v14
    vor.vv v14, v8, v12
    vsll.vi v14, v8, 3
    vsll.vi v14, v8, 3
    vadd.vi v18, v16, 2
    vsetvli t0, zero, e8, m2, ta, ma
    vadd.vv v10, v7, v12
    vsetvli t0, zero, e8, m1, ta, ma
    srli t3, t3, 1
    vadd.vi v20, v18, -2
    addi t2, t2, 1
    vor.vv v16, v18, v20
    vadd.vi v16, v16, 3
    vadd.vx v8, v8, t2
    vadd.vi v18, v16, 2
    vadd.vi v12, v12, -1
    vsrl.vi v20, v16, 2
    vle8.v v14, (a0)
    vadd.vv v12, v8, v14
    addi t5, zero, -5
    vadd.vi v12, v12, -1
    vor.vv v14, v8, v12
    vadd.vi v10, v10, 0
    vadd.vx v10, v12, t2
    addi t4, zero, 10
    sub t3, t2, t3
    vle8.v v14, (a0)
    vse8.v v8, (a0)
    vadd.vi v12, v12, -1
    vsub.vv v10, v12, v14
    and t2, t2, t3
    vse8.v v8, (a0)
    vsll.vi v8, v10, 2
    vsub.vv v8, v14, v10
    vsub.vv v18, v20, v16
    vand.vv v8, v10, v12
    vxor.vv v10, v8, v14
    vsll.vi v14, v8, 3
    vadd.vi v10, v10, 0
    vxor.vv v10, v8, v14
    vsub.vv v12, v10, v8
    addi t4, zero, 10
    vadd.vi v12, v14, -3
    vadd.vi v18, v18, 7
    vor.vv v16, v18, v20
    addi t3, t3, -1
    addi t3, t3, -1
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
    .word 0x6c412493
    .word 0x24ef65a7
    .word 0x2cd6e8df
    .word 0xf84ce7a9
    .word 0x708175fd
    .word 0x96e83922
    .word 0xf2deb798
    .word 0x6c7ceeb7

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
