# Data Exchange Host

## Purpose

This cookbook configures a host for uploading non-confidential data from remote
institutions for analysis at the Hutch.

## Constraints

 - The data is non-confidential (non-human control specimens), but remote
   agents should not be able to see the uploads from other agents to ensure
   blinding between remote sites.
 - Accounts will be managed locally

## Implementation

The host's default (OS-configured) SSH server will be restricted to the host's
default interface.  A second IP interface (by default configured as a
subinterface on the default network device) is used for SFTP.  A second OpenSSH
daemon is configured to listen on that second IP address- this OpenSSH daemon
has been configured such that the only available subsystem is SFTP, thus no
shell access via this interface.  Firewall rules thus only allow remote access
to this second IP address on port 22.

Further customizations are used to configure SFTP- the `chroot` directory is
configured to use the incoming connection's username, appending it to the root
upload directory.  This directory needs to be configured as owned by root, so a subdirectory under this (called `upload`) is created with permissions such that the connecting account can read and write inside this directory.

- `<data directory>`: the top-level directory for uploading data. Owned by root.
- `<data directory>/<username>`: the chroot directory for the upload account.
  Owned by root, no write access for others
- `<data directory>/<username>/uploads`: the chroot directory for the upload
  account.  Owned by the upload account, mode 0755

As this data needs to be uploaded to networked storage, a subdirectory is
mounted via SMB to the location indicated by `<data directory>`.  This mount
will use a service account such that the uploaded data on the server will have
permissions allowing Hutch staff to manage this data.

