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

    sub t3, t2, t3
    nop
    vadd.vx v8, v8, t2
    vadd.vi v8, v10, 5
    vsub.vv v10, v12, v14
    vadd.vi v18, v18, 7
    vse8.v v14, (a0)
    vand.vv v20, v16, v18
    vse8.v v14, (a0)
    vse8.v v18, (a0)
    vse8.v v12, (a0)
    vadd.vv v16, v18, v20
    vsub.vv v8, v14, v10
    vsub.vv v12, v10, v8
    vse8.v v16, (a0)
    vsrl.vi v10, v12, 4
    vmaxu.vv v8, v12, v10
    vadd.vi v20, v20, -5
    vadd.vi v14, v8, 7
    or t3, t2, t3
    vadd.vi v14, v14, 5
    vle8.v v18, (a0)
    vand.vv v20, v16, v18
    add t4, t4, t5
    vsrl.vi v10, v12, 4
    vadd.vi v20, v18, -2
    vand.vv v12, v10, v8
    add t4, t4, t5
    or t3, t2, t3
    vsub.vv v12, v10, v8
    vsub.vv v8, v14, v10
    vsrl.vi v20, v16, 2
    vadd.vi v12, v14, -3
    vadd.vi v18, v18, 7
    vadd.vi v10, v10, 0
    vadd.vi v18, v16, 2
    nop
    vadd.vv v8, v10, v12
    vse8.v v12, (a0)
    vse8.v v16, (a0)
    vse8.v v8, (a0)
    vadd.vx v10, v12, t2
    vadd.vi v10, v12, -1
    vle8.v v8, (a0)
    vsrl.vi v12, v14, 1
    vsub.vv v10, v12, v14
    vadd.vi v14, v14, 5
    vse8.v v16, (a0)
    vxor.vv v14, v10, v8
    vmaxu.vv v8, v12, v10
    nop
    vsrl.vi v12, v14, 1
    vand.vv v8, v10, v12
    vmaxu.vv v8, v12, v10
    vsrl.vi v10, v12, 4
    vand.vv v8, v10, v12
    vse8.v v8, (a0)
    vadd.vi v14, v14, 5
    vsrl.vi v20, v16, 2
    vminu.vv v12, v10, v14
    vadd.vi v18, v16, 2
    vand.vv v12, v10, v8
    add t2, t2, t3
    vor.vv v14, v8, v12
    add t2, t2, t3
    vadd.vi v12, v14, -3
    vadd.vi v12, v12, -1
    and t2, t2, t3
    vle8.v v18, (a0)
    vse8.v v14, (a0)
    vadd.vv v12, v8, v14
    vse8.v v10, (a0)
    vsrl.vi v20, v16, 2
    vsll.vi v14, v8, 3
    vadd.vi v20, v18, -2
    vsrl.vi v10, v12, 4
    vsub.vv v8, v14, v10
    vand.vv v20, v16, v18
    srli t3, t3, 1
    vxor.vv v10, v8, v14
    sub t3, t2, t3
    vadd.vv v0, v6, v4, v0.t
    vadd.vi v20, v18, -2
    vadd.vv v8, v10, v12
    vse8.v v10, (a0)
    vsll.vi v16, v18, 1
    vadd.vi v14, v8, 7
    vsrl.vi v10, v12, 4
    vadd.vi v12, v14, -3
    add t4, t4, t5
    srli t3, t3, 1
    vminu.vv v12, v10, v14
    vand.vv v20, v16, v18
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
    .word 0xa6ca8d50
    .word 0x189099c9
    .word 0x88802d4d
    .word 0xa07eafb1
    .word 0xaf76b6c2
    .word 0xd5ee2587
    .word 0xafa08cbe
    .word 0x0614ac41

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
