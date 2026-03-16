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
    vadd.vi v12, v12, -1
    vxor.vv v14, v10, v8
    and t2, t2, t3
    vle8.v v10, (a0)
    vadd.vi v18, v18, 7
    vadd.vi v12, v14, -3
    vsub.vv v12, v10, v8
    vadd.vi v16, v16, 3
    vsll.vi v14, v8, 3
    vle8.v v16, (a0)
    xor t2, t2, t3
    vsrl.vi v10, v12, 4
    vsub.vv v12, v10, v8
    vadd.vi v20, v20, -5
    vadd.vi v8, v10, 5
    vadd.vi v18, v16, 2
    vsrl.vi v10, v12, 4
    vsrl.vi v12, v14, 1
    vsub.vv v18, v20, v16
    vadd.vv v12, v8, v14
    vadd.vv v12, v8, v14
    vsub.vv v10, v12, v14
    vsll.vi v14, v8, 3
    vadd.vi v12, v14, -3
    nop
    vadd.vv v16, v18, v20
    vor.vv v10, v12, v14
    vmaxu.vv v8, v12, v10
    vse8.v v10, (a0)
    vor.vv v10, v12, v14
    vxor.vv v14, v10, v8
    vand.vv v8, v10, v12
    vsub.vv v8, v14, v10
    vsll.vi v14, v8, 3
    vadd.vx v10, v12, t2
    vadd.vi v20, v18, -2
    vadd.vi v12, v12, -1
    vmax.vv v14, v8, v10
    vadd.vi v8, v8, 1
    vsrl.vi v12, v14, 1
    sub t3, t2, t3
    vadd.vi v20, v18, -2
    vse8.v v10, (a0)
    vadd.vi v18, v18, 7
    vand.vv v8, v10, v12
    vsll.vi v14, v8, 3
    vadd.vx v10, v12, t2
    vadd.vi v14, v14, 5
    vadd.vv v12, v8, v14
    nop
    vadd.vv v8, v10, v12
    vadd.vi v16, v16, 3
    vle16.v v5, (a0)
    vadd.vv v12, v8, v14
    vadd.vi v12, v12, -1
    vadd.vx v10, v12, t2
    vadd.vi v8, v10, 5
    vadd.vv v16, v18, v20
    addi t2, t2, 1
    vle8.v v16, (a0)
    vadd.vi v18, v18, 7
    vsrl.vi v20, v16, 2
    vadd.vi v14, v8, 7
    vle8.v v14, (a0)
    vsll.vi v14, v8, 3
    vsub.vv v8, v14, v10
    vmaxu.vv v8, v12, v10
    vxor.vv v10, v8, v14
    vmaxu.vv v8, v12, v10
    addi t5, zero, -5
    vadd.vv v8, v10, v12
    vle8.v v10, (a0)
    vse8.v v16, (a0)
    vand.vv v20, v16, v18
    addi t4, zero, 10
    vadd.vv v16, v18, v20
    add t4, t4, t5
    vle8.v v18, (a0)
    slli t2, t2, 1
    vadd.vi v12, v12, -1
    add t2, t2, t3
    vle8.v v10, (a0)
    vadd.vi v18, v16, 2
    nop
    vadd.vi v8, v8, 1
    vadd.vi v18, v16, 2
    vor.vv v16, v18, v20
    vor.vv v16, v18, v20
    vadd.vi v18, v16, 2
    vadd.vi v12, v14, -3
    vadd.vi v12, v14, -3
    addi t4, zero, 10
    vadd.vv v8, v10, v12
    vsrl.vi v10, v12, 4
    vle8.v v18, (a0)
    add t2, t2, t3
    vse8.v v8, (a0)
    vle8.v v10, (a0)
    vminu.vv v12, v10, v14
    vadd.vx v10, v12, t2
    vadd.vv v8, v10, v12

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
    .word 0x3f9304fa
    .word 0x88baef4a
    .word 0xff2e1955
    .word 0x82b60c8e
    .word 0xb01c337e
    .word 0x0b73ca1c
    .word 0x09676569
    .word 0x24444f64

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
