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

    addi t4, zero, 10
    vadd.vi v10, v10, 0
    sub t3, t2, t3
    addi t4, zero, 10
    vsub.vv v18, v20, v16
    vmin.vv v8, v10, v12
    nop
    li t2, 1
    csrw vstart, t2
    vcpop.m t3, v8
    vsub.vv v18, v20, v16
    vmax.vv v14, v8, v10
    add t4, t4, t5
    vsub.vv v8, v14, v10
    vadd.vi v18, v16, 2
    vand.vv v8, v10, v12
    vor.vv v14, v8, v12
    vand.vv v8, v10, v12
    vsrl.vi v20, v16, 2
    add t4, t4, t5
    sub t3, t2, t3
    vand.vv v8, v10, v12
    vsll.vi v16, v18, 1
    vsub.vv v18, v20, v16
    vle8.v v16, (a0)
    vadd.vv v8, v10, v12
    vse8.v v18, (a0)
    and t2, t2, t3
    vadd.vi v12, v12, -1
    vsub.vv v8, v14, v10
    vle8.v v10, (a0)
    vle8.v v14, (a0)
    vadd.vi v10, v12, -1
    vsll.vi v8, v10, 2
    vxor.vv v10, v8, v14
    vadd.vi v8, v8, 1
    vadd.vi v14, v8, 7
    vxor.vv v14, v10, v8
    vxor.vv v10, v8, v14
    vsub.vv v10, v12, v14
    vse8.v v12, (a0)
    vadd.vv v16, v18, v20
    vle8.v v8, (a0)
    slli t2, t2, 1
    vmin.vv v8, v10, v12
    vadd.vi v8, v10, 5
    vsub.vv v10, v12, v14
    nop
    vadd.vi v16, v16, 3
    vsub.vv v10, v12, v14
    vsll.vi v8, v10, 2
    vsub.vv v10, v12, v14
    nop
    vor.vv v10, v12, v14
    vadd.vi v8, v8, 1
    vsll.vi v14, v8, 3
    sub t3, t2, t3
    vmaxu.vv v8, v12, v10
    vmin.vv v8, v10, v12
    vsub.vv v12, v10, v8
    vxor.vv v10, v8, v14
    vmax.vv v14, v8, v10
    vse8.v v12, (a0)
    addi t3, t3, -1
    vsll.vi v16, v18, 1
    vadd.vi v8, v8, 1
    vse8.v v8, (a0)
    vadd.vi v14, v14, 5
    vmax.vv v14, v8, v10
    vmaxu.vv v8, v12, v10
    vadd.vi v18, v18, 7
    vsll.vi v16, v18, 1
    sub t3, t2, t3
    vxor.vv v10, v8, v14
    xor t2, t2, t3
    vsrl.vi v20, v16, 2
    xor t2, t2, t3
    vadd.vi v8, v10, 5
    vse8.v v8, (a0)
    vsll.vi v8, v10, 2
    vle8.v v10, (a0)
    slli t2, t2, 1
    vand.vv v20, v16, v18
    vadd.vv v14, v8, v10
    vle8.v v16, (a0)
    vsrl.vi v10, v12, 4
    vadd.vv v8, v10, v12
    xor t2, t2, t3
    vadd.vi v20, v18, -2
    vadd.vi v14, v8, 7
    vadd.vx v10, v12, t2
    vsub.vv v12, v10, v8
    and t2, t2, t3
    vor.vv v14, v8, v12
    and t2, t2, t3
    vadd.vv v16, v18, v20
    vminu.vv v12, v10, v14
    sub t3, t2, t3
    vsub.vv v18, v20, v16
    vadd.vx v8, v8, t2
    vse8.v v8, (a0)
    vse8.v v12, (a0)
    vsll.vi v16, v18, 1
    vmin.vv v8, v10, v12
    vadd.vi v12, v12, -1
    vadd.vi v20, v20, -5
    vadd.vi v20, v20, -5
    vand.vv v12, v10, v8
    vsub.vv v8, v14, v10
    vsrl.vi v10, v12, 4
    vsrl.vi v20, v16, 2
    vadd.vi v16, v16, 3
    vsrl.vi v10, v12, 4

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
    .word 0x60452909
    .word 0x64976593
    .word 0x905881df
    .word 0x8bae591e
    .word 0x8cd34c62
    .word 0xb5578b00
    .word 0xb15da72d
    .word 0x7fd255ee

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
