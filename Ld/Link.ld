ENTRY( _start )

__stack_size = 256;

PROVIDE( _stack_size = __stack_size );

MEMORY
{
	FLASH_BOOT (rx) : ORIGIN = 0x00000000, LENGTH = 3K          /*User alloted space for bootloader. Must be >= size of bootloader*/
  FLASH_APPL (rx) : ORIGIN = 0x00000C00, LENGTH = 3K - 64     /*Start of application code*/
  FLASH_CNFG (rx) : ORIGIN = 0x00003FC0, LENGTH = 64          /*Location of boot configuration*/
	RAM (xrw)  : ORIGIN = 0x20000000, LENGTH = 2K
}

SECTIONS
{
    /*Startup Code is also placed in bootloader space*/
    .init :
    { 
      _sinit = .;
      . = ALIGN(4);
      KEEP(*(SORT_NONE(.init)))
      . = ALIGN(4);
      _einit = .;
    } >FLASH_BOOT AT>FLASH_BOOT

    .highcodelalign : 
    {       
        . = ALIGN(4);
        PROVIDE(_highcode_lma = .); 
    } >FLASH_APPL AT>FLASH_APPL 
    
    .highcode : 
    {
        . = ALIGN(4);
        PROVIDE(_highcode_vma_start = .);
        *(.highcode);
        *(.highcode.*);
		. = ALIGN(4); 
        PROVIDE(_highcode_vma_end = .);
    } >RAM AT>FLASH_APPL

    /*User added section to ensure that bootloader and application do not share pages in FLASH*/
    .bootloader :
    {
      . = ALIGN(4);
      *(.text.bootloader)
      *(.text.handle_reset)
      *ch32v00x_flash.o(.text*)
      *(.rodata.bootloader)
    } >FLASH_BOOT AT>FLASH_BOOT
    
    /*Application code and rodata*/
    .text :
    {
      . = ALIGN(4);
      *(.text)
      *(.text.*)
      *(.rodata)
      *(.rodata*)
      *(.gnu.linkonce.t.*)
      . = ALIGN(4);
    } >FLASH_APPL AT>FLASH_APPL 

    /*To store the length of the file*/
    .bootcfg :
    {
      . = ALIGN(4);
      FW_LEN = .;
      LONG(_etext)
      LONG(SystemInit)
      LONG(main)
    } >FLASH_CNFG AT>FLASH_CNFG

    .fini :
    {
      PROVIDE( _etext = . );  /* Modified to properly set the end of firmware */
      KEEP(*(SORT_NONE(.fini)))
      . = ALIGN(4);
    } >FLASH_APPL AT>FLASH_APPL

    /*PROVIDE( _etext = . );*/
    PROVIDE( _eitcm = . );  

    .preinit_array :
    {
      PROVIDE_HIDDEN (__preinit_array_start = .);
      KEEP (*(.preinit_array))
      PROVIDE_HIDDEN (__preinit_array_end = .);
    } >FLASH_APPL AT>FLASH_APPL 
  
    .init_array :
    {
      PROVIDE_HIDDEN (__init_array_start = .);
      KEEP (*(SORT_BY_INIT_PRIORITY(.init_array.*) SORT_BY_INIT_PRIORITY(.ctors.*)))
      KEEP (*(.init_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .ctors))
      PROVIDE_HIDDEN (__init_array_end = .);
    } >FLASH_APPL AT>FLASH_APPL 
  
    .fini_array :
    {
      PROVIDE_HIDDEN (__fini_array_start = .);
      KEEP (*(SORT_BY_INIT_PRIORITY(.fini_array.*) SORT_BY_INIT_PRIORITY(.dtors.*)))
      KEEP (*(.fini_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .dtors))
      PROVIDE_HIDDEN (__fini_array_end = .);
    } >FLASH_APPL AT>FLASH_APPL 
  
    .ctors :
    {
      /* gcc uses crtbegin.o to find the start of
         the constructors, so we make sure it is
         first.  Because this is a wildcard, it
         doesn't matter if the user does not
         actually link against crtbegin.o; the
         linker won't look for a file to match a
         wildcard.  The wildcard also means that it
         doesn't matter which directory crtbegin.o
         is in.  */
      KEEP (*crtbegin.o(.ctors))
      KEEP (*crtbegin?.o(.ctors))
      /* We don't want to include the .ctor section from
         the crtend.o file until after the sorted ctors.
         The .ctor section from the crtend file contains the
         end of ctors marker and it must be last */
      KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .ctors))
      KEEP (*(SORT(.ctors.*)))
      KEEP (*(.ctors))
    } >FLASH_APPL AT>FLASH_APPL 
  
    .dtors :
    {
      KEEP (*crtbegin.o(.dtors))
      KEEP (*crtbegin?.o(.dtors))
      KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .dtors))
      KEEP (*(SORT(.dtors.*)))
      KEEP (*(.dtors))
    } >FLASH_APPL AT>FLASH_APPL 

    .dalign :
    {
      . = ALIGN(4);
      PROVIDE(_data_vma = .);
    } >RAM AT>FLASH_APPL  

    .dlalign :
    {
      . = ALIGN(4); 
      PROVIDE(_data_lma = .);
    } >FLASH_APPL AT>FLASH_APPL

    .data :
    {
      . = ALIGN(4);
      *(.gnu.linkonce.r.*)
      *(.data .data.*)
      *(.gnu.linkonce.d.*)
      . = ALIGN(8);
      PROVIDE( __global_pointer$ = . + 0x800 );
      *(.sdata .sdata.*)
      *(.sdata2*)
      *(.gnu.linkonce.s.*)
      . = ALIGN(8);
      *(.srodata.cst16)
      *(.srodata.cst8)
      *(.srodata.cst4)
      *(.srodata.cst2)
      *(.srodata .srodata.*)
      . = ALIGN(4);
      PROVIDE( _edata = .);
    } >RAM AT>FLASH_APPL

    .bss :
    {
      . = ALIGN(4);
      PROVIDE( _sbss = .);
      *(.sbss*)
      *(.gnu.linkonce.sb.*)
      *(.bss*)
      *(.gnu.linkonce.b.*)    
      *(COMMON*)
      . = ALIGN(4);
      PROVIDE( _ebss = .);
    } >RAM AT>FLASH_APPL

    PROVIDE( _end = _ebss);
	PROVIDE( end = . );    

	.stack ORIGIN(RAM) + LENGTH(RAM) - __stack_size :
	{
	    PROVIDE( _heap_end = . );
	    . = ALIGN(4);
	    PROVIDE(_susrstack = . );
	    . = . + __stack_size;
	    PROVIDE( _eusrstack = .);
	} >RAM 
}



