.syntax unified
.cpu cortex-m4
.thumb

.global main
main:
  @ to use the 16 bit version the S suffix must be used and r0-r7 registers only

@@@@@@@@@@@@@@@@@@@@@@ mov operations @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @ mov, movs, mov.w, movt, movw, mvn, mrs, msr
  movs r0, #0xff @ 16 bits instruction if imm 8 bit and rd = [r0;r7], otherwise the same as movs.w 
  @ movs r12, #0xff @ the same as movs.w
  @ movs r0, #0xffff @ the same as mov.w
  @ movs r12, #0xfff @ the same as mov.w
  mov  r0, #0xff @ the same as "mov.w" (even when imm <= 0xFF), 32 bit instruction
  movw r0, #0xffff @ the mov version with 16 bit imm value (fills LSB 16 bits), 32 bit instruction
  movt r0, #0xffff @ the mov version with 16 bit imm value (fills MSB 16 bits), 32 bit instruction

  @ if imm value is greater than 16 bits than the ldr instruction is used
  ldr r0, =0x12345678
  @ may be converted by into mov.w for trivial imm
  @ for example mov.w r0, 0xffffffff

@@@@@@@@@@@@@@@@@@@@ ldr operations @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @ ldrb, strb, ldrh, strh, ldr, str, ldm, stm,       ldrsb, strsb, ldrsh, strsh
@ ldrsh, N @ even if read half-word of
@ ldrsh r0, M
@N: .byte 0xf
@M: .byte 0x1
  ldrb r0, array

  ldr r0, =array  @ base address for array
  sub r0, #4      @ decrement 1 word before the array
  mov r1, #0x03   @ the number of bytes in array
ldr_while:
  ldr r2, [r0,#4]!  @ load the next array value
  subs r1, 0x01     @ decrement
  bne ldr_while     @ continue the while loop if there is elemnt in array

  @the same without loop (require more registers to store every word)
  ldr r0, =array
  ldmia r0, {r2-r4}
@@@@@@@@@@@@@@@@@@@@ arithmetical operations @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @ add, adc, sub, rsb, mul, sdiv, udiv +s suffix or .w
  add r2, r2, r3  @ 16 bit instruction
  add r2, r3      @ the same but shorter
  add r2, #0x4000 @ 32 bit the add with maximum imm value (14 bit)
  rsb r2, r2, #0x4000 @reverse subtraction
  movs r0, #0x2
  movs r1, #0x2
  mul r3, r1, r0
  udiv r3, r1
@@@@@@@@@@@@@@@@@@@ logical operations @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @ and, orr, orn, eor, bic
  mov r0, 0xff
  mov r1, 0x0f
  ands r0,r1  @ logical AND
  mov r0, #0xff
  bics r0, #0x0f @ clear the bits marked by 1s
@@@@@@@@@@@@@@@@@@@@@ shift operations @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @ lsl, lsr, ror, rrx, asr
  movs r0, #0x01  @ r0 = 0x00000001
  lsls r0, #0x03  @ r0 = 0x00000008
  lsrs r0, #0x03  @ r0 = 0x00000001
  rors r0, #0x1   @ r0 = 0x80000000
  rors r0, #31    @ there is no rol so "rol r0, #imm" is eq ror r0, #(32-imm)
  orrs r0, 0x80000000 @set the bit 31 for asr
  asrs r0, #1 @ 0x80000001 -> 0xC0000000

  b main

.align 4  @ the data must be aligned
array:
  .word 0x1
  .word 0x2
  .word 0x3