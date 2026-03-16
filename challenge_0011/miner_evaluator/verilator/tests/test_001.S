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

    vadd.vi v10, v12, -1
    vsub.vv v8, v14, v10
    vadd.vi v8, v10, 5
    addi t5, zero, -5
    vand.vv v12, v10, v8
    nop
    nop
    vadd.vv v8, v10, v12
    vsub.vv v18, v20, v16
    vse8.v v10, (a0)
    vsll.vi v14, v8, 3
    vle8.v v18, (a0)
    vxor.vv v10, v8, v14
    vor.vv v14, v8, v12
    vadd.vi v18, v16, 2
    vse8.v v14, (a0)
    vadd.vx v10, v12, t2
    nop
    vor.vv v10, v12, v14
    vand.vv v12, v10, v8
    vadd.vi v8, v8, 1
    vminu.vv v12, v10, v14
    vor.vv v16, v18, v20
    vadd.vi v14, v8, 7
    or t3, t2, t3
    vle8.v v16, (a0)
    vadd.vv v8, v10, v12
    vse8.v v16, (a0)
    vle8.v v10, (a0)
    vmin.vv v8, v10, v12
    vsll.vi v8, v10, 2
    vor.vv v10, v12, v14
    vadd.vi v16, v16, 3
    vadd.vv v16, v18, v20
    vand.vv v12, v10, v8
    vse8.v v16, (a0)
    vadd.vi v12, v12, -1
    vand.vv v8, v10, v12
    vadd.vi v8, v10, 5
    vse8.v v18, (a0)
    vadd.vi v8, v10, 5
    sub t3, t2, t3
    vsub.vv v12, v10, v8
    vsll.vi v8, v10, 2
    vor.vv v14, v8, v12
    vadd.vi v20, v18, -2
    vse8.v v16, (a0)
    vadd.vv v8, v10, v12
    vadd.vi v14, v8, 7
    vsetvli t0, zero, e32, m1, ta, ma
    .word 0x00061057
    vsetvli t0, zero, e8, m1, ta, ma
    vor.vv v10, v12, v14
    vand.vv v8, v10, v12
    addi t2, t2, 1
    vadd.vi v10, v12, -1
    vadd.vx v8, v8, t2
    add t4, t4, t5
    vadd.vi v20, v18, -2
    vsub.vv v18, v20, v16
    and t2, t2, t3
    addi t2, t2, 1
    vadd.vi v18, v16, 2
    vse8.v v10, (a0)
    vle8.v v18, (a0)
    vor.vv v16, v18, v20
    vle8.v v16, (a0)
    vle8.v v12, (a0)
    vle8.v v10, (a0)
    vadd.vi v14, v8, 7
    vle8.v v18, (a0)
    addi t4, zero, 10
    vle8.v v10, (a0)
    vadd.vi v18, v18, 7
    vsrl.vi v10, v12, 4
    vor.vv v10, v12, v14
    vadd.vi v14, v8, 7
    add t2, t2, t3
    vsll.vi v14, v8, 3
    vor.vv v14, v8, v12
    vle8.v v18, (a0)
    vadd.vi v8, v10, 5
    vle8.v v14, (a0)
    vsub.vv v12, v10, v8
    vadd.vi v14, v8, 7
    vadd.vx v10, v12, t2
    vadd.vi v18, v16, 2
    vsll.vi v16, v18, 1
    vor.vv v16, v18, v20
    vadd.vi v20, v18, -2
    addi t5, zero, -5
    vle8.v v12, (a0)
    vle8.v v10, (a0)
    vadd.vv v12, v8, v14
    addi t4, zero, 10

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
    .word 0x57c700aa
    .word 0xda587e8a
    .word 0x81627cf1
    .word 0x0d01280f
    .word 0xa2607723
    .word 0xd450281c
    .word 0x0b49452d
    .word 0xfad409e2

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
