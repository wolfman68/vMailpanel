#!/bin/bash
PERCENT=$1
cat << EOF | /usr/local/libexec/dovecot/deliver -d $USER
From: postmaster@example.tld
Subject: quota warning

Your mailbox is now $PERCENT% full.
EOF
