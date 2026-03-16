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

    vmaxu.vv v8, v12, v10
    vadd.vi v14, v8, 7
    vadd.vi v18, v18, 7
    addi t5, zero, -5
    and t2, t2, t3
    vadd.vx v8, v8, t2
    vadd.vi v18, v16, 2
    vse8.v v10, (a0)
    vsll.vi v14, v8, 3
    vadd.vi v12, v12, -1
    vadd.vx v8, v8, t2
    xor t2, t2, t3
    vadd.vi v8, v10, 5
    addi t4, zero, 10
    vsrl.vi v12, v14, 1
    vsrl.vi v12, v14, 1
    vadd.vi v8, v8, 1
    addi t4, zero, 10
    vand.vv v8, v10, v12
    vsrl.vi v12, v14, 1
    vxor.vv v14, v10, v8
    vmax.vv v14, v8, v10
    sub t3, t2, t3
    vsub.vv v12, v10, v8
    vsrl.vi v20, v16, 2
    vsll.vi v14, v8, 3
    vse8.v v10, (a0)
    vxor.vv v10, v8, v14
    vsrl.vi v10, v12, 4
    vsub.vv v8, v14, v10
    nop
    vminu.vv v12, v10, v14
    vsll.vi v8, v10, 2
    vadd.vi v10, v12, -1
    vadd.vv v16, v18, v20
    vsrl.vi v12, v14, 1
    vmin.vv v8, v10, v12
    vadd.vx v8, v8, t2
    vadd.vv v12, v8, v14
    vadd.vi v8, v8, 1
    vsetvli t0, zero, e8, m8, ta, ma
    vle8.v v15, (a0)
    vsetvli t0, zero, e8, m1, ta, ma
    vadd.vi v8, v8, 1
    vle8.v v16, (a0)
    vse8.v v10, (a0)
    vadd.vi v10, v12, -1
    vsrl.vi v20, v16, 2
    vadd.vi v8, v10, 5
    vadd.vv v16, v18, v20
    vadd.vi v20, v18, -2
    vsll.vi v16, v18, 1
    addi t3, t3, -1
    vsll.vi v14, v8, 3
    vadd.vi v12, v14, -3
    vle8.v v8, (a0)
    vsub.vv v18, v20, v16
    vle8.v v14, (a0)
    vsub.vv v12, v10, v8
    vminu.vv v12, v10, v14
    vadd.vi v18, v16, 2
    vadd.vv v12, v8, v14
    vadd.vi v8, v10, 5
    vsll.vi v16, v18, 1
    vsll.vi v8, v10, 2
    vse8.v v10, (a0)
    slli t2, t2, 1
    vadd.vi v8, v10, 5
    vminu.vv v12, v10, v14
    vmax.vv v14, v8, v10
    vse8.v v8, (a0)
    vadd.vx v8, v8, t2
    vle8.v v14, (a0)
    vadd.vi v20, v20, -5
    vand.vv v8, v10, v12
    add t2, t2, t3
    vor.vv v10, v12, v14
    vle8.v v16, (a0)
    sub t3, t2, t3
    vxor.vv v14, v10, v8
    vadd.vi v20, v20, -5
    vle8.v v12, (a0)
    vadd.vi v18, v16, 2
    add t2, t2, t3
    vle8.v v8, (a0)
    vle8.v v14, (a0)
    vadd.vv v14, v8, v10
    addi t2, t2, 1
    vse8.v v12, (a0)
    vle8.v v10, (a0)
    vminu.vv v12, v10, v14
    vadd.vi v8, v10, 5
    vxor.vv v14, v10, v8
    vsub.vv v10, v12, v14
    vor.vv v16, v18, v20

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
    .word 0x4d37a539
    .word 0x07f97d05
    .word 0xffa361be
    .word 0xd8e88ebb
    .word 0x1ba362e7
    .word 0x718d4d05
    .word 0xe63658c9
    .word 0x25f934bf

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
