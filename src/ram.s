.syntax unified
.cpu cortex-m4
.thumb

.bss
var4b:
        .space 4
var1b:
        .space 1

.text
.global main
main:
        ldr r0, = var4b
        ldr r1, = 0xFFFFAAAA
        str r1, [r0]

        ldr r0, = var1b
        strb r1, [r0]        
        b main
