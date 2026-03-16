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

    vle8.v v16, (a0)
    vsrl.vi v10, v12, 4
    vxor.vv v14, v10, v8
    addi t5, zero, -5
    vadd.vi v8, v8, 1
    vadd.vi v20, v20, -5
    vxor.vv v10, v8, v14
    vadd.vi v8, v8, 1
    vse8.v v10, (a0)
    vsetvli t0, zero, e8, m2, ta, ma
    vadd.vv v2, v15, v0
    vsetvli t0, zero, e8, m1, ta, ma
    vxor.vv v10, v8, v14
    vadd.vi v12, v12, -1
    vsub.vv v12, v10, v8
    vadd.vv v16, v18, v20
    vsub.vv v18, v20, v16
    vadd.vi v16, v16, 3
    addi t4, zero, 10
    vadd.vi v14, v8, 7
    vse8.v v12, (a0)
    vadd.vi v16, v16, 3
    vse8.v v16, (a0)
    vminu.vv v12, v10, v14
    vsrl.vi v10, v12, 4
    vadd.vv v14, v8, v10
    vadd.vx v10, v12, t2
    vadd.vi v14, v14, 5
    vadd.vi v14, v14, 5
    vle8.v v14, (a0)
    or t3, t2, t3
    add t4, t4, t5
    vle8.v v8, (a0)
    addi t4, zero, 10
    vsrl.vi v12, v14, 1
    vadd.vi v12, v14, -3
    vadd.vv v16, v18, v20
    vle8.v v14, (a0)
    vor.vv v10, v12, v14
    vadd.vi v10, v12, -1
    vsll.vi v16, v18, 1
    vadd.vv v12, v8, v14
    vadd.vv v14, v8, v10
    vor.vv v16, v18, v20
    vle8.v v12, (a0)
    vle8.v v14, (a0)
    vand.vv v8, v10, v12
    vadd.vv v8, v10, v12
    vse8.v v16, (a0)
    nop
    vminu.vv v12, v10, v14
    vadd.vv v14, v8, v10
    addi t5, zero, -5
    vmaxu.vv v8, v12, v10
    vadd.vi v8, v10, 5
    vsub.vv v18, v20, v16
    vadd.vi v18, v16, 2
    vle8.v v14, (a0)
    vadd.vx v8, v8, t2
    vadd.vv v14, v8, v10
    vle8.v v16, (a0)
    vadd.vi v8, v8, 1
    vadd.vv v14, v8, v10
    vmax.vv v14, v8, v10
    vsll.vi v14, v8, 3
    srli t3, t3, 1
    vsrl.vi v20, v16, 2
    xor t2, t2, t3
    vadd.vv v14, v8, v10
    vsll.vi v8, v10, 2
    or t3, t2, t3
    vxor.vv v10, v8, v14
    vor.vv v16, v18, v20
    vsll.vi v16, v18, 1
    vxor.vv v14, v10, v8
    vadd.vi v16, v16, 3
    and t2, t2, t3
    vadd.vi v18, v16, 2
    vse8.v v16, (a0)
    vle8.v v16, (a0)
    vand.vv v12, v10, v8
    vsll.vi v14, v8, 3
    vor.vv v16, v18, v20
    vadd.vi v12, v12, -1
    vadd.vi v16, v16, 3
    vsrl.vi v10, v12, 4
    vle8.v v16, (a0)
    vadd.vi v12, v14, -3
    vadd.vv v12, v8, v14
    vsrl.vi v10, v12, 4
    vadd.vi v10, v10, 0

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
    .word 0xf610f40d
    .word 0x4da838b7
    .word 0xbd03d33b
    .word 0x301c6abf
    .word 0x21acfdb5
    .word 0x9df034d3
    .word 0x9cc3c1f5
    .word 0x98ab182c

    .section .tohost, "aw", @progbits
    .align 2
    .globl _tohost
_tohost:
    .word 0
