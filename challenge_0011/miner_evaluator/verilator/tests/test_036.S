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

    slli t2, t2, 1
    vsub.vv v10, v12, v14
    add t4, t4, t5
    vor.vv v10, v12, v14
    nop
    vadd.vi v12, v14, -3
    vadd.vi v16, v16, 3
    vadd.vi v20, v18, -2
    add t4, t4, t5
    vadd.vi v20, v20, -5
    vor.vv v14, v8, v12
    vor.vv v14, v8, v12
    vle8.v v18, (a0)
    vor.vv v16, v18, v20
    vand.vv v12, v10, v8
    vadd.vv v14, v8, v10
    vadd.vi v18, v16, 2
    vadd.vi v20, v18, -2
    vadd.vv v8, v10, v12
    vand.vv v8, v10, v12
    vsrl.vi v10, v12, 4
    vadd.vi v10, v10, 0
    vle8.v v16, (a0)
    vminu.vv v12, v10, v14
    vsub.vv v10, v12, v14
    vxor.vv v14, v10, v8
    vse8.v v12, (a0)
    vadd.vv v8, v10, v12
    vmin.vv v8, v10, v12
    vle8.v v18, (a0)
    vxor.vv v14, v10, v8
    vadd.vi v12, v12, -1
    vadd.vi v14, v8, 7
    or t3, t2, t3
    vse8.v v16, (a0)
    vse8.v v14, (a0)
    vadd.vv v14, v8, v10
    vsrl.vi v20, v16, 2
    vadd.vi v10, v12, -1
    vle8.v v14, (a0)
    vand.vv v8, v10, v12
    vor.vv v16, v18, v20
    vor.vv v14, v8, v12
    vadd.vi v8, v10, 5
    vadd.vi v18, v18, 7
    vle8.v v8, (a0)
    vmaxu.vv v8, v12, v10
    vor.vv v14, v8, v12
    vand.vv v8, v10, v12
    vadd.vi v14, v14, 5
    vsrl.vi v20, v16, 2
    vadd.vi v8, v10, 5
    vadd.vi v20, v18, -2
    xor t2, t2, t3
    vsll.vi v16, v18, 1
    vxor.vv v14, v10, v8
    vsll.vi v16, v18, 1
    vadd.vv v0, v2, v8, v0.t
    vadd.vi v12, v12, -1
    vsll.vi v16, v18, 1
    vse8.v v16, (a0)
    vadd.vv v14, v8, v10
    vmin.vv v8, v10, v12
    vadd.vi v8, v10, 5
    vse8.v v18, (a0)
    vle8.v v14, (a0)
    vsub.vv v12, v10, v8
    vmax.vv v14, v8, v10
    vsll.vi v16, v18, 1
    vadd.vi v14, v8, 7
    vle8.v v8, (a0)
    vse8.v v8, (a0)
    vand.vv v20, v16, v18
    vmax.vv v14, v8, v10
    vadd.vi v18, v16, 2
    vse8.v v8, (a0)
    vsrl.vi v12, v14, 1
    vadd.vv v8, v10, v12
    vadd.vv v12, v8, v14
    nop
    vand.vv v8, v10, v12
    vand.vv v12, v10, v8
    vand.vv v12, v10, v8
    vmin.vv v8, v10, v12
    slli t2, t2, 1
    vadd.vx v8, v8, t2
    vadd.vi v18, v18, 7
    vmin.vv v8, v10, v12
    vadd.vi v10, v10, 0
    vadd.vi v8, v10, 5
    vsub.vv v10, v12, v14
    vadd.vv v8, v10, v12
    vxor.vv v14, v10, v8
    vadd.vi v14, v8, 7
    vmin.vv v8, v10, v12
    vmaxu.vv v8, v12, v10
    add t2, t2, t3
    vadd.vv v8, v10, v12
    vor.vv v14, v8, v12
    vle8.v v10, (a0)
    vse8.v v14, (a0)
    addi t4, zero, 10
    vminu.vv v12, v10, v14
    vle8.v v8, (a0)
    add t2, t2, t3
    and t2, t2, t3
    vmin.vv v8, v10, v12
    vadd.vi v14, v8, 7
    add t2, t2, t3
    vadd.vi v8, v10, 5
    vse8.v v16, (a0)
    vse8.v v16, (a0)
    vor.vv v10, v12, v14
    vadd.vi v14, v8, 7
    vminu.vv v12, v10, v14

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
    .word 0xa9315044
    .word 0xe1b4b7ef
    .word 0x10bc94d3
    .word 0xec9573e9
    .word 0xcb7e717c
    .word 0x5fcf3219
    .word 0x997c0dc9
    .word 0x8914741c

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
