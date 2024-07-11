# Ravenports
Universal package builder system

## Objective

To develop the next generation software collection builder and packager
that is also truly cross-platform.  Think FreeBSD ports with several new
cutting edge features and enhancements, but with equal support to Linux,
Solaris(like), and all BSD platforms.  MacOS was previously supported, but
it proved difficult to maintain due to the different file format (Mach-o vs 
ELF) and extrememly large system root.

It is not a reinvention of pkgsrc.  The approach is new and not based
on the 'make' program.

## Ravenports Triad

There are three main components of Ravenports.

  1. **Source ports:**
This component, known as "ravensource" is not seen or utilized by
regular users.  It resembles
the ports tree seen in FreeBSD and pkgsrc, but only at the individual
port directory level.  It is not arranged in categories.  The contents
of each port directory is used to generate a port buildsheet.

Custom overlays are supported, known as **unkindness** directories.
These overlays either lock in standard parts (should the locations match
the source ports, or add custom ports.  The two typical uses for this
directory is related port development and the ability to add proprietary
software to a custom repository.

  2. **Conspiracy:**
The conspiracy repository contains all the buildsheets, separated into
256 bucket directories.  These single files are the complete recipe for
building the software for which they were created.  These buildsheets
are not meant to be viewed directly, as their information can be queried
by the ravenadm tool.  The conspiracy buildsheets are "compiled" from
ravensource and possible an unkindness directory and getting the latest
versions is accomplished by updating the repository.
This README is contained within the Conspiracy repository.

  3. **Raven administration tool:**
The administration tool for Ravenports is "ravenadm".  It can query the
ports for many types of information like a database.  It can build
packages in parallel (think synth interface).  It controls the build
environment such that it is the same across users, even if those
users are on different operating systems.  Raven also plays a part
in the development of ports and features inbuilt lint, sanity checks
and compile checks.  If somebody develops a buildsheet that passes
all checks and builds, it likely can be incorporated in the source
tree as submitted, especially if the submission process includes
automated testing on all supported platforms.

## Make has really been eliminated?

Actually, not really.  Make is pretty good at the actual building of the
port.  A significant chunk of FreeBSD's build logic will be retained
(although improved upon).  Raven will generate a makefile dynamically
depending on options and variants requested for the purpose of
building and packaging the software.  The logic will be straight-forward
without recursion or shell forking.  Keeping this logic at
${RAVENBASE}/share/mk will ensure adaptability.

The options handling and other complex logic that affect package
dependencies will be done by the ravenadm internally.  This will
enable speedups by magnitudes as compared to other ports systems.

## Official Website

Please visit
[http://www.ravenports.com](http://www.ravenports.com)
for additional and current information.

## License

The contents of this repository are available under the
conditions defined by the Internet Systems Consortium (ISC) license:

---

```
Copyright (c) 2017-2024, The Ravenports Project.

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

## Ravenports fingerprint

All Ravenports repositories are signed by the following fingerprint:

```
function: "blake3"
fingerprint: "adcb0aeb115a8ca66e4cce5ad1d500ad235cc2eab0a14fdb8bb74f786b896c97"
```

The file containing is defined by the repository configuration.  The downloader
script creates it here:

    /raven/etc/rvn/fingerprints/ravenports/trusted/Alpha-fingerprint

The repository configuration created by the downloader script is this:

   /raven/etc/rvn/repos/raven.conf
```
Raven: {
    url            : http://www.ravenports.com/repository/${ABI},
    enabled        : true
    master         : true
    signature_type : fingerprints
    fingerprints   : ${LOCAL_FPRINTDIR}
    priority       : 10
}
```

## Ravenports public key

All Ravenports repositories are signed by the following key.

```
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4rhIOkp+aJS04AOz/V0S
gKOg7Ol/rUTUeHUwzbE45vvGq+M7s00MKDhzdU6QBPnhRLaPdRf8jJNCcNIEIjQ4
fON43BNJfJX1q5T1jnT4Dd+pyyejPv3gOQdDARYt4risfeey3BBYQMuOghGoCNDt
DYPsWaBUPHUR+Um96U0CYHl3ZeAbovq466Wn3OuYX3gvg4QPaMPKmx1fgI3V9bDA
KuOBD5JEVzhJgtzv33e7C0murs4WWJpRv3eSinZsUKoFbt4F4To+YrIXnOQPrNdr
u25Z5hSBdNT5gM43JKWWqM57Zi60Poj5nG6p+GxGePWrraOQY68mgDEScTrJLIXj
UwIDAQAB
-----END PUBLIC KEY-----
```

The downloader skip no longer installs this file, but it still works.
An example of use is to save the contents to
/raven/etc/rvn/keys/ravenports.key.  The ravensw repository
configuration file might look like this:

```
> cat /raven/etc/rvn/repos/raven.conf
Raven: {
    url            : http://www.ravenports.com/repository/${ABI},
    pubkey         : /raven/etc/rvn/keys/ravenports.key,
    signature_type : PUBKEY,
    enabled        : yes
}
```

## Bootstrapping Ravenports

These are operating system-specific examples on how to install Ravenports on a new
system using basic commands.

### FreeBSD / DragonFly / MidnightBSD

    root> fetch http://www.ravenports.com/repository/ravenports-downloader.sh -o - | /bin/sh

### NetBSD

    root> ftp -o - http://www.ravenports.com/repository/ravenports-downloader.sh | /bin/sh

### Solaris 10

    root> /usr/sfw/bin/wget http://www.ravenports.com/repository/ravenports-downloader.sh -O - | /usr/bin/bash

### Linux

    user> curl http://www.ravenports.com/repository/ravenports-downloader.sh --silent | sudo /bin/bash

==  or  ==

    user> wget http://www.ravenports.com/repository/ravenports-downloader.sh --quiet -O - | sudo /bin/bash

