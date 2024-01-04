.syntax unified
.cpu cortex-m4
.thumb

.global main
main:
  @ movement instructions (if imm value is not more than 16 bits)
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

@ memory accsess instructions
@ ldrsh, N @ even if read half-word of
@ ldrsh r0, M
@N: .byte 0xf
@M: .byte 0x1
        ldr r0, =array  @ base address for array
        sub r0, #4      @ decrement 1 word before the array
        mov r1, #0x03   @ the number of bytes in array
ldr_while:
  ldr r2, [r0,#4]!  @ load the next array value
  subs r1, 0x01     @ decrement
  bne ldr_while     @ continue the while loop if there is elemnt in array

  @the same without loop (require more registers to store every word)
  ldr r0, =array
  ldm r0, {r2-r4}
  b main
.align 4
array:
  .word 0x1
  .word 0x2
  .word 0x3