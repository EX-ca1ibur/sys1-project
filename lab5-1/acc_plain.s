        .text
        .globl  acc
acc:
        addi    sp,sp,-48
        sd      s0,40(sp)
        addi    s0,sp,48
        sd      a0,-40(s0)
        sd      a1,-48(s0)
        sd      zero,-32(s0)
        ld      a5,-40(s0)
        sd      a5,-24(s0)
        j       .L2
.L3:
        ld      a4,-32(s0)
        ld      a5,-24(s0)
        add     a5,a4,a5
        sd      a5,-32(s0)
        ld      a5,-24(s0)
        addi    a5,a5,1
        sd      a5,-24(s0)
.L2:
        ld      a4,-24(s0)
        ld      a5,-48(s0)
        ble     a4,a5,.L3
        ld      a5,-32(s0)
        mv      a0,a5
        ld      s0,40(sp)
        addi    sp,sp,48
        jr      ra