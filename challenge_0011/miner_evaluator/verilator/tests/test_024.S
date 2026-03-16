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

    vadd.vv v16, v18, v20
    vle8.v v18, (a0)
    vminu.vv v12, v10, v14
    vsub.vv v18, v20, v16
    vadd.vx v10, v12, t2
    addi t2, t2, 1
    vadd.vv v8, v10, v12
    vxor.vv v14, v10, v8
    vand.vv v12, v10, v8
    vor.vv v14, v8, v12
    slli t2, t2, 1
    vsub.vv v18, v20, v16
    vadd.vx v8, v8, t2
    vadd.vi v12, v12, -1
    vsub.vv v10, v12, v14
    vslide1up.vx v10, v10, t2
    vsrl.vi v10, v12, 4
    vadd.vi v16, v16, 3
    vor.vv v16, v18, v20
    vsub.vv v10, v12, v14
    vadd.vi v14, v14, 5
    vsub.vv v10, v12, v14
    vadd.vi v14, v8, 7
    vadd.vi v8, v8, 1
    vse8.v v12, (a0)
    vsrl.vi v20, v16, 2
    vand.vv v12, v10, v8
    xor t2, t2, t3
    vsrl.vi v12, v14, 1
    vadd.vi v12, v12, -1
    addi t2, t2, 1
    vadd.vv v12, v8, v14
    vadd.vi v14, v14, 5
    vle8.v v16, (a0)
    vle8.v v18, (a0)
    vadd.vi v18, v16, 2
    vse8.v v12, (a0)
    vadd.vv v14, v8, v10
    vand.vv v12, v10, v8
    vxor.vv v10, v8, v14
    add t4, t4, t5
    vadd.vx v10, v12, t2
    vxor.vv v10, v8, v14
    vse8.v v14, (a0)
    vxor.vv v10, v8, v14
    vmaxu.vv v8, v12, v10
    vand.vv v20, v16, v18
    vadd.vx v10, v12, t2
    vmaxu.vv v8, v12, v10
    vle8.v v12, (a0)
    vadd.vv v12, v8, v14
    add t2, t2, t3
    add t4, t4, t5
    vse8.v v8, (a0)
    vadd.vi v14, v14, 5
    vadd.vi v12, v14, -3
    vand.vv v12, v10, v8
    vse8.v v8, (a0)
    vse8.v v14, (a0)
    vadd.vi v18, v16, 2
    vsub.vv v18, v20, v16
    addi t4, zero, 10
    vadd.vx v8, v8, t2
    vadd.vi v20, v20, -5
    vadd.vi v14, v8, 7
    vsll.vi v8, v10, 2
    vadd.vi v20, v18, -2
    vor.vv v10, v12, v14
    vle8.v v12, (a0)
    vsub.vv v10, v12, v14
    vle8.v v8, (a0)
    vadd.vi v20, v20, -5
    vxor.vv v10, v8, v14
    vse8.v v12, (a0)
    vadd.vx v10, v12, t2
    vsll.vi v16, v18, 1
    vadd.vi v20, v20, -5
    vsub.vv v8, v14, v10
    vadd.vi v18, v18, 7
    vsub.vv v10, v12, v14
    vse8.v v8, (a0)
    vmaxu.vv v8, v12, v10
    vadd.vi v12, v12, -1
    vor.vv v14, v8, v12
    vadd.vi v12, v14, -3
    vsll.vi v8, v10, 2
    vadd.vi v10, v10, 0
    vor.vv v10, v12, v14
    vadd.vi v8, v10, 5
    vsrl.vi v20, v16, 2
    vxor.vv v10, v8, v14
    vadd.vi v20, v20, -5
    vsrl.vi v12, v14, 1
    vsrl.vi v10, v12, 4
    addi t4, zero, 10
    vmax.vv v14, v8, v10
    vsub.vv v18, v20, v16

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
    .word 0xa1c16b96
    .word 0x9c02040d
    .word 0xb565f64e
    .word 0xfab0a15d
    .word 0x00679b62
    .word 0x0623ffbf
    .word 0xd91b1a04
    .word 0xffbd9cdd

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
