# Ravenports
Universal package builder system

## Objective

To develop the next generation software collection builder and packager
that is also truly cross-platform.  Think FreeBSD ports with several new
cutting edge features and enhancements, but with equal support to Linux,
Solaris(like), MacOS, and all BSD platforms.

It is not a reinvention of pkgsrc.  The approach is new and not based
on make.

## Ravenports Triad

There will be three main components of Ravenports.

  1. **Source ports:**
This component, known as "ravensource" is not seen or utilized by
regular users.  It resembles
the ports tree seen in FreeBSD and pkgsrc, but only at the individual
port directory level.  It is not arranged in categories.  The contents
of each port directory is used to generate a port buildsheet.

  2. **Conspiracy:**
The conspiracy repository contains all the buildsheets, separated into
256 bucket directories.  These single files are the complete recipe for
building the software for which they were created.  These buildsheets
are not meant to be viewed directly, as their information can be queried
by the ravenadm tool.  The conspiracy buildsheets are "compiled" from
ravensource and getting the latest ports is accomplished by updating the
repository.  This README is contained within the Conspiracy repository.

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

## Updates

Unlike other ports systems, the updates will come all at once at
regular intervals (e.g. weekly or biweekly).  That allows for the
entire tree to be integrity checked before publishing.

The goal is to automate port updates for specific types of ports
like all software in CPAN.  These buildsheets can be generated
by querying CPAN.  Similar approaches can be done for rubygems,
haskell, python, Go, etc.

Volunteers will still be needed for many complex ports, but
similarities with FreeBSD and pkgsrc will ease these tasks.

## Miscellaneous

This is just an initial set of notes.  As progress is made, these notes
will be updated accordingly.
