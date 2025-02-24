################################################################################
# MRS Version: 2.1.0
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
S_UPPER_SRCS += \
../Startup/boot_config.S \
../Startup/custom_boot.S \
../Startup/startup_ch32v00x.S 

S_UPPER_DEPS += \
./Startup/boot_config.d \
./Startup/custom_boot.d \
./Startup/startup_ch32v00x.d 

OBJS += \
./Startup/boot_config.o \
./Startup/custom_boot.o \
./Startup/startup_ch32v00x.o 



# Each subdirectory must supply rules for building sources it contributes
Startup/%.o: ../Startup/%.S
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv-none-embed-gcc -march=rv32ecxw -mabi=ilp32e -msmall-data-limit=0 -msave-restore -fmax-errors=20 -Os -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -fno-common -Wunused -Wuninitialized -g -x assembler-with-cpp -I"c:/Users/mnsan/mounriver-studio-projects/CH32V003F4P6_Bootloader/Startup" -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@
