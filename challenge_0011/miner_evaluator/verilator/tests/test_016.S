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

    vor.vv v16, v18, v20
    vand.vv v8, v10, v12
    vadd.vx v10, v12, t2
    vse8.v v18, (a0)
    vsub.vv v12, v10, v8
    vor.vv v16, v18, v20
    vadd.vv v14, v8, v10
    nop
    vadd.vi v14, v8, 7
    vle8.v v8, (a0)
    vand.vv v12, v10, v8
    vsetvli t0, zero, e32, m1, ta, ma
    .word 0x08061057
    vsetvli t0, zero, e8, m1, ta, ma
    vand.vv v20, v16, v18
    vadd.vi v12, v14, -3
    vadd.vi v14, v8, 7
    vadd.vi v20, v20, -5
    vadd.vv v16, v18, v20
    vmax.vv v14, v8, v10
    and t2, t2, t3
    vxor.vv v10, v8, v14
    xor t2, t2, t3
    vle8.v v18, (a0)
    vor.vv v10, v12, v14
    vxor.vv v14, v10, v8
    addi t5, zero, -5
    vadd.vv v14, v8, v10
    vadd.vv v8, v10, v12
    vsub.vv v12, v10, v8
    vadd.vi v20, v20, -5
    vxor.vv v14, v10, v8
    nop
    vsll.vi v8, v10, 2
    vmax.vv v14, v8, v10
    vor.vv v10, v12, v14
    vor.vv v16, v18, v20
    vadd.vi v8, v8, 1
    vadd.vv v8, v10, v12
    vminu.vv v12, v10, v14
    vadd.vi v20, v20, -5
    addi t5, zero, -5
    vle8.v v10, (a0)
    vsll.vi v8, v10, 2
    vsll.vi v8, v10, 2
    add t4, t4, t5
    vsll.vi v14, v8, 3
    vle8.v v14, (a0)
    vadd.vi v20, v20, -5
    vsrl.vi v10, v12, 4
    vadd.vv v14, v8, v10
    vsrl.vi v12, v14, 1
    xor t2, t2, t3
    vsub.vv v10, v12, v14
    vadd.vi v16, v16, 3
    vmin.vv v8, v10, v12
    vxor.vv v14, v10, v8
    vsrl.vi v20, v16, 2
    vmax.vv v14, v8, v10
    vadd.vx v10, v12, t2
    vadd.vi v20, v18, -2
    addi t3, t3, -1
    vadd.vi v10, v12, -1
    vadd.vi v20, v18, -2
    vsub.vv v8, v14, v10
    vmin.vv v8, v10, v12
    vse8.v v10, (a0)
    nop
    vmin.vv v8, v10, v12
    vadd.vi v18, v18, 7
    nop
    vle8.v v8, (a0)
    vadd.vi v18, v18, 7
    vsll.vi v16, v18, 1
    vand.vv v12, v10, v8
    vmaxu.vv v8, v12, v10
    vadd.vi v10, v10, 0
    vadd.vv v12, v8, v14
    vle8.v v14, (a0)
    vadd.vi v16, v16, 3
    vse8.v v18, (a0)
    addi t3, t3, -1
    vsrl.vi v20, v16, 2
    vsrl.vi v10, v12, 4
    vadd.vv v8, v10, v12
    vor.vv v10, v12, v14
    vadd.vx v10, v12, t2
    vxor.vv v10, v8, v14
    vse8.v v12, (a0)
    vadd.vi v8, v8, 1
    vmaxu.vv v8, v12, v10
    vle8.v v16, (a0)
    or t3, t2, t3
    vsrl.vi v10, v12, 4
    vor.vv v16, v18, v20
    addi t5, zero, -5

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
    .word 0xbbcd6c18
    .word 0xe0821918
    .word 0x4fe54745
    .word 0x1a4b1606
    .word 0x4e5d8f12
    .word 0x0bb432b3
    .word 0xf2ce7eeb
    .word 0x862c92fd

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
