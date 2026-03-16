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

    add t2, t2, t3
    vmaxu.vv v8, v12, v10
    vle8.v v18, (a0)
    vadd.vi v8, v8, 1
    vadd.vi v10, v10, 0
    vminu.vv v12, v10, v14
    vadd.vi v18, v16, 2
    vxor.vv v10, v8, v14
    vle8.v v14, (a0)
    vmax.vv v14, v8, v10
    addi t4, zero, 10
    vadd.vi v8, v8, 1
    vmin.vv v8, v10, v12
    vadd.vi v12, v12, -1
    vse8.v v8, (a0)
    add t4, t4, t5
    vadd.vi v18, v18, 7
    vadd.vi v14, v14, 5
    vadd.vx v8, v8, t2
    vadd.vi v18, v18, 7
    vadd.vv v12, v8, v14
    vadd.vv v14, v8, v10
    vsrl.vi v12, v14, 1
    vxor.vv v10, v8, v14
    vse8.v v18, (a0)
    vmin.vv v8, v10, v12
    vor.vv v10, v12, v14
    vmax.vv v14, v8, v10
    vadd.vi v14, v14, 5
    vsrl.vi v10, v12, 4
    vle8.v v8, (a0)
    vadd.vi v12, v14, -3
    vse8.v v10, (a0)
    vadd.vx v10, v12, t2
    vadd.vi v14, v8, 7
    vadd.vi v20, v18, -2
    srli t3, t3, 1
    vxor.vv v14, v10, v8
    vsrl.vi v20, v16, 2
    addi t5, zero, -5
    vadd.vi v8, v8, 1
    vle8.v v18, (a0)
    vadd.vi v14, v14, 5
    vadd.vv v8, v10, v12
    vslide1up.vx v4, v4, t2
    add t4, t4, t5
    vor.vv v14, v8, v12
    vadd.vi v18, v16, 2
    or t3, t2, t3
    vadd.vi v10, v12, -1
    vsub.vv v18, v20, v16
    vsrl.vi v20, v16, 2
    vmaxu.vv v8, v12, v10
    vadd.vi v12, v14, -3
    vadd.vx v8, v8, t2
    vsll.vi v14, v8, 3
    vadd.vi v18, v18, 7
    vle8.v v12, (a0)
    vadd.vi v14, v8, 7
    vsub.vv v8, v14, v10
    vand.vv v20, v16, v18
    vadd.vi v20, v20, -5
    vse8.v v12, (a0)
    vsub.vv v18, v20, v16
    vsub.vv v8, v14, v10
    and t2, t2, t3
    vse8.v v10, (a0)
    vsll.vi v16, v18, 1
    vse8.v v10, (a0)
    vsub.vv v18, v20, v16
    vse8.v v12, (a0)
    vand.vv v20, v16, v18
    vsub.vv v18, v20, v16
    vadd.vi v14, v14, 5
    vxor.vv v10, v8, v14
    vxor.vv v14, v10, v8
    and t2, t2, t3
    and t2, t2, t3
    slli t2, t2, 1
    vsub.vv v18, v20, v16
    vadd.vi v16, v16, 3
    vle8.v v16, (a0)
    vminu.vv v12, v10, v14
    vsub.vv v10, v12, v14
    vadd.vi v14, v14, 5
    vadd.vi v12, v12, -1
    vse8.v v16, (a0)
    addi t2, t2, 1
    vmax.vv v14, v8, v10
    vxor.vv v10, v8, v14
    vadd.vi v12, v14, -3
    add t4, t4, t5
    vmax.vv v14, v8, v10
    vsll.vi v16, v18, 1
    vadd.vx v10, v12, t2
    vle8.v v14, (a0)
    vand.vv v8, v10, v12
    vadd.vi v18, v16, 2
    srli t3, t3, 1
    add t4, t4, t5
    addi t4, zero, 10
    nop
    vadd.vi v8, v10, 5
    vse8.v v12, (a0)
    vsll.vi v8, v10, 2
    vsub.vv v12, v10, v8
    vsub.vv v12, v10, v8
    add t4, t4, t5
    vadd.vi v14, v8, 7
    vadd.vv v12, v8, v14

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
    .word 0x6a0aa7d5
    .word 0x73b5bad5
    .word 0x17d50f59
    .word 0x5e7b72c8
    .word 0xf343d9eb
    .word 0xbb93cd40
    .word 0x88d00abd
    .word 0x363be5cb

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
