# Attempt to work with either sail from opam or built from repo in SAIL_DIR
ifneq ($(SAIL_DIR),)
# Use sail repo in SAIL_DIR
SAIL:=$(SAIL_DIR)/sail
export SAIL_DIR
else
# Use sail from opam package
SAIL_DIR:=$(shell opam var sail:share)
SAIL:=sail
endif

SAIL_X86_DIR=sail-x86
SAIL_X86_MODEL_DIR=$(SAIL_X86_DIR)/model
SAIL_CHERI_MODEL_DIR=src

PRELUDE_SAILS = $(SAIL_X86_MODEL_DIR)/prelude.sail \
		$(SAIL_X86_MODEL_DIR)/register_types.sail \
		$(SAIL_X86_MODEL_DIR)/registers.sail \
		$(SAIL_X86_MODEL_DIR)/register_accessors.sail \
		$(SAIL_X86_MODEL_DIR)/memory_accessors.sail \
		$(SAIL_X86_MODEL_DIR)/opcode_ext.sail
MAIN_SAIL=$(SAIL_X86_MODEL_DIR)/main.sail

CC?=gcc

all: x86_emulator

.PHONY: all clean interactive

x86_emulator.c: $(PRELUDE_SAILS) $(MAIN_SAIL)
	$(SAIL) -c -memo_z3 $(SAIL_FLAGS) $(PRELUDE_SAILS) $(MAIN_SAIL) > x86_emulator.c.temp
	mv x86_emulator.c.temp x86_emulator.c

x86_emulator: x86_emulator.c
	$(CC) -O2 -DHAVE_SETCONFIG x86_emulator.c $(SAIL_DIR)/lib/*.c -lgmp -lz -I $(SAIL_DIR)/lib/ -o x86_emulator

interactive:
	$(SAIL) -i -memo_z3 $(SAIL_FLAGS) $(PRELUDE_SAILS) $(MAIN_SAIL)

clean:
	rm -f x86_emulator.c x86_emulator
