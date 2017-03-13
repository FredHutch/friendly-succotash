# `sti_crc_method_comparison` Data Sharing Host

Configure a system for sharing microbiome data across multiple institutions.

## Goals

## Requirements:

 - use common tools for access, both upload and download
 - available from institutions external to the Center without
   requiring HutchNet IDs
 - Logging and auditing?

# Implementation Options

These are the two options that appear most viable at the moment.  Both are
viable but each present different challenges for adoption.  Likely the biggest
single differentiator between these two is the need for access via
desktop GUI environments provided in Windows and OSX.

## sftp

Using sftp is attractive as it uses a commonly available and robust software
suite (ssh) using common metaphors for accessing data (i.e. the FTP command
set).

There is a challenge in implementing this at the Hutch as providing sftp
implies shell access which is not something that is viewed positively by the
engineering and security teams.  Their preference is that remote login access
be limited to VPN or a single ssh server.

This can be addressed by removing login capabilities from the ssh server- this
would be done by restricting the enabled ssh subsystems to the sftp server
only.  However, this presents a management challenge as administrators and
managers require shell access via ssh for thier activities.

While it is possible to limit subsystems via users and/or groups, it is likely
simplest to run two SSH servers- one providing the usual shell access required
by admins and application managers and another server restricted to provide
/only/ sftp services.

One option here would be running a second SSH server on an alternate port for
SFTP access.  This is somewhat undesirable as application users must change the
behavior of their clients in unaccustomed ways.

Another option would be to assign two IP addresses to the host providing the
service and have one SSH server provide (only) sftp services via the first and
another SSH server providing shell services on the second.  This allows those
accessing services on the host to use the default SSH client configuration.
Alternate host names are required, but careful name selection can easily
mitigate that challenge.

## WebDAV

Providing webdav services uses the familiar HTTP protocol which is rather
better understood by the engineering and security communities for external
access.  In this configuration, the host would have an HTTP server (likely
Apache2) with the required module enabled to allow file upload and download via
the DAV protocol.

This has one advantage over sftp in that the WebDAV protocol enables native
client access via the GUI tools found in Windows (Windows Exporer), OSX
(Finder), and Linux (Nautilus et alia).  Users need only mount the remote host
using these tools and the files will then be available via familiar graphical
interfaces.

However, on the command line, use is less certain.  Tools for command line
access in Windows and OSX have not been researched.  The primary tool for Linux
hosts would be cadaver which is currently not installed on the SciComp hosts.
While adding this to the SciComp environment is an easily completed change,
adding required tools to hosts at collaborating institutions may not be as
straight forward.  Though these are "user-land" tools which are typically low
impact and easily added to an institution's toolchain.

