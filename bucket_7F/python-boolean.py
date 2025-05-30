# Buildsheet autogenerated by ravenadm tool -- Do not edit.

NAMEBASE=		python-boolean.py
VERSION=		5.0
KEYWORDS=		python
VARIANTS=		v12 v13
SDESC[v12]=		Boolean expression and algebra library (3.12)
SDESC[v13]=		Boolean expression and algebra library (3.13)
HOMEPAGE=		https://github.com/bastikr/boolean.py
CONTACT=		Python_Automaton[python@ironwolf.systems]

DOWNLOAD_GROUPS=	main
SITES[main]=		PYPIWHL/e5/ca/78d423b324b8d77900030fa59c4aa9054261ef0925631cd2501dd015b7b7
DISTFILE[1]=		boolean_py-5.0-py3-none-any.whl:main
DIST_SUBDIR=		python-src
DF_INDEX=		1
SPKGS[v12]=		single
SPKGS[v13]=		single

OPTIONS_AVAILABLE=	PY312 PY313
OPTIONS_STANDARD=	none
VOPTS[v12]=		PY312=ON PY313=OFF
VOPTS[v13]=		PY312=OFF PY313=ON

DISTNAME=		boolean_py-5.0.dist-info

GENERATED=		yes

[PY312].USES_ON=			python:v12,wheel

[PY313].USES_ON=			python:v13,wheel

[FILE:602:descriptions/desc.single]


This library helps you deal with boolean expressions and algebra with
variables
and the boolean functions AND, OR, NOT.

You can parse expressions from strings and simplify and compare
expressions.
You can also easily create your custom algreba and mini DSL and create
custom
tokenizers to handle custom expressions.

For extensive documentation look either into the docs directory or view it
online, at
https://booleanpy.readthedocs.org/en/latest/

https://github.com/bastikr/boolean.py

Copyright (c) 2009-2020 Sebastian Kraemer, basti.kr@gmail.com and others
SPDX-License-Identifier: BSD-2-Clause


[FILE:121:distinfo]
ef28a70bd43115208441b53a045d1549e2f0ec6e3d08a9d142cbc41c1938e8d9        26577 python-src/boolean_py-5.0-py3-none-any.whl

