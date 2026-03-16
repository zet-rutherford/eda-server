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

    addi t5, zero, -5
    vsub.vv v12, v10, v8
    vadd.vi v18, v18, 7
    vor.vv v10, v12, v14
    vadd.vv v16, v18, v20
    vadd.vx v10, v12, t2
    vand.vv v20, v16, v18
    vor.vv v16, v18, v20
    vsrl.vi v10, v12, 4
    vor.vv v16, v18, v20
    vsub.vv v18, v20, v16
    vadd.vi v18, v18, 7
    vadd.vi v18, v18, 7
    vle8.v v14, (a0)
    vadd.vi v14, v14, 5
    vadd.vi v8, v8, 1
    xor t2, t2, t3
    vadd.vi v16, v16, 3
    nop
    vadd.vi v20, v18, -2
    vle8.v v10, (a0)
    vmax.vv v14, v8, v10
    addi t2, t2, 1
    vsll.vi v16, v18, 1
    vse16.v v13, (a0)
    vadd.vi v12, v12, -1
    vsub.vv v18, v20, v16
    vmaxu.vv v8, v12, v10
    vse8.v v14, (a0)
    addi t5, zero, -5
    vle8.v v10, (a0)
    vand.vv v20, v16, v18
    vxor.vv v10, v8, v14
    vxor.vv v14, v10, v8
    vle8.v v10, (a0)
    vadd.vi v18, v16, 2
    vmin.vv v8, v10, v12
    add t4, t4, t5
    vsll.vi v8, v10, 2
    addi t4, zero, 10
    vadd.vi v18, v16, 2
    vadd.vv v8, v10, v12
    vsrl.vi v12, v14, 1
    vadd.vi v8, v8, 1
    vadd.vv v8, v10, v12
    vand.vv v20, v16, v18
    vadd.vv v12, v8, v14
    vxor.vv v14, v10, v8
    add t4, t4, t5
    sub t3, t2, t3
    vadd.vi v20, v18, -2
    vadd.vx v8, v8, t2
    vxor.vv v10, v8, v14
    vand.vv v12, v10, v8
    vadd.vi v10, v10, 0
    slli t2, t2, 1
    vadd.vv v14, v8, v10
    vle8.v v12, (a0)
    vadd.vv v8, v10, v12
    vmax.vv v14, v8, v10
    vadd.vi v10, v10, 0
    vadd.vi v8, v8, 1
    vsrl.vi v10, v12, 4
    vadd.vi v16, v16, 3
    vsub.vv v12, v10, v8
    or t3, t2, t3
    vadd.vi v20, v20, -5
    vadd.vi v16, v16, 3
    vmaxu.vv v8, v12, v10
    xor t2, t2, t3
    vand.vv v12, v10, v8
    vmin.vv v8, v10, v12
    vadd.vi v14, v14, 5
    vxor.vv v10, v8, v14
    addi t5, zero, -5
    vsub.vv v10, v12, v14
    vadd.vi v20, v20, -5
    vsub.vv v8, v14, v10
    xor t2, t2, t3
    sub t3, t2, t3
    srli t3, t3, 1
    vminu.vv v12, v10, v14
    vadd.vx v10, v12, t2
    vadd.vi v10, v10, 0
    addi t3, t3, -1
    vse8.v v12, (a0)
    vor.vv v14, v8, v12
    vor.vv v10, v12, v14
    vle8.v v14, (a0)
    vadd.vv v16, v18, v20
    vsll.vi v14, v8, 3
    vand.vv v20, v16, v18
    vadd.vx v8, v8, t2
    addi t2, t2, 1
    vadd.vi v8, v8, 1
    vadd.vi v14, v8, 7
    vadd.vi v16, v16, 3
    vadd.vx v8, v8, t2
    vxor.vv v10, v8, v14
    slli t2, t2, 1
    vsll.vi v14, v8, 3
    vsub.vv v8, v14, v10
    vsub.vv v8, v14, v10
    vadd.vi v12, v12, -1
    vsub.vv v8, v14, v10
    vadd.vi v8, v10, 5
    vsub.vv v10, v12, v14
    nop
    addi t5, zero, -5
    vor.vv v14, v8, v12
    vor.vv v10, v12, v14
    vadd.vi v10, v10, 0
    vadd.vi v20, v18, -2
    vse8.v v10, (a0)
    vle8.v v10, (a0)

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
    .word 0xc78e0272
    .word 0x68fc0e45
    .word 0x2a32e553
    .word 0x0b6d35d7
    .word 0x06d6fba7
    .word 0x763f56ac
    .word 0x31c46ef9
    .word 0x09ab99a3

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
