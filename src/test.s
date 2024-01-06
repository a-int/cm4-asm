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
@@@@@@@@@@@@@@@@@@@@@ extend operations @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	@ sxtb, sxth, uxtb, uxth   rev, rev16, revsh
	ldr r0, =0x55aa8765
	sxtb r1, r0 @ r1 = 0x00000065  
	sxth r1, r0 @ r1 = 0xffff8765  
	uxtb r1, r0 @ r1 = 0x00000065  
	uxth r1, r0 @ r1 = 0x00008765  

	rev r1, r0  @ r1 = 0x6587aa55
	rev16 r1, r0 @ r1 = 0xaa556587
	revsh r1, r0 @ r1 = 0x00006587
@@@@@@@@@@@@@@@@@@@@@ bit-field operations @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	@ bfc, bfi, clz, rbit, sbfx, ubfx

	mov r0, #0xff00
	mov r1, #0xffff
	bfc r0, #0, 16 @ clear 16 bits starting from 0 bit
	bfi r0, r1, #0, #4 @ copy 4 bits from r1 to r0 starting from 8th bit of r1
	clz r0, r0  @ count leading zeroes r0 = 0x0000000f
	rbit r0, r0 @ reverse bits r0 = 0x0000000f
	sbfx r0, r1, #0, #4 @ copy 4 bits from 0th from r1 to r0 (sign-extended)
	ubfx r0, r1, #0, #4 @ copy 4 bits from 0th from r1 to r0
@@@@@@@@@@@@@@@@@@@@@ compare and test operations @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2
	@ the N is set if Rd is negative
	@ the Z is set if Rd = 0
	@ the C flag is set if
	@ if result of addition has more than 32 bits
	@ if result of subtraction is not negative
	@ shift or mov ops
	@ the V flag is set if signed overflow occured
	@ cmp, cmn, tst, teq
	mov r0, #0xff
	mov r1, #0x0f
	cmp r0, r1
	cmp r0, #0xff
	cmn r0, r1
	cmn r0, #-15 @ may be converted into "cmp r0, #15"

	mov r0, 0x80000000
	mov r1, 0xf0000000
	tst r0, r1  @ N flag will be set
	tst r0, #0xF  @ the Z flag will be set and N is reset

@@@@@@@@@@@@@@@@ available suffixes @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ eq/ne, mi/pl, cs/cc, vs/vc, hi/hc, ge/le, gt/lt 
	mov r0, #0xff
	mov r1, #0xff
t1:	@@@@@@@@@@@@ N flag @@@@@@@@@@@@@@@@@@@@@@@@@@
	subs r3, r0, #0x100   @ r0 = 0xff - 0x100 = -1 (N is set)
	bpl texit	@ exit tests if N = 0
	subs r3, r0, #0x0f  @ r0 = 0xff - 0x0f = 0xf0 (N is reset)
	bmi texit	@ exit tests if N = 1
t2: @@@@@@@@@@@@@ Z flag @@@@@@@@@@@@@@@@@@@
	subs r3, r0, r1 @r0 = r0 - r1 = 0 (Z = 1)
	bne texit	@ exit tests if Z reset
	subs r3, r0, #0x0F   @ r0 = 0xff - 0x0f = 0xf0 (Z = 0)
	beq texit	@ exit tests if Z = 1
t3:	@@@@@@@@@ C flag @@@@@@@@@@@@@@@@@@@
	subs r3, r0, #0x0f @ r0 = r0 - 0x0f = 0xf0 (C = 1)
	bcc texit	@ exit tests if N = 0
	subs r3, r0, #0x100 @ r0 = r0 - 0x0f = 0xf0 (C = 0)
	bcs texit
t4:	@@@@@@@@@@@@@@@@ V flag @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	mov r3, #0x80000000
	subs r3, #1		@ r3 = 0x80000000 - 0x1 = 0x7fffffff (sign overflow)
	bvc texit
	adds r3, #1 @ sign overflow again
	bvc texit
t5:	@@@@@@@@@@@@@ signed tests @@@@@@@@@@@@@@@@@@@@@@@@@@
	movs r0, 0x00
	movs r1, 0x01
	subs r3, r0, r1	@ r0 < r1
	bge texit @ go to exit if r0 >= r1

	subs r3, r0, r1	@ r0 <= r1
	bgt texit @ go to exit if r0 > r1

	subs r3, r1, r0	@ r1 > r0
	ble texit	@ go to exit if r1 <= r0

	subs r3, r1, r0	@ r1 >= r0
	blt texit	@ go to exit if r1 < r0
t6: @@@@@@@@@@@@@ unsigned tests @@@@@@@@@@@@@@@@@@@
	mov r0, #0x0f
	mov r1, #0x0A
	subs r3, r0, r1 @ r0 is higher 
	bls texit @ go to exit if r0 is lower or the same as r1
	subs r3, r0, #0x0f	@ r0 is the same as 0x0f
	bhi texit @ go to exit if r0 is higher than the 0x0f
texit: NOP

@@@@@@@@@@@ CBZ/CBZN and IT blocks @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	@ cbz/cbzn is an ooperation for quick zero/nonzero check with branch
	mov r0, #0x5
cbz_while: 
	cbz r0, cbz_while_exit
	subs r0, #1
	b cbz_while
cbz_while_exit: NOP

	movs r0, #0x0	@ trigger Z flag
	ITE EQ	@ if Z is set
	@movseq r0, #0x1	@ its prohibited to change APSR in IT block
						@ for that line the Z will be reset so except
						@ block will be executed too
						@ 16 bit commands (without S suffix) won't change APSR
	moveq r0, #0x01	@ the correct command style for IT block
	movne r0, #0x2 @ its ok for last command in IT block 
					@ the comands in IT block anyway take a cycle even if not used
@@@@@@@@@@@@@@@ Table branches @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	@ tbb, tbh
	movs r0, 0x01	@ select case #1
	tbb [pc, r0]		@ select the case number
tb_start:
	.byte ((tb_case1-tb_start)/2)	@ case 0
	.byte ((tb_case2-tb_start)/2)	@ case 1
	.byte ((tb_case3-tb_start)/2)	@ case 2

.align 2	@ the alignmnet is required if table has not even number of elements
tb_case1:
	movs r0, #1
	b tb_exit
tb_case2:
	movs r0, #2
	b tb_exit
tb_case3:
	movs r0, #3
tb_exit:
	NOP
@@@@@@@@@@@@@@@@@ saturation @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@	ssat, usat
	ldr r0, =-145348	@ some negative 18 bit value
	usat r1, #16, r0	@ unsigned saturation fixes this negative number on 0
	ssat r1, #16, r0	@ signed saturation fixes this negative number at
						@ maximum negative 16 bit signed value eg. 0x8000
	
	
	b main
.align 4  @ the data must be aligned
array:
  .word 0x1
  .word 0x2
  .word 0x3