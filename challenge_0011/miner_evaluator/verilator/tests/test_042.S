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

    add t2, t2, t3
    vsub.vv v8, v14, v10
    nop
    vse8.v v8, (a0)
    vadd.vi v14, v8, 7
    vadd.vi v12, v12, -1
    vadd.vi v8, v10, 5
    vand.vv v20, v16, v18
    vand.vv v12, v10, v8
    vadd.vi v18, v18, 7
    vxor.vv v14, v10, v8
    vse8.v v12, (a0)
    vle8.v v14, (a0)
    vadd.vi v12, v12, -1
    vle8.v v14, (a0)
    vle8.v v8, (a0)
    vor.vv v16, v18, v20
    vsrl.vi v20, v16, 2
    xor t2, t2, t3
    vand.vv v20, v16, v18
    vnsrl.wi v5, v4, 0
    vsll.vi v14, v8, 3
    vse8.v v10, (a0)
    or t3, t2, t3
    vadd.vi v14, v8, 7
    vand.vv v8, v10, v12
    addi t2, t2, 1
    vsrl.vi v10, v12, 4
    slli t2, t2, 1
    addi t4, zero, 10
    vadd.vi v10, v12, -1
    vminu.vv v12, v10, v14
    vadd.vi v12, v14, -3
    vadd.vi v20, v18, -2
    vsub.vv v12, v10, v8
    vminu.vv v12, v10, v14
    vor.vv v16, v18, v20
    vadd.vi v14, v8, 7
    vor.vv v10, v12, v14
    vxor.vv v10, v8, v14
    vsub.vv v12, v10, v8
    vadd.vi v20, v20, -5
    vle8.v v18, (a0)
    vand.vv v12, v10, v8
    vadd.vi v8, v10, 5
    vle8.v v16, (a0)
    vsll.vi v14, v8, 3
    vand.vv v12, v10, v8
    vsub.vv v10, v12, v14
    vse8.v v12, (a0)
    vadd.vi v10, v12, -1
    vadd.vi v20, v18, -2
    vminu.vv v12, v10, v14
    vadd.vi v12, v14, -3
    vor.vv v14, v8, v12
    vand.vv v20, v16, v18
    vadd.vx v10, v12, t2
    vnsrl.wi v5, v4, 0
    add t2, t2, t3
    addi t4, zero, 10
    vse8.v v18, (a0)
    nop
    vadd.vi v18, v16, 2
    vor.vv v14, v8, v12
    nop
    vmaxu.vv v8, v12, v10
    vsll.vi v8, v10, 2
    addi t2, t2, 1
    sub t3, t2, t3
    vadd.vv v8, v10, v12
    vand.vv v20, v16, v18
    vor.vv v16, v18, v20
    vxor.vv v14, v10, v8
    and t2, t2, t3
    vadd.vx v10, v12, t2
    srli t3, t3, 1
    addi t2, t2, 1
    vse8.v v8, (a0)
    vsll.vi v8, v10, 2
    vand.vv v8, v10, v12
    vadd.vi v14, v8, 7
    vor.vv v10, v12, v14
    vadd.vv v8, v10, v12
    vsrl.vi v20, v16, 2
    vminu.vv v12, v10, v14
    vse8.v v18, (a0)
    vadd.vi v10, v12, -1
    vadd.vi v10, v10, 0
    vsrl.vi v12, v14, 1
    vand.vv v8, v10, v12
    vmax.vv v14, v8, v10
    and t2, t2, t3
    addi t2, t2, 1
    vadd.vi v18, v18, 7
    vse8.v v18, (a0)
    vadd.vi v10, v12, -1
    vsrl.vi v20, v16, 2
    vor.vv v10, v12, v14
    and t2, t2, t3
    addi t5, zero, -5
    vadd.vi v8, v8, 1
    sub t3, t2, t3
    vadd.vi v12, v12, -1
    vadd.vv v16, v18, v20
    vadd.vx v8, v8, t2
    nop
    addi t4, zero, 10
    vsub.vv v8, v14, v10
    vadd.vv v14, v8, v10
    vsub.vv v8, v14, v10
    vadd.vi v20, v20, -5
    add t2, t2, t3
    vle8.v v14, (a0)
    vadd.vi v8, v8, 1

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
    .word 0x86daf596
    .word 0xced89c97
    .word 0x9a7171aa
    .word 0x60bc6cbc
    .word 0x054da360
    .word 0xd399956c
    .word 0x0b328c23
    .word 0x15668483

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
