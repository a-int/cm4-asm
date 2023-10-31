MEMORY {
	FLASH : ORIGIN = 0x8000000, LENGTH = 512K
	RAM : ORIGIN = 0x20000000, LENGTH = 128K
}

_estack = ORIGIN(RAM) + LENGTH(RAM);

SECTIONS {
	.isr_vector : {
		KEEP(*(.isr_vector))
	} >FLASH
	
	.text : {
		*(.text)
		*(.text*)
	} >FLASH
	
	_sdata = .;
	.data (NOLOAD) : {
		*(.data)
		*(.data*)
	} >RAM
	_edata = .;
}
