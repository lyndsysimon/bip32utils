#!/bin/sh

echo Generating receiving addresses through both private and public chains using entropy
bip32gen -v \
    -i entropy -f vector1.bin \
    -o addr -F - -X \
    m/0/1/2/3 M/0/1/2/3
