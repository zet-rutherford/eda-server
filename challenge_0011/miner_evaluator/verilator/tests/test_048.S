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

    vle8.v v16, (a0)
    vand.vv v8, v10, v12
    vsll.vi v14, v8, 3
    vsub.vv v8, v14, v10
    vadd.vi v18, v16, 2
    addi t4, zero, 10
    vsetvli t0, zero, e8, m4, ta, ma
    vmslt.vv v8, v8, v12
    vsetvli t0, zero, e8, m1, ta, ma
    vsll.vi v16, v18, 1
    vle8.v v12, (a0)
    vsub.vv v8, v14, v10
    vse8.v v18, (a0)
    vadd.vx v10, v12, t2
    vadd.vi v18, v16, 2
    slli t2, t2, 1
    addi t5, zero, -5
    vsub.vv v18, v20, v16
    vsll.vi v8, v10, 2
    vadd.vi v8, v10, 5
    vadd.vi v12, v12, -1
    vse8.v v8, (a0)
    vadd.vi v16, v16, 3
    vadd.vi v18, v18, 7
    vsll.vi v16, v18, 1
    vmax.vv v14, v8, v10
    vadd.vx v8, v8, t2
    add t2, t2, t3
    vand.vv v20, v16, v18
    add t4, t4, t5
    vor.vv v14, v8, v12
    add t2, t2, t3
    vadd.vi v16, v16, 3
    vsub.vv v12, v10, v8
    nop
    vadd.vi v8, v8, 1
    vse8.v v16, (a0)
    vadd.vv v16, v18, v20
    vsub.vv v8, v14, v10
    vand.vv v20, v16, v18
    vor.vv v16, v18, v20
    add t4, t4, t5
    vadd.vi v18, v18, 7
    vadd.vi v8, v8, 1
    vle8.v v8, (a0)
    vadd.vx v10, v12, t2
    addi t5, zero, -5
    vse8.v v16, (a0)
    vxor.vv v14, v10, v8
    vadd.vi v14, v8, 7
    vle8.v v12, (a0)
    vmaxu.vv v8, v12, v10
    vadd.vi v10, v10, 0
    vand.vv v8, v10, v12
    addi t2, t2, 1
    vor.vv v14, v8, v12
    vminu.vv v12, v10, v14
    vadd.vv v14, v8, v10
    vsrl.vi v10, v12, 4
    vse8.v v14, (a0)
    vsrl.vi v20, v16, 2
    vand.vv v12, v10, v8
    slli t2, t2, 1
    vxor.vv v14, v10, v8
    add t2, t2, t3
    vor.vv v16, v18, v20
    vand.vv v12, v10, v8
    vle8.v v8, (a0)
    vadd.vi v8, v10, 5
    nop
    vle8.v v8, (a0)
    vadd.vi v10, v10, 0
    vor.vv v14, v8, v12
    vor.vv v16, v18, v20
    vor.vv v10, v12, v14
    vadd.vv v16, v18, v20
    vsll.vi v16, v18, 1
    vsub.vv v12, v10, v8
    vadd.vi v14, v14, 5
    vmaxu.vv v8, v12, v10
    vadd.vi v16, v16, 3
    vle8.v v16, (a0)
    addi t3, t3, -1
    addi t4, zero, 10
    vadd.vv v14, v8, v10
    and t2, t2, t3
    vadd.vi v10, v12, -1
    vmax.vv v14, v8, v10
    vle8.v v12, (a0)
    vle8.v v18, (a0)
    srli t3, t3, 1
    vand.vv v20, v16, v18
    vsll.vi v16, v18, 1
    vse8.v v18, (a0)
    vadd.vi v10, v12, -1
    vsub.vv v10, v12, v14

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
    .word 0x568a220d
    .word 0x42c91aaf
    .word 0xc3c5bbb5
    .word 0x23a86b61
    .word 0xbbdf144c
    .word 0xe0d65081
    .word 0x3c5168b0
    .word 0x090d7d2f

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
