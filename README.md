Introduction
============

The bip32utils library is a pure Python implementation of Bitcoin
hierarchical deterministic wallet ("HD Wallet") ECDSA key generation
as specified in BIP0032 (Bitcoin Improvement Proposal #0032).

Deterministic ECDSA key generation allows creating a sequence of
Bitcoin private and public ECDSA keys from an initial seed and a
hierarchical set of indices.  A number of benefits follow:

* An entire wallet can be backed up once by storing the wallet seed or
  master extended private key, and all future addresses in the wallet
  can be restored from it.

* The creation of public and private ECDSA keys may be separated from
  each other.  That is, it is possible to create only the public ECDSA
  key half (and receiving address) of an ECDSA key pair, without the
  ability to create the private half.  Thus, one can create receiving
  addresses on a public facing system that if compromised would not
  give the attacker the ability to spend bitcoin received at those
  addresses. A separate, offline machine can generate the
  corresponding private ECDSA keys and sign transactions.

* Public and private ECDSA keys may be created in a hierarchy, and
  control over or visibility of portions of the hierarchy may be
  delegated to third parties.  This has uses for auditing, for
  separating ECDSA key sequences into different logical groups or
  accounts, and for giving 3rd parties the ability to create spending
  transactions without first getting a receiving address in advance.

BIP0032 is in draft stage, is subject to change, and is documented at:

https://github.com/sipa/bips/blob/bip32update/bip-0032.mediawiki

Python bip32gen Script
======================

This library installs the bip32gen script into $PREFIX/bin, which
wraps a command-line interface around the BIP32Key class functionality
described in a later section:

## Script Parameters
```
$ bip32gen -h
usage: bip32gen [-h] [-x] [-X] -i {entropy,xprv,xpub} [-n AMOUNT]
                [-f FROM_FILE] [-F TO_FILE] -o OUTPUT_TYPE [-v] [-d]
                chain [chain ...]

Create hierarchical deterministic wallet addresses

positional arguments:
  chain                 list of hierarchical key specifiers

optional arguments:
  -h, --help            show this help message and exit
  -x, --input-hex       input supplied as hex-encoded ascii
  -X, --output-hex      output generated (where applicable) as hex-encoded
                        ascii
  -i {entropy,xprv,xpub}, --input-type {entropy,xprv,xpub}
                        source material to generate key
  -n AMOUNT, --amount AMOUNT
                        amount of entropy to to read (bits), None for all of
                        input
  -f FROM_FILE, --from-file FROM_FILE
                        filespec of input data, '-' for stdin
  -F TO_FILE, --to-file TO_FILE
                        filespec of output data, '-' for stdout
  -o OUTPUT_TYPE, --output-type OUTPUT_TYPE
                        output types, comma separated, from
                        addr|privkey|wif|pubkey|xprv|xpub|chain
  -v, --verbose         verbose output, not for machine parsing
  -d, --debug           enable debugging output
```

The user specifies the type of input data (currently from entropy, a
serialized extended private key, or serialized extended public key),
the filespec to get that input data from (or stdin), the set of output
fields to generate, whether to hex encode those outputs when
applicable, and a list of key specifier(s).  A key specifier will
either start with 'm' or 'M' when using entropy as an input source;
otherwise, when importing from a serialized extended key, the key
specifier(s) start with the first hierarchical child index to create.

For example, to generate a new master wallet key from entropy and
output the serialized extended private key for that to stdout:

```
$ bip32gen -i entropy -f /dev/random -n 128 -o xprv -F - m
xprv9s21ZrQH143K3eqKCaAW9CvAiKR8SHdikQnR8dVs8eBxC9fYtW69k1gLRTG5o2Rn3gtz651yFGzxRFjtfjLQHmh4kT7YF3vZcZgGdfX7ZVS
```

To generate the BIP0032 test vector #1, using entropy
supplied as a hex-encoded string on stdin, and output the private
ECDSA key, wallet import format for that private ECDSA key, public
ECDSA key, address, and serialized extended private and public keys,
hex encoding where applicable, and writing to stdout:

```
$echo 000102030405060708090A0B0C0D0E0F | \
    bip32gen -v \
    -i entropy -f - -x \
    -o privkey,wif,pubkey,addr,xprv,xpub -F - -X \
    m \
    m/0h \
    m/0h/1 \
    m/0h/1/2h \
    m/0h/1/2h/2 \
    m/0h/1/2h/2/1000000000
```

(output not listed)


Python bip32utils Library
=========================

## The BIP32Key Class

The bip32utils python library currently has a single class, BIP32Key,
which encapsulates a single node in a BIP0032 wallet hierarchy. A
terminology distinction is made between an ECDSA private and public
key pair and a full BIP32Key, which internally holds an ECDSA key pair
and other data.

A BIP32Key may act like a standard Bitcoin keypair, providing the
means to sign transactions with its internal ECDSA private key or to
generate a receiving address with its internal ECDSA public key. In
addition, a BIP32Key can act as the parent node for a set of indexed
children and thus form a tree of BIP32Key sequences.

A BIP32Key may also be deemed a private or public BIP32Key, depending
upon whether the secret half of the internal ECDSA key pair is
present.  Private BIP32Keys are able to generate either public or
private child BIP32Keys, while public BIP32Keys can only generate
public children.

In other words, a private BIP32Key internally stores an ECDSA private
key, an ECDSA public key, and some additional pseudorandom bits named
the _chain code_.  Public BIP32Keys are only different in that the
secret half of the ECDSA key pair does not exist; only the public half
does.

## Creating a BIP32Key

A BIP32Key may come into existence in one of four ways:

* Using the BIP32Key.fromEntropy(entropy, public=False) method, one
  may provide a string of at least 32 bytes (128 bits) to construct a
  new master BIP32Key for an entire tree. From this initial >= 128
  bits of entropy a new ECDSA private key, ECDSA public key, and
  pseudorandom chain code are derived that preserves the 128 bit
  security parameter as described in BIP0032. This is termed a private
  BIP32Key, and may be used to derive child BIP32Keys that are either
  private or public.

  If the public parameter is set to True, then the internal ECDSA
  private key is discarded, the resulting BIP32Key is known as a
  public BIP32Key, and may only be used to generate further public
  BIP32Keys.

* Using the BIP32Key.fromExtendedKey(xkey, public=False) static
  method, one may provide a 78-byte serialized string that is
  formatted as an Extended Private Key, as documented in BIP0032. From
  this, the ECDSA private key, ECDSA public key, and chain code are
  extracted.

  If the public parameter is set to True, then the internal ECDSA
  private key is discarded, converting the resulting BIP32Key into a
  public BIP32Key, and may only be used to generate further public
  BIP32Keys.

* Using the BIP32Key.fromExtendedKey(xkey) static method, one may
  provide a 78-byte serialized string that is formatted as an Extended
  Public Key, as documented in BIP0032. From this, the ECDSA public
  key and chain code are extracted, resulting in a public BIP32Key
  that may only be used to generate further public BIP32Keys.

* Finally, using an instance of a BIP32Key resulting from any of the
  three methods above, one may call the member function ChildKey(i) to
  create a child BIP32Key one level lower in the hierarchy, at integer
  index 'i'. If the starting BIP32Key is a private one, then the
  resulting child BIP32Key will also be a private one, using the
  CKDpriv derivation formula in BIP0032.

  Likewise, if the starting BIP32Key is a public one (i.e., does not
  contain an internal ECDSA private key half), then the child BIP32Key
  will also be a public one, derived using the CKDpub algorithm in
  BIP0032.

At any time, a private BIP32Key may be turned into a public one by
calling the instance member function SetPublic(), which discards the
internal private ECDSA key half and sets an internal flag.

When creating a child BIP32Key from an existing private BIP32Key, one
may also select from an alternate set of child keys, called _hardened_
keys, by adding the constant BIP32_HARDEN to the integer index.  A
hardened child BIP32Key avoids a known issue with non-hardened child
keys where a compromise of one child key may result in a compromise of
all child keys in the same sequence.
