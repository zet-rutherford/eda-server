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

    vxor.vv v14, v10, v8
    vsub.vv v12, v10, v8
    vle8.v v14, (a0)
    vand.vv v20, v16, v18
    vadd.vv v12, v8, v14
    vsub.vv v8, v14, v10
    vsll.vi v16, v18, 1
    vle8.v v16, (a0)
    vadd.vi v12, v14, -3
    vse8.v v16, (a0)
    vle8.v v18, (a0)
    vadd.vv v8, v10, v12
    vadd.vi v12, v12, -1
    vminu.vv v12, v10, v14
    vadd.vi v12, v12, -1
    nop
    vmaxu.vv v8, v12, v10
    vadd.vi v16, v16, 3
    vle8.v v12, (a0)
    nop
    nop
    vle8.v v18, (a0)
    vand.vv v12, v10, v8
    vse8.v v18, (a0)
    vadd.vi v16, v16, 3
    vor.vv v16, v18, v20
    vse8.v v16, (a0)
    nop
    vminu.vv v12, v10, v14
    addi t5, zero, -5
    vadd.vi v10, v12, -1
    vadd.vi v12, v12, -1
    vsll.vi v8, v10, 2
    vadd.vi v8, v8, 1
    vadd.vi v10, v10, 0
    vadd.vi v20, v18, -2
    vminu.vv v12, v10, v14
    vadd.vv v16, v18, v20
    and t2, t2, t3
    vadd.vi v8, v8, 1
    vadd.vi v12, v14, -3
    vadd.vi v14, v14, 5
    vadd.vx v10, v12, t2
    vle8.v v16, (a0)
    vmin.vv v8, v10, v12
    vsll.vi v16, v18, 1
    vand.vv v8, v10, v12
    addi t5, zero, -5
    vle8.v v10, (a0)
    vsetvli t0, zero, e8, m4, ta, ma
    vmslt.vv v8, v8, v12
    vsetvli t0, zero, e8, m1, ta, ma
    vadd.vi v20, v20, -5
    vor.vv v14, v8, v12
    or t3, t2, t3
    vle8.v v8, (a0)
    vadd.vi v8, v8, 1
    vor.vv v16, v18, v20
    addi t4, zero, 10
    vle8.v v12, (a0)
    vadd.vi v14, v14, 5
    vse8.v v16, (a0)
    vor.vv v16, v18, v20
    addi t2, t2, 1
    vxor.vv v14, v10, v8
    vsub.vv v10, v12, v14
    vadd.vv v8, v10, v12
    vxor.vv v10, v8, v14
    vadd.vi v8, v8, 1
    vadd.vi v8, v8, 1
    vand.vv v12, v10, v8
    vse8.v v18, (a0)
    vle8.v v10, (a0)
    vadd.vi v20, v18, -2
    vmax.vv v14, v8, v10
    vsll.vi v8, v10, 2
    sub t3, t2, t3
    vadd.vi v8, v8, 1
    vle8.v v12, (a0)
    vadd.vi v8, v10, 5
    vand.vv v20, v16, v18
    addi t3, t3, -1
    vadd.vi v10, v12, -1
    vadd.vi v16, v16, 3
    slli t2, t2, 1
    vadd.vi v14, v8, 7
    vadd.vx v8, v8, t2
    vadd.vi v18, v18, 7
    vadd.vv v16, v18, v20
    vle8.v v10, (a0)
    vxor.vv v14, v10, v8
    vsrl.vi v10, v12, 4
    vmax.vv v14, v8, v10
    vadd.vv v8, v10, v12
    vadd.vi v10, v12, -1
    addi t3, t3, -1
    vmin.vv v8, v10, v12
    vle8.v v12, (a0)
    vmax.vv v14, v8, v10
    vsll.vi v8, v10, 2
    add t4, t4, t5
    vand.vv v12, v10, v8
    vand.vv v12, v10, v8
    vadd.vi v10, v12, -1
    sub t3, t2, t3
    vsll.vi v16, v18, 1
    vadd.vi v8, v10, 5
    vsub.vv v18, v20, v16
    vadd.vi v18, v16, 2
    vadd.vv v16, v18, v20
    vsub.vv v18, v20, v16
    vadd.vi v16, v16, 3
    vsub.vv v18, v20, v16
    nop
    vsll.vi v8, v10, 2
    addi t4, zero, 10
    vle8.v v16, (a0)
    vadd.vv v16, v18, v20
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
    .word 0x80a23721
    .word 0x2cbfb769
    .word 0xf9fc6034
    .word 0x75c72fb6
    .word 0xb0701a53
    .word 0x35f3de4a
    .word 0x94bcf47a
    .word 0x534fc96d

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
