#!/bin/sh

XPRV=$(bip32gen -i entropy -f vector1.bin -o xprv -F - m/0h)
echo "Extended private key for 'm/0h' is $XPRV"
echo $XPRV >xprv.asc

XPUB=$(bip32gen -i entropy -f vector1.bin -o xpub -F - m/0h)
echo "Extended public  key for 'm/0h' is $XPUB"
echo $XPUB >xpub.asc

ADDR=$(bip32gen -i entropy -f vector1.bin -o addr m/0h/1)
echo "Using entropy for 'm',    address of 'm/0h/1' is $ADDR"

ADDR2=$(bip32gen -i xprv -f xprv.asc -o addr 1)
echo "Using xprv    for 'm/0h', address of 'm/0h/1' is $ADDR2"

ADDR3=$(bip32gen -i xpub -f xpub.asc -o addr 1)
echo "Using xpub    for 'M/0h', address of 'M/0h/1' is $ADDR3"
