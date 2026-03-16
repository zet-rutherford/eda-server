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

    vle8.v v12, (a0)
    vsrl.vi v20, v16, 2
    vadd.vv v12, v8, v14
    vle8.v v16, (a0)
    addi t4, zero, 10
    vand.vv v12, v10, v8
    or t3, t2, t3
    nop
    vsll.vi v14, v8, 3
    vadd.vi v12, v12, -1
    vmax.vv v14, v8, v10
    vsll.vi v16, v18, 1
    vadd.vi v8, v8, 1
    vsrl.vi v12, v14, 1
    vadd.vi v20, v18, -2
    vadd.vv v8, v10, v12
    vmax.vv v14, v8, v10
    vadd.vv v14, v8, v10
    add t4, t4, t5
    vsrl.vi v20, v16, 2
    vadd.vi v8, v8, 1
    vadd.vi v18, v16, 2
    add t2, t2, t3
    vand.vv v12, v10, v8
    vminu.vv v12, v10, v14
    nop
    vsub.vv v12, v10, v8
    vse8.v v16, (a0)
    vse8.v v18, (a0)
    vadd.vi v12, v12, -1
    vsub.vv v12, v10, v8
    vse8.v v12, (a0)
    vadd.vi v20, v20, -5
    vsll.vi v16, v18, 1
    vadd.vi v12, v12, -1
    vadd.vi v14, v14, 5
    vxor.vv v14, v10, v8
    addi t4, zero, 10
    vadd.vi v14, v8, 7
    vsll.vi v8, v10, 2
    vadd.vi v18, v16, 2
    vsub.vv v10, v12, v14
    vminu.vv v12, v10, v14
    vse8.v v14, (a0)
    vxor.vv v10, v8, v14
    vse8.v v18, (a0)
    vsll.vi v8, v10, 2
    vxor.vv v10, v8, v14
    vxor.vv v10, v8, v14
    addi t5, zero, -5
    vor.vv v14, v8, v12
    vadd.vi v18, v16, 2
    vsll.vi v14, v8, 3
    vmin.vv v8, v10, v12
    vadd.vv v8, v10, v12
    vadd.vv v16, v18, v20
    vse16.v v21, (a0)
    vmax.vv v14, v8, v10
    vsrl.vi v12, v14, 1
    addi t2, t2, 1
    vadd.vi v20, v20, -5
    vadd.vi v16, v16, 3
    addi t5, zero, -5
    vadd.vx v10, v12, t2
    vsrl.vi v12, v14, 1
    vsrl.vi v12, v14, 1
    vsub.vv v12, v10, v8
    vsll.vi v8, v10, 2
    addi t4, zero, 10
    nop
    add t4, t4, t5
    vle8.v v12, (a0)
    vadd.vv v12, v8, v14
    vsub.vv v8, v14, v10
    add t4, t4, t5
    add t2, t2, t3
    vsub.vv v10, v12, v14
    vxor.vv v10, v8, v14
    vadd.vi v20, v20, -5
    vadd.vv v12, v8, v14
    vadd.vi v10, v10, 0
    slli t2, t2, 1
    vadd.vx v10, v12, t2
    add t4, t4, t5
    vand.vv v8, v10, v12
    vadd.vi v12, v14, -3
    vse8.v v14, (a0)
    vadd.vv v16, v18, v20
    vadd.vi v18, v16, 2
    addi t5, zero, -5
    vadd.vv v16, v18, v20
    srli t3, t3, 1
    vadd.vv v8, v10, v12
    vadd.vi v14, v14, 5
    vsrl.vi v10, v12, 4
    vsub.vv v10, v12, v14
    vle8.v v16, (a0)
    vadd.vi v12, v12, -1
    vsll.vi v8, v10, 2
    vsll.vi v8, v10, 2
    vadd.vi v10, v12, -1
    vadd.vi v8, v8, 1
    vadd.vi v14, v8, 7
    vadd.vi v18, v18, 7
    vor.vv v16, v18, v20
    vsub.vv v8, v14, v10
    vadd.vv v8, v10, v12
    vor.vv v14, v8, v12
    vle8.v v10, (a0)
    vadd.vi v14, v14, 5

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
    .word 0x59fcfaeb
    .word 0xb9aa06f5
    .word 0x407c4370
    .word 0x08b6f61d
    .word 0x9e90d107
    .word 0xf5321352
    .word 0x9accb00d
    .word 0x2f2bdc13

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
