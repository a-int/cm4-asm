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
	
############# barriers #####################################
 	@ MSB, DSB, ISB
	@ one of the usage of barries is to ensure the data is written.
	@ almost all section are bufferable (SRAM, devices, peripheral, vendor specific devices)
	@ except code, ram, debug, private peripheral
	@ so if something is important for the next step is written its moved in buffer first
	@ to ensure the data has been written the DSB has to be exetued (+ISB possible)
	@ for example 
	@ *copy vector table into the new position*
	dmb @ memory access sync
	@ SVC->VTOR = newTablePosition // update vector table address using offset
	dsb @ ensure the VTOR was updated


############# SVC ##########################################

@@@@@@@@@@ bit-band (may not be supported by some CM4/3) @@@@@@@@@@@@@@@@@@@@@@@

	ldr r0, =0x20000000	@ that minimum address of bit-band region in SRAM
	ldr r1, =0x3a558eFF	@ some constant to write
	str r1, [r0]		@ save the value into the memory

	@ clear the bit 2 using bit-band operatios
	ldr r0, =0x22000008	@ bit 0 is 0x...0; bit 1 is 0x...4 and so on 
	mov r1, #0
	str r1, [r0]	@ clear the bit 2	
	
	ldr r1, [r0]	@ bit 2 is zero eg. r1 will be zero too
	ldr r0, =0x20000000
	ldr r1, [r0]	@ SRAM[0x20000000] now is 0x3a558eFB

@@@@@@@@@@@@ ISR @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	@ the ISR can be masked (eighet all except hard fault, NMI and reset, or hard falut too)
	@ can be determined the currently executing ISR via IPSR (xPSR[7:0])
	@ can be masked by BASEPRI. The disabled if 0 and blocks all ISR with the same or higher (number) level

	@ ISR 0-15 are the systemd interrupts for reset, hard fault, other faults, debug, SVC, SySTick
	@ ISR 16- 240 are the vendor specific ISRs for timers, peripherals and so on

	@ the priotity level is determined by N MSB bits in BASEPRI
	@ the max is 8 bit [7:0]. If less than lsb are cutting of and it always 0 (writing is ignored)
	@ when configuring BASEPRI the number of groups and sub-groups has to be considered
	@ the number of groups defines the number of pre-emtions 
	@ and sub groups defines the number of ISRs at that level do be selected
	@ if 3 bits are available and group are [7:6] and sub are [5] then  4 groups and 2 sub groups are availabe 
	@ the next ISR to be execute is the ISR with highest gorup and sub-group (in that group)
	@ so for the config with such 3 bits if 2 ISR are happend (0x05, 0x06) they have the same group and sub
	@ then the the level of ISR is considered and 0x05 takes place 1st

	@ VTOR must be aligned to the size of factor 2 enough to store table
	@ the ISR is served (the mode is changed from thread to Handler) only if that is the currently highest
	@ pending ISR. And the next pending may be considered only if that mode switch has occured.
	@ work the same for level based ISRs and pulse ISRs (the pulses considered as the same pending until mode switch)
	@ pending status may occur even if the ISR is disabled, so before enable it clear interrupt pending status register

@@@@@@@@@ NVIC operations @@@@@@@@@@@@@@@@@@@@@
	@ iser/icer, ispr/icpr, iabr, ip, stir
	NVIC_ISER0 = 0xE000E100	@ NVIC Interrupt Set Enable Register 0
	NVIC_ICER0 = 0xE000E180	@ NVIC Interrupt Clear Enable Register 0
	NVIC_IABR0 = 0xE000E300	@ NVIC Interrupt Active Bit Register 0
	ldr r1, = NVIC_ISER0	@ load the address of IRQ Set Enable Reg 0
	movs r0, 0x1			@ select the IRQ 1
	str r0, [r1]			@ enable the 1st non system IRQ 

	ldr r1, = NVIC_IABR0	@ set new address
	ldr r2, [r1]			@ load active bits for first 32 non system IRQs
	ands r2, #0x100			@ check if the 1st non system IRQ is active 
							@ (IABR works with system IRQs too so 1st non system after 16 of system IRqs)
	ITT EQ					@ if no active then turn that IRQ off
	ldreq r1, = NVIC_ICER0	@ load the address of IRQ Clear Enable Reg 0
	streq r0, [r1]			@ disable 1st non system IRQ

	NVIC_IP0 = 0xE000E400
	ldr r1, =NVIC_IP0
	mov r0, #0xff
	str r0, [r1]			@ try to write 8 ones to priority register of IRQ 16
	ldr r0, [r1]			@ check how many ones available for priority

	NIVC_STIR0 = 0xE000EF00
	ldr r1, =NIVC_STIR0
	mov r0, #0x0	@ the number of external IRQ to trigger (IRQ 16 == 0x00)
	str r0, [r1]	@ trigger IRQ 16
					@ due to disabled status of IRQ 16 its in constant pending status
	ldr r1, =NVIC_IABR0
	ldr r2, [r1]	@ check active status of triggered IRQ (the pending IRQ is marked by '1')

	NVIC_ISPR0 = 0xE000E200
	NVIC_ICPR0 = 0xE000E280
	ldr r1, =NVIC_ICPR0
	mov r0, #0x1
	str r0, [r1] @clear the pending status of IRQ 16

	ldr r1, =NVIC_ISPR0
	ldr r2, [r1] 		@ check the pending status of first 32 external IRQs



	b main
.align 4  @ the data must be aligned
array:
  .word 0x1
  .word 0x2
  .word 0x3