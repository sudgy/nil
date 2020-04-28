#!/bin/bash

./sasm sasm.asm sasm_new
rm sasm
mv sasm_new sasm
