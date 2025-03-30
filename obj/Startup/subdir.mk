################################################################################
# MRS Version: 2.1.0
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Startup/fw_upgrade.c 

C_DEPS += \
./Startup/fw_upgrade.d 

S_UPPER_SRCS += \
../Startup/boot_config.S \
../Startup/custom_boot.S \
../Startup/flash_commands.S \
../Startup/fw_upgrade.S \
../Startup/startup_ch32v00x.S 

S_UPPER_DEPS += \
./Startup/boot_config.d \
./Startup/custom_boot.d \
./Startup/flash_commands.d \
./Startup/fw_upgrade.d \
./Startup/startup_ch32v00x.d 

OBJS += \
./Startup/boot_config.o \
./Startup/custom_boot.o \
./Startup/flash_commands.o \
./Startup/fw_upgrade.o \
./Startup/fw_upgrade.o \
./Startup/startup_ch32v00x.o 



# Each subdirectory must supply rules for building sources it contributes
Startup/%.o: ../Startup/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv-none-embed-gcc -march=rv32ecxw -mabi=ilp32e -msmall-data-limit=0 -msave-restore -fmax-errors=20 -Os -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -fno-common -Wunused -Wuninitialized -g -I"c:/Users/mnsan/mounriver-studio-projects/CH32V003F4P6_Bootloader/Debug" -I"c:/Users/mnsan/mounriver-studio-projects/CH32V003F4P6_Bootloader/Core" -I"c:/Users/mnsan/mounriver-studio-projects/CH32V003F4P6_Bootloader/User" -I"c:/Users/mnsan/mounriver-studio-projects/CH32V003F4P6_Bootloader/Peripheral/inc" -std=gnu99 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@
Startup/%.o: ../Startup/%.S
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv-none-embed-gcc -march=rv32ecxw -mabi=ilp32e -msmall-data-limit=0 -msave-restore -fmax-errors=20 -Os -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -fno-common -Wunused -Wuninitialized -g -x assembler-with-cpp -I"c:/Users/mnsan/mounriver-studio-projects/CH32V003F4P6_Bootloader/Startup" -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@
