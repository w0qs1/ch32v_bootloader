################################################################################
# MRS Version: 2.1.0
# Automatically-generated file. Do not edit!
################################################################################
-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include User/subdir.mk
-include Startup/subdir.mk
-include Peripheral/src/subdir.mk
-include Debug/subdir.mk
-include Core/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(S_DEPS)),)
-include $(S_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(ASM_DEPS)),)
-include $(ASM_DEPS)
endif
ifneq ($(strip $(ASM_UPPER_DEPS)),)
-include $(ASM_UPPER_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
SECONDARY_FLASH += \
CH32V003F4P6_Bootloader.bin \

SECONDARY_LIST += \
CH32V003F4P6_Bootloader.lst \

SECONDARY_SIZE += \
CH32V003F4P6_Bootloader.siz \


# All Target
all: 
	$(MAKE) --no-print-directory main-build 
	$(MAKE) --no-print-directory post-build 

main-build: CH32V003F4P6_Bootloader.elf secondary-outputs

post-build: 
	python ../Post_Build/add_crc32_end.py CH32V003F4P6_Bootloader.bin CH32V003F4P6_Bootloader_CRC.bin

# Tool invocations
CH32V003F4P6_Bootloader.elf: $(OBJS) $(USER_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: GNU RISC-V Cross C Linker'
	riscv-none-embed-gcc -march=rv32ecxw -mabi=ilp32e -msmall-data-limit=0 -msave-restore -fmax-errors=20 -Os -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -fno-common -Wunused -Wuninitialized -g -T "c:/Users/mnsan/mounriver-studio-projects/CH32V003F4P6_Bootloader/Ld/Link.ld" -nostartfiles -Xlinker --gc-sections -Wl,-Map,"CH32V003F4P6_Bootloader.map" --specs=nano.specs --specs=nosys.specs -o "CH32V003F4P6_Bootloader.elf" $(OBJS) $(USER_OBJS) $(LIBS) -lprintf
	@echo 'Finished building target: $@'
	@
CH32V003F4P6_Bootloader.bin: CH32V003F4P6_Bootloader.elf
	@echo 'Invoking: GNU RISC-V Cross Create Flash Image'
	@	riscv-none-embed-objcopy -O binary "CH32V003F4P6_Bootloader.elf" "CH32V003F4P6_Bootloader.bin"
	@echo 'Finished building $@'
	@
CH32V003F4P6_Bootloader.lst: CH32V003F4P6_Bootloader.elf
	@echo 'Invoking: GNU RISC-V Cross Create Listing'
	@	riscv-none-embed-objdump --all-headers --demangle --disassemble -M xw "CH32V003F4P6_Bootloader.elf" > "CH32V003F4P6_Bootloader.lst"
	@echo 'Finished building $@'
	@
CH32V003F4P6_Bootloader.siz: CH32V003F4P6_Bootloader.elf
	@echo 'Invoking: GNU RISC-V Cross Print Size'
	riscv-none-embed-size --format=berkeley "CH32V003F4P6_Bootloader.elf"
	@echo 'Finished building $@'
	@

# Other Targets
clean:
	-$(RM) $(OBJS)$(SECONDARY_FLASH)$(SECONDARY_LIST)$(SECONDARY_SIZE)$(S_DEPS)$(S_UPPER_DEPS)$(ASM_DEPS)$(ASM_UPPER_DEPS)$(C_DEPS) CH32V003F4P6_Bootloader.elf

secondary-outputs: $(SECONDARY_FLASH) $(SECONDARY_LIST) $(SECONDARY_SIZE)

.PHONY: all clean dependents

-include ../makefile.targets