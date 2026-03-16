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

    vmin.vv v8, v10, v12
    vsub.vv v18, v20, v16
    vand.vv v12, v10, v8
    nop
    vxor.vv v14, v10, v8
    add t2, t2, t3
    addi t2, t2, 1
    vadd.vx v10, v12, t2
    vsub.vv v10, v12, v14
    vsrl.vi v20, v16, 2
    srli t3, t3, 1
    vle8.v v8, (a0)
    vadd.vv v14, v8, v10
    vle8.v v10, (a0)
    vmaxu.vv v8, v12, v10
    vse8.v v8, (a0)
    vadd.vv v12, v8, v14
    addi t5, zero, -5
    vse8.v v12, (a0)
    vor.vv v16, v18, v20
    addi t4, zero, 10
    vadd.vi v10, v10, 0
    vadd.vi v8, v10, 5
    vsll.vi v16, v18, 1
    vle8.v v10, (a0)
    vsub.vv v18, v20, v16
    vadd.vi v10, v12, -1
    li t2, 1
    csrw vstart, t2
    vcpop.m t3, v2
    vsrl.vi v12, v14, 1
    srli t3, t3, 1
    vor.vv v10, v12, v14
    vadd.vv v16, v18, v20
    vadd.vv v8, v10, v12
    vadd.vi v12, v14, -3
    vsub.vv v18, v20, v16
    vle8.v v10, (a0)
    vse8.v v18, (a0)
    vse8.v v8, (a0)
    vadd.vx v8, v8, t2
    vsrl.vi v12, v14, 1
    addi t2, t2, 1
    vle8.v v12, (a0)
    vsrl.vi v12, v14, 1
    vsrl.vi v10, v12, 4
    vadd.vi v12, v14, -3
    vle8.v v8, (a0)
    vle8.v v12, (a0)
    vadd.vx v10, v12, t2
    vadd.vi v14, v14, 5
    vsll.vi v8, v10, 2
    vxor.vv v10, v8, v14
    vmin.vv v8, v10, v12
    xor t2, t2, t3
    vsll.vi v8, v10, 2
    vadd.vv v16, v18, v20
    vadd.vx v10, v12, t2
    vse8.v v18, (a0)
    vadd.vx v10, v12, t2
    vle8.v v18, (a0)
    vadd.vi v14, v14, 5
    xor t2, t2, t3
    vsll.vi v16, v18, 1
    li t2, 1
    csrw vstart, t2
    vcpop.m t3, v1
    vsub.vv v12, v10, v8
    vsub.vv v18, v20, v16
    vse8.v v12, (a0)
    vor.vv v14, v8, v12
    or t3, t2, t3
    vse8.v v16, (a0)
    vadd.vi v16, v16, 3
    vxor.vv v14, v10, v8
    vor.vv v16, v18, v20
    vsll.vi v16, v18, 1
    vse8.v v16, (a0)
    vadd.vv v16, v18, v20
    vmaxu.vv v8, v12, v10
    vle8.v v16, (a0)
    vsll.vi v16, v18, 1
    vse8.v v16, (a0)
    vadd.vv v16, v18, v20
    vadd.vx v10, v12, t2
    vse8.v v14, (a0)
    vmin.vv v8, v10, v12
    vle8.v v14, (a0)
    vmaxu.vv v8, v12, v10
    vadd.vi v14, v8, 7
    vse8.v v14, (a0)
    vadd.vi v14, v14, 5
    vadd.vi v14, v14, 5
    vsub.vv v18, v20, v16
    vadd.vv v14, v8, v10
    vsub.vv v10, v12, v14
    vadd.vv v8, v10, v12
    vadd.vi v20, v20, -5
    vand.vv v20, v16, v18
    vadd.vx v8, v8, t2
    vminu.vv v12, v10, v14
    vxor.vv v14, v10, v8
    vmin.vv v8, v10, v12

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
    .word 0xa83c1c2b
    .word 0xb7461b72
    .word 0x1d30a290
    .word 0x38c46b38
    .word 0x57632e1e
    .word 0x85a0d089
    .word 0xb3bc912f
    .word 0x2a061609

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
