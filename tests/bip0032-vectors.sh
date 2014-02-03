#!/bin/sh

# BIP0032 Test vector #1

echo Generating BIP0032 test vector 1:
echo 000102030405060708090A0B0C0D0E0F | \
    bip32gen -v \
    -i entropy -f - -x \
    -o privkey,wif,pubkey,addr,xprv,xpub -F - -X \
    m \
    m/0h \
    m/0h/1 \
    m/0h/1/2h \
    m/0h/1/2h/2 \
    m/0h/1/2h/2/1000000000

# BIP0032 Test vector #2

echo Generating BIP0032 test vector 2:
echo fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542 | \
    bip32gen -v \
    -i entropy -f - -x -n 512 \
    -o privkey,wif,pubkey,addr,xprv,xpub -F - -X \
    m \
    m/0 \
    m/0/2147483647h \
    m/0/2147483647h/1 \
    m/0/2147483647h/1/2147483646h \
    m/0/2147483647h/1/2147483646h/2
