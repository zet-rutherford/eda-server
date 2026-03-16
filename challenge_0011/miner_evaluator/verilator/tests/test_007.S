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

    vor.vv v14, v8, v12
    vxor.vv v10, v8, v14
    vand.vv v20, v16, v18
    vadd.vi v18, v18, 7
    vsub.vv v10, v12, v14
    vadd.vi v16, v16, 3
    vsrl.vi v10, v12, 4
    vand.vv v20, v16, v18
    addi t2, t2, 1
    vmin.vv v8, v10, v12
    vxor.vv v10, v8, v14
    vsub.vv v10, v12, v14
    slli t2, t2, 1
    vor.vv v16, v18, v20
    vadd.vx v10, v12, t2
    vsrl.vi v12, v14, 1
    vmin.vv v8, v10, v12
    vand.vv v8, v10, v12
    vor.vv v14, v8, v12
    vadd.vi v20, v18, -2
    vsrl.vi v12, v14, 1
    nop
    vadd.vi v20, v20, -5
    vmin.vv v8, v10, v12
    vse8.v v16, (a0)
    vse8.v v10, (a0)
    vadd.vi v8, v8, 1
    vse8.v v18, (a0)
    vsll.vi v14, v8, 3
    vmin.vv v8, v10, v12
    vor.vv v16, v18, v20
    vadd.vi v12, v12, -1
    vadd.vv v14, v8, v10
    vsub.vv v8, v14, v10
    vsub.vv v18, v20, v16
    add t2, t2, t3
    vle16.v v7, (a0)
    nop
    vle8.v v16, (a0)
    vor.vv v16, v18, v20
    vsll.vi v16, v18, 1
    vse8.v v12, (a0)
    add t2, t2, t3
    vadd.vx v10, v12, t2
    vsub.vv v10, v12, v14
    vadd.vi v14, v8, 7
    vsll.vi v16, v18, 1
    add t4, t4, t5
    vxor.vv v14, v10, v8
    vsll.vi v14, v8, 3
    vadd.vv v16, v18, v20
    vadd.vi v16, v16, 3
    vadd.vx v8, v8, t2
    vmaxu.vv v8, v12, v10
    vadd.vi v10, v10, 0
    vadd.vi v20, v20, -5
    vse8.v v8, (a0)
    vse8.v v14, (a0)
    vadd.vi v20, v18, -2
    vor.vv v16, v18, v20
    vsrl.vi v12, v14, 1
    vle8.v v12, (a0)
    vand.vv v20, v16, v18
    vse8.v v12, (a0)
    vle8.v v14, (a0)
    vmax.vv v14, v8, v10
    vadd.vi v10, v10, 0
    vminu.vv v12, v10, v14
    addi t3, t3, -1
    vadd.vv v14, v8, v10
    vmin.vv v8, v10, v12
    vsub.vv v12, v10, v8
    vse8.v v14, (a0)
    vsub.vv v12, v10, v8
    vadd.vv v16, v18, v20
    vxor.vv v10, v8, v14
    vle8.v v14, (a0)
    vadd.vi v20, v18, -2
    vadd.vi v20, v20, -5
    vadd.vi v12, v14, -3
    vadd.vi v14, v8, 7
    vle8.v v14, (a0)
    vsll.vi v16, v18, 1
    vadd.vi v12, v14, -3
    vsub.vv v18, v20, v16
    vadd.vv v14, v8, v10
    vadd.vi v14, v8, 7
    vsrl.vi v12, v14, 1
    vsll.vi v16, v18, 1
    vadd.vi v16, v16, 3
    vxor.vv v10, v8, v14

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
    .word 0x5c508720
    .word 0x0534a101
    .word 0xdf92a621
    .word 0x5f90bed6
    .word 0xbf5023f4
    .word 0x114b9547
    .word 0xc1b5b5ca
    .word 0x2227219f

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
