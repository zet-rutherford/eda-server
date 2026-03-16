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

    vsrl.vi v20, v16, 2
    addi t5, zero, -5
    and t2, t2, t3
    addi t3, t3, -1
    vand.vv v20, v16, v18
    vadd.vv v8, v10, v12
    vse8.v v10, (a0)
    vadd.vi v16, v16, 3
    vadd.vv v14, v8, v10
    vand.vv v12, v10, v8
    vmin.vv v8, v10, v12
    vadd.vv v16, v18, v20
    vsub.vv v12, v10, v8
    vsrl.vi v20, v16, 2
    vadd.vi v18, v16, 2
    vadd.vx v8, v8, t2
    vadd.vi v10, v10, 0
    vand.vv v8, v10, v12
    add t4, t4, t5
    vadd.vi v20, v18, -2
    vor.vv v10, v12, v14
    vmin.vv v8, v10, v12
    vmax.vv v14, v8, v10
    vle8.v v12, (a0)
    addi t2, t2, 1
    vsrl.vi v20, v16, 2
    vadd.vx v10, v12, t2
    vmaxu.vv v8, v12, v10
    addi t3, t3, -1
    vsll.vi v14, v8, 3
    vsub.vv v10, v12, v14
    addi t3, t3, -1
    vadd.vi v14, v8, 7
    vsll.vi v14, v8, 3
    and t2, t2, t3
    or t3, t2, t3
    vand.vv v12, v10, v8
    vadd.vi v14, v14, 5
    vse8.v v14, (a0)
    vadd.vv v12, v8, v14
    slli t2, t2, 1
    vor.vv v16, v18, v20
    vsrl.vi v10, v12, 4
    vle8.v v10, (a0)
    vor.vv v16, v18, v20
    vor.vv v10, v12, v14
    vadd.vx v8, v8, t2
    vor.vv v16, v18, v20
    vse8.v v8, (a0)
    vadd.vi v20, v20, -5
    vmin.vv v8, v10, v12
    vsub.vv v10, v12, v14
    vse8.v v16, (a0)
    vadd.vi v16, v16, 3
    vsrl.vi v20, v16, 2
    vsrl.vi v10, v12, 4
    and t2, t2, t3
    or t3, t2, t3
    vadd.vi v12, v14, -3
    add t2, t2, t3
    addi t2, t2, 1
    vadd.vi v8, v10, 5
    or t3, t2, t3
    vsll.vi v8, v10, 2
    vse8.v v18, (a0)
    vadd.vi v16, v16, 3
    addi t3, t3, -1
    vmin.vv v8, v10, v12
    vsub.vv v12, v10, v8
    vse8.v v16, (a0)
    vse8.v v12, (a0)
    vse8.v v12, (a0)
    vadd.vi v20, v20, -5
    vsrl.vi v20, v16, 2
    vadd.vi v14, v14, 5
    vmin.vv v8, v10, v12
    vsetvli t0, zero, e8, m2, ta, ma
    vadd.vv v6, v3, v14
    vsetvli t0, zero, e8, m1, ta, ma
    vse8.v v18, (a0)
    vadd.vx v8, v8, t2
    vadd.vx v8, v8, t2
    vxor.vv v14, v10, v8
    vle8.v v18, (a0)
    or t3, t2, t3
    vmin.vv v8, v10, v12
    vadd.vv v14, v8, v10
    vle8.v v10, (a0)
    vadd.vx v8, v8, t2
    vsrl.vi v12, v14, 1
    vadd.vi v20, v20, -5
    vle8.v v10, (a0)
    vadd.vi v8, v10, 5
    vor.vv v14, v8, v12
    vadd.vi v18, v16, 2
    vadd.vi v18, v18, 7
    vsll.vi v16, v18, 1
    add t2, t2, t3
    vmin.vv v8, v10, v12
    add t4, t4, t5
    vadd.vi v12, v12, -1
    vmin.vv v8, v10, v12
    vadd.vi v14, v8, 7

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
    .word 0xab6b3f08
    .word 0xd635212d
    .word 0x98986758
    .word 0x71f9b0e2
    .word 0x67e2189b
    .word 0x9927839b
    .word 0xd1e2b878
    .word 0x53d106cb

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
