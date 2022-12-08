# CHERI x86-64 Sail model
This repository contains an implementation of the CHERI extensions
for the 64-bit x86 architecture in [sail](https://github.com/rems-project/sail). It is designed to be used with the [sail-x86](https://github.com/rems-project/sail-x86-from-acl2)
model, which is included as a submodule. To checkout / build (assuming you have installed sail):
```
git clone --recurse-submodules https://github.com/CTSRD-CHERI/sail-cheri-x86
cd sail-cheri-x86
```
You can build a C emulator:
```
make x86_emulator
```

## Funding

This software was developed by SRI International, the University of
Cambridge Computer Laboratory (Department of Computer Science and
Technology), and Capabilities Limited under Defense Advanced Research
Projects Agency (DARPA) Contract No. HR001122C0110 ("ETC").
