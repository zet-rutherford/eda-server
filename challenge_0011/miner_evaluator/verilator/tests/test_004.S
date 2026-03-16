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
    vadd.vv v12, v8, v14
    vle8.v v12, (a0)
    vadd.vi v20, v20, -5
    vadd.vi v16, v16, 3
    vadd.vi v14, v14, 5
    vse8.v v18, (a0)
    vsll.vi v8, v10, 2
    vsub.vv v18, v20, v16
    vadd.vi v20, v20, -5
    vse8.v v12, (a0)
    vadd.vi v20, v20, -5
    vle8.v v14, (a0)
    vsetvli t0, zero, e8, m4, ta, ma
    vmslt.vv v8, v8, v12
    vsetvli t0, zero, e8, m1, ta, ma
    vadd.vi v16, v16, 3
    vadd.vv v14, v8, v10
    vsll.vi v8, v10, 2
    vsub.vv v8, v14, v10
    vadd.vi v14, v14, 5
    vsub.vv v8, v14, v10
    vadd.vi v12, v12, -1
    vsub.vv v18, v20, v16
    vadd.vi v10, v10, 0
    vadd.vi v8, v10, 5
    vmin.vv v8, v10, v12
    vsrl.vi v12, v14, 1
    vadd.vi v8, v8, 1
    vadd.vi v20, v18, -2
    vle8.v v10, (a0)
    vsrl.vi v10, v12, 4
    vadd.vv v0, v2, v8, v0.t
    vadd.vv v8, v10, v12
    vadd.vi v18, v16, 2
    vand.vv v8, v10, v12
    or t3, t2, t3
    vsub.vv v18, v20, v16
    vand.vv v8, v10, v12
    srli t3, t3, 1
    vadd.vi v14, v14, 5
    vsub.vv v18, v20, v16
    vse8.v v16, (a0)
    vadd.vi v14, v8, 7
    srli t3, t3, 1
    vse8.v v12, (a0)
    vslide1up.vx v2, v2, t2
    vadd.vi v12, v14, -3
    vadd.vi v12, v14, -3
    vadd.vv v12, v8, v14
    vsrl.vi v12, v14, 1
    vadd.vi v10, v10, 0
    vadd.vv v16, v18, v20
    li t2, 1
    csrw vstart, t2
    vredsum.vs v0, v1, v0
    vadd.vv v12, v8, v14
    vadd.vi v20, v20, -5
    vsub.vv v12, v10, v8
    vsll.vi v8, v10, 2
    vand.vv v20, v16, v18
    addi t2, t2, 1
    and t2, t2, t3
    vadd.vi v18, v18, 7
    vse16.v v23, (a0)
    vadd.vi v14, v14, 5
    vmax.vv v14, v8, v10
    vadd.vi v18, v16, 2
    vsrl.vi v10, v12, 4
    vadd.vi v14, v8, 7
    vxor.vv v14, v10, v8
    vse8.v v18, (a0)
    vmaxu.vv v8, v12, v10
    vadd.vv v12, v8, v14
    vsub.vv v10, v12, v14
    vle8.v v18, (a0)
    vadd.vi v8, v10, 5
    vse8.v v14, (a0)
    vle8.v v12, (a0)
    vadd.vv v12, v8, v14
    vse8.v v8, (a0)
    vadd.vi v8, v8, 1
    vmin.vv v8, v10, v12
    vmaxu.vv v8, v12, v10
    vsrl.vi v20, v16, 2
    vsub.vv v18, v20, v16
    vsub.vv v10, v12, v14
    vadd.vi v14, v8, 7
    vsrl.vi v12, v14, 1
    vxor.vv v10, v8, v14
    vadd.vi v8, v10, 5
    vadd.vi v8, v10, 5
    vsll.vi v14, v8, 3

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
    .word 0xe746ccb9
    .word 0x0bc61066
    .word 0xcbd00ef2
    .word 0x4b1a269b
    .word 0x5ff595ea
    .word 0x25440fe0
    .word 0x87fa841a
    .word 0xcae28e66

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
