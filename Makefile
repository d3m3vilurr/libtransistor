LD := ld.lld
CC := clang
AS := llvm-mc
LD_FLAGS := -Bsymbolic --shared --emit-relocs --no-gc-sections --no-undefined -T link.T
CC_FLAGS := -g -fPIC -ffreestanding -fexceptions -target aarch64-none-linux-gnu -O0 -mtune=cortex-a53 -I include/
AS_FLAGS := -arch=aarch64
PYTHON2 := python2

libtransistor_OBJECTS := build/lib/svc.o build/lib/ipc.o build/lib/tls.o build/lib/util.o build/lib/ipc/sm.o build/lib/ipc/bsd.o

.SUFFIXES: # disable built-in rules

all: build/test/libtransistor_test.nro build/test/libtransistor_test.nso

build/test/%.o: test/%.c
	mkdir -p $(@D)
	$(CC) $(CC_FLAGS) -c -o $@ $<

build/lib/%.o: lib/%.c
	mkdir -p $(@D)
	$(CC) $(CC_FLAGS) -c -o $@ $<

build/lib/%.o: lib/%.S
	mkdir -p $(@D)
	$(AS) $(AS_FLAGS) $< -filetype=obj -o $@

build/test/%.nro: build/test/%.nro.so
	mkdir -p $(@D)
	$(PYTHON2) ./tools/elf2nxo.py $< $@ nro

build/test/%.nso: build/test/%.nso.so
	mkdir -p $(@D)
	$(PYTHON2) ./tools/elf2nxo.py $< $@ nso

build/test/libtransistor_test.nro.so: build/lib/libtransistor.nro.a build/test/test.o
	mkdir -p $(@D)
	$(LD) $(LD_FLAGS) -o $@ --whole-archive $+

build/test/libtransistor_test.nso.so: build/lib/libtransistor.nso.a build/test/test.o
	mkdir -p $(@D)
	$(LD) $(LD_FLAGS) -o $@ --whole-archive $+

build/lib/libtransistor.nro.a: build/lib/crt0.nro.o $(libtransistor_OBJECTS)
	mkdir -p $(@D)
	rm -f $@
	ar rcs $@ $+

build/lib/libtransistor.nso.a: build/lib/crt0.nso.o $(libtransistor_OBJECTS)
	mkdir -p $(@D)
	rm -f $@
	ar rcs $@ $+

clean:
	rm -rf build/lib/* build/test/*
