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
    vadd.vv v12, v8, v14
    vor.vv v16, v18, v20
    vor.vv v14, v8, v12
    vadd.vi v8, v8, 1
    vse8.v v8, (a0)
    vadd.vx v10, v12, t2
    .word 0x02850087
    vsrl.vi v10, v12, 4
    srli t3, t3, 1
    vsll.vi v16, v18, 1
    vxor.vv v14, v10, v8
    vsub.vv v8, v14, v10
    vsrl.vi v12, v14, 1
    vse8.v v18, (a0)
    vse8.v v18, (a0)
    vadd.vi v16, v16, 3
    vle8.v v18, (a0)
    vsll.vi v16, v18, 1
    addi t4, zero, 10
    vse8.v v14, (a0)
    vse8.v v18, (a0)
    vse8.v v10, (a0)
    addi t3, t3, -1
    vsrl.vi v20, v16, 2
    vmin.vv v8, v10, v12
    vadd.vi v10, v12, -1
    add t4, t4, t5
    vadd.vi v8, v10, 5
    vand.vv v8, v10, v12
    vadd.vi v10, v10, 0
    vsub.vv v18, v20, v16
    vmax.vv v14, v8, v10
    vadd.vi v8, v10, 5
    vadd.vi v16, v16, 3
    vxor.vv v14, v10, v8
    addi t3, t3, -1
    vsub.vv v10, v12, v14
    or t3, t2, t3
    addi t3, t3, -1
    vle8.v v12, (a0)
    vadd.vx v10, v12, t2
    vadd.vi v20, v18, -2
    vsll.vi v16, v18, 1
    vadd.vv v14, v8, v10
    vadd.vx v10, v12, t2
    vadd.vx v10, v12, t2
    vse8.v v10, (a0)
    sub t3, t2, t3
    vadd.vi v20, v18, -2
    vadd.vi v18, v16, 2
    and t2, t2, t3
    addi t3, t3, -1
    vadd.vi v20, v18, -2
    vadd.vv v12, v8, v14
    vle8.v v8, (a0)
    vse8.v v16, (a0)
    vadd.vv v16, v18, v20
    addi t2, t2, 1
    addi t5, zero, -5
    addi t3, t3, -1
    vadd.vi v12, v14, -3
    vadd.vv v16, v18, v20
    vadd.vi v10, v12, -1
    vle8.v v16, (a0)
    vminu.vv v12, v10, v14
    vminu.vv v12, v10, v14
    vadd.vi v10, v12, -1
    vadd.vi v10, v12, -1
    and t2, t2, t3
    vadd.vv v12, v8, v14
    vxor.vv v10, v8, v14
    vadd.vi v18, v16, 2
    vadd.vi v18, v18, 7
    addi t2, t2, 1
    vor.vv v16, v18, v20
    vadd.vi v18, v16, 2
    vadd.vv v16, v18, v20
    vadd.vi v14, v8, 7
    xor t2, t2, t3
    vsub.vv v10, v12, v14
    vor.vv v16, v18, v20
    vsll.vi v16, v18, 1
    vse8.v v14, (a0)
    add t2, t2, t3
    vsub.vv v12, v10, v8
    vle8.v v10, (a0)
    vadd.vi v12, v12, -1
    nop
    vle8.v v18, (a0)
    add t4, t4, t5
    vor.vv v14, v8, v12
    vle8.v v16, (a0)
    vsrl.vi v10, v12, 4
    vor.vv v16, v18, v20
    vadd.vv v8, v10, v12
    vsll.vi v16, v18, 1
    vadd.vi v10, v10, 0
    vle8.v v12, (a0)
    vle8.v v18, (a0)
    vadd.vi v8, v10, 5
    vadd.vi v16, v16, 3
    vsrl.vi v12, v14, 1
    vmax.vv v14, v8, v10
    addi t5, zero, -5
    vadd.vi v20, v20, -5
    vsub.vv v8, v14, v10
    add t2, t2, t3
    vadd.vi v8, v8, 1
    vse8.v v10, (a0)
    add t4, t4, t5
    vsll.vi v8, v10, 2

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
    .word 0xe5a3d8e9
    .word 0x052dfb9a
    .word 0x4d950273
    .word 0xde703b72
    .word 0x226716e3
    .word 0xd3692867
    .word 0xa543148e
    .word 0x301c8db3

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
