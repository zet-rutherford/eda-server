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

    vadd.vi v12, v12, -1
    vadd.vi v12, v14, -3
    vse8.v v18, (a0)
    vadd.vi v18, v16, 2
    vse8.v v10, (a0)
    vadd.vv v12, v8, v14
    vse8.v v8, (a0)
    vsub.vv v10, v12, v14
    vor.vv v10, v12, v14
    vadd.vi v8, v10, 5
    vadd.vi v20, v18, -2
    vadd.vi v10, v10, 0
    vadd.vi v14, v8, 7
    vsub.vv v8, v14, v10
    vadd.vv v14, v8, v10
    or t3, t2, t3
    vadd.vi v10, v10, 0
    vadd.vi v14, v8, 7
    nop
    vle8.v v8, (a0)
    vxor.vv v14, v10, v8
    slli t2, t2, 1
    vxor.vv v14, v10, v8
    addi t5, zero, -5
    or t3, t2, t3
    addi t3, t3, -1
    vsll.vi v8, v10, 2
    vadd.vi v8, v8, 1
    vadd.vi v18, v16, 2
    vadd.vv v14, v8, v10
    vse8.v v8, (a0)
    and t2, t2, t3
    vse8.v v12, (a0)
    vsrl.vi v10, v12, 4
    vand.vv v20, v16, v18
    vadd.vi v16, v16, 3
    addi t2, t2, 1
    vadd.vv v8, v10, v12
    vadd.vi v18, v16, 2
    vand.vv v12, v10, v8
    vor.vv v14, v8, v12
    vmin.vv v8, v10, v12
    vadd.vi v12, v14, -3
    vsll.vi v14, v8, 3
    vadd.vi v10, v10, 0
    vsrl.vi v12, v14, 1
    vand.vv v12, v10, v8
    vmaxu.vv v8, v12, v10
    vsub.vv v8, v14, v10
    vsll.vi v14, v8, 3
    vadd.vv v8, v10, v12
    vor.vv v10, v12, v14
    vadd.vi v18, v18, 7
    vsrl.vi v10, v12, 4
    vadd.vi v14, v14, 5
    vand.vv v20, v16, v18
    vadd.vx v10, v12, t2
    vsrl.vi v12, v14, 1
    vsetvli t0, zero, e32, m1, ta, ma
    vwadd.vv v6, v10, v16
    vsetvli t0, zero, e8, m1, ta, ma
    vand.vv v12, v10, v8
    vle8.v v8, (a0)
    slli t2, t2, 1
    vor.vv v14, v8, v12
    vsrl.vi v20, v16, 2
    vmaxu.vv v8, v12, v10
    vadd.vi v14, v8, 7
    vse8.v v18, (a0)
    vadd.vi v8, v10, 5
    vxor.vv v14, v10, v8
    add t4, t4, t5
    vadd.vi v20, v18, -2
    nop
    vle8.v v12, (a0)
    vor.vv v16, v18, v20
    vadd.vi v20, v20, -5
    vadd.vi v14, v14, 5
    vand.vv v20, v16, v18
    vadd.vi v20, v18, -2
    vadd.vx v10, v12, t2
    vadd.vv v16, v18, v20
    vadd.vi v14, v8, 7
    vsll.vi v8, v10, 2
    vor.vv v16, v18, v20
    vsll.vi v8, v10, 2
    vsrl.vi v12, v14, 1
    or t3, t2, t3
    vadd.vi v18, v16, 2
    vle8.v v12, (a0)
    add t4, t4, t5
    vor.vv v14, v8, v12
    vmin.vv v8, v10, v12
    vadd.vi v10, v10, 0
    vse8.v v12, (a0)

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
    .word 0x9360715f
    .word 0x7a1b5806
    .word 0xf1578470
    .word 0xd5f25073
    .word 0xe5d6f6e6
    .word 0x7cfc9b79
    .word 0x45df16b6
    .word 0x7c5308bf

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
