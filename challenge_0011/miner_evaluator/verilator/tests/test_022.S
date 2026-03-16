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

    vse8.v v18, (a0)
    nop
    vadd.vi v14, v8, 7
    vand.vv v12, v10, v8
    vadd.vi v8, v10, 5
    vor.vv v10, v12, v14
    vsll.vi v14, v8, 3
    vadd.vx v10, v12, t2
    vsub.vv v10, v12, v14
    vadd.vi v20, v18, -2
    vadd.vi v10, v12, -1
    vand.vv v12, v10, v8
    vand.vv v8, v10, v12
    vor.vv v10, v12, v14
    vadd.vi v14, v8, 7
    vsrl.vi v10, v12, 4
    vse8.v v8, (a0)
    vle8.v v14, (a0)
    vle8.v v8, (a0)
    vadd.vv v16, v18, v20
    vadd.vv v12, v8, v14
    vxor.vv v10, v8, v14
    slli t2, t2, 1
    vle8.v v18, (a0)
    vsrl.vi v20, v16, 2
    vse8.v v10, (a0)
    vadd.vi v18, v16, 2
    vsub.vv v12, v10, v8
    vsrl.vi v10, v12, 4
    vmax.vv v14, v8, v10
    vadd.vi v14, v14, 5
    vadd.vv v14, v8, v10
    vmax.vv v14, v8, v10
    vadd.vi v10, v12, -1
    vsub.vv v18, v20, v16
    vadd.vi v20, v18, -2
    vsub.vv v18, v20, v16
    add t2, t2, t3
    vsrl.vi v10, v12, 4
    vsll.vi v8, v10, 2
    vadd.vi v20, v20, -5
    srli t3, t3, 1
    and t2, t2, t3
    vadd.vi v18, v16, 2
    vadd.vv v8, v10, v12
    vand.vv v20, v16, v18
    vsub.vv v8, v14, v10
    .word 0x00850087
    vsll.vi v16, v18, 1
    add t4, t4, t5
    vle8.v v16, (a0)
    vand.vv v12, v10, v8
    vsub.vv v18, v20, v16
    vadd.vv v12, v8, v14
    vsrl.vi v10, v12, 4
    vadd.vi v12, v14, -3
    vse8.v v16, (a0)
    vle8.v v12, (a0)
    addi t2, t2, 1
    slli t2, t2, 1
    addi t2, t2, 1
    vmaxu.vv v8, v12, v10
    vor.vv v16, v18, v20
    vadd.vi v18, v18, 7
    or t3, t2, t3
    add t4, t4, t5
    vle8.v v14, (a0)
    vxor.vv v10, v8, v14
    vand.vv v8, v10, v12
    vadd.vi v10, v10, 0
    vand.vv v8, v10, v12
    vsll.vi v8, v10, 2
    vor.vv v14, v8, v12
    vor.vv v14, v8, v12
    vadd.vi v8, v10, 5
    vle8.v v14, (a0)
    vand.vv v12, v10, v8
    addi t5, zero, -5
    vsub.vv v8, v14, v10
    vadd.vi v20, v18, -2
    vadd.vi v8, v10, 5
    vadd.vi v16, v16, 3
    vadd.vi v12, v12, -1
    vadd.vx v10, v12, t2
    vadd.vi v20, v18, -2
    vmin.vv v8, v10, v12
    vadd.vi v18, v16, 2
    vmax.vv v14, v8, v10
    vadd.vi v20, v18, -2
    vsrl.vi v10, v12, 4
    vadd.vi v10, v10, 0
    vadd.vi v12, v12, -1
    vsrl.vi v10, v12, 4
    vadd.vi v16, v16, 3
    nop
    vadd.vi v10, v12, -1
    vadd.vi v14, v14, 5
    vadd.vi v8, v8, 1
    vle8.v v8, (a0)
    vadd.vi v20, v20, -5
    vle8.v v12, (a0)
    vle8.v v14, (a0)
    or t3, t2, t3
    vse8.v v18, (a0)
    vadd.vi v20, v18, -2
    vadd.vi v16, v16, 3
    addi t2, t2, 1
    vadd.vv v12, v8, v14
    vse8.v v10, (a0)
    vadd.vi v14, v8, 7
    nop
    vadd.vi v16, v16, 3
    vor.vv v10, v12, v14
    vse8.v v10, (a0)
    vsub.vv v8, v14, v10
    vadd.vi v16, v16, 3

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
    .word 0xa46acc9a
    .word 0x61ad018a
    .word 0xc7b611cd
    .word 0x559a8f54
    .word 0x6f2e92b9
    .word 0xc5384872
    .word 0xedbc36d8
    .word 0xa1d770ea

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
