#!/bin/bash

# Copy "original.sfc" to "patched.sfc"
cp original.sfc patched.sfc

# Run the command "./asar patch.asm patched.sfc"
./asar patch.asm patched.sfc
