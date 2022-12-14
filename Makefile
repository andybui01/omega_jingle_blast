# Build
CC=riscv64-unknown-elf-gcc
CFLAGS=-ffreestanding -nostartfiles -nostdlib -nodefaultlibs
CFLAGS+=-g -Wl,--gc-sections -mcmodel=medany
RUNTIME=src/asm/crt0.s
LINKER_SCRIPT=src/lds/riscv64-virt.ld

# Output
KERNEL_IMAGE=obj_final_img

# QEMU
QEMU=qemu-system-riscv64
MACH=virt
MEM=128M
RUN=$(QEMU) -nographic -machine $(MACH) -m $(MEM)
RUN+=-bios none -kernel $(KERNEL_IMAGE)

# QEMU (debug)
GDB_PORT=1234

all: uart syscon common kmain
	$(CC) *.o $(RUNTIME) $(CFLAGS) -T $(LINKER_SCRIPT) -o $(KERNEL_IMAGE)

uart:
	$(CC) -c src/uart/uart.c $(CFLAGS) -o uart.o

syscon:
	$(CC) -c src/syscon/syscon.c $(CFLAGS) -o syscon.o

common:
	$(CC) -c src/common/common.c $(CFLAGS) -o common.o

kmain:
	$(CC) -c src/kmain.c $(CFLAGS) -o kmain.o

run: all
	$(RUN)

debug: all
	$(RUN) -gdb tcp::$(GDB_PORT) -S

clean:
	rm -vf *.o
	rm -vf $(KERNEL_IMAGE)
