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

    vadd.vi v20, v18, -2
    vmaxu.vv v8, v12, v10
    vor.vv v16, v18, v20
    srli t3, t3, 1
    vadd.vi v8, v10, 5
    vadd.vi v12, v14, -3
    vadd.vi v20, v18, -2
    vadd.vi v12, v12, -1
    vxor.vv v14, v10, v8
    vadd.vx v8, v8, t2
    vadd.vi v8, v10, 5
    vsrl.vi v10, v12, 4
    vminu.vv v12, v10, v14
    vadd.vv v16, v18, v20
    vle8.v v10, (a0)
    vminu.vv v12, v10, v14
    vadd.vi v20, v18, -2
    vle8.v v16, (a0)
    vadd.vi v12, v14, -3
    vadd.vi v12, v12, -1
    vand.vv v8, v10, v12
    vadd.vi v20, v20, -5
    vadd.vi v8, v10, 5
    vor.vv v10, v12, v14
    slli t2, t2, 1
    vmax.vv v14, v8, v10
    vminu.vv v12, v10, v14
    vse8.v v8, (a0)
    vadd.vi v12, v12, -1
    vsll.vi v16, v18, 1
    vadd.vi v20, v18, -2
    vse8.v v16, (a0)
    vsll.vi v8, v10, 2
    vse8.v v8, (a0)
    vsll.vi v14, v8, 3
    vmax.vv v14, v8, v10
    add t2, t2, t3
    vadd.vi v8, v8, 1
    vse8.v v18, (a0)
    vxor.vv v10, v8, v14
    vor.vv v10, v12, v14
    vadd.vx v8, v8, t2
    vminu.vv v12, v10, v14
    li t2, 1
    csrw vstart, t2
    vredsum.vs v0, v1, v0
    vadd.vi v16, v16, 3
    vand.vv v8, v10, v12
    nop
    vxor.vv v10, v8, v14
    addi t5, zero, -5
    vadd.vi v14, v14, 5
    vor.vv v10, v12, v14
    vadd.vi v12, v14, -3
    vadd.vi v12, v14, -3
    addi t5, zero, -5
    vor.vv v16, v18, v20
    vxor.vv v14, v10, v8
    vadd.vi v20, v20, -5
    vle8.v v14, (a0)
    vor.vv v10, v12, v14
    vadd.vi v10, v12, -1
    addi t3, t3, -1
    vse8.v v18, (a0)
    vsub.vv v12, v10, v8
    vxor.vv v14, v10, v8
    vmax.vv v14, v8, v10
    vse8.v v18, (a0)
    vle8.v v8, (a0)
    vor.vv v14, v8, v12
    vadd.vi v16, v16, 3
    vsrl.vi v20, v16, 2
    vadd.vi v12, v14, -3
    vsrl.vi v10, v12, 4
    addi t4, zero, 10
    vminu.vv v12, v10, v14
    vle8.v v10, (a0)
    vadd.vi v8, v8, 1
    vadd.vi v8, v8, 1
    vmin.vv v8, v10, v12
    nop
    vse8.v v16, (a0)
    vle8.v v16, (a0)
    nop
    vadd.vv v12, v8, v14
    vse8.v v8, (a0)
    addi t4, zero, 10
    nop
    vsub.vv v8, v14, v10
    vadd.vi v16, v16, 3
    vadd.vi v14, v14, 5
    vadd.vi v16, v16, 3
    vsll.vi v16, v18, 1
    vsrl.vi v20, v16, 2

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
    .word 0x50ee7a92
    .word 0x70944bdb
    .word 0x780b3657
    .word 0xa1a27485
    .word 0xcbdc4318
    .word 0x97674900
    .word 0x12fe28bf
    .word 0x7634c169

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
