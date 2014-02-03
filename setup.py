#!/usr/bin/env python

from setuptools import setup

setup(
    name = 'bip32utils',
    version = '0.1',
    author = 'Johnathan Corgan, Corgan Labs',
    author_email = 'johnathan@corganlabs.com',
    url = 'http://github.com/jmcorgan/bip32utils',
    description = 'Utilites for generating and using Bitcoin hierarchical deterministic wallets (BIP0032).',
    license = 'MIT',
    requires = ['ecsda'],
    packages = ['bip32utils'],
    scripts = ['bin/bip32gen']
)
