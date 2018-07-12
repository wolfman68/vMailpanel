#!/bin/bash
#
# Use this script to:
# 
# Delete mailbox(es) marked for deletion from:
#   - the ldap directory
#   - the physical mailbox(es)
# 
# Delete domain(s) marked for deletion from:
#   - the ldap directory
#   - the physical domain(s) directory
# 

# Replace example tld with your actual domain name
LDAPURI="ldap://localhost:389/"
BINDDN="cn=admin,dc=example,dc=tld"
BINDPW="password"
LDAP_BASE="o=hosting,dc=example,dc=tld"
OUTPUT="/tmp/list"

touch $OUTPUT
# find mail to delete
ldapsearch -H $LDAPURI -D $BINDDN -w $BINDPW -b $LDAP_BASE -x -LLL "(&(objectClass=VirtualMailAccount)(delete=TRUE))" mailbox > /tmp/mb$$
# create file for awk
sed \
-e ':a' \
-e '$!N;s/\n //;ta' \
-e 'P;D' \
/tmp/mb$$ > /tmp/mb$$.1

cat /tmp/mb$$.1 | awk '{
			if ($1 == "dn:")
			{ print "ldapdelete -H \"'$LDAPURI'\" -D \"'$BINDDN'\" -w \"'$BINDPW'\" -x \""$2"\"" > "'$OUTPUT'" }
			if ($1 == "mailbox:")
			{ print "rm -rf " $2 > "'$OUTPUT'" } 
			}'

# find domain to delete
ldapsearch -H $LDAPURI -D $BINDDN -w $BINDPW -b $LDAP_BASE -x -LLL "(&(objectClass=VirtualDomain)(delete=TRUE))" vd > /tmp/vd$$
# create file for awk
sed \
-e ':a' \
-e '$!N;s/\n //;ta' \
-e 'P;D' \
/tmp/vd$$ > /tmp/vd$$.1

cat delete/vd$$ | awk '{
			if ($1 == "dn:")
			{ print "ldapdelete -H \"'$LDAPURI'\" -D \"'$BINDDN'\" -w \"'$BINDPW'\" -x -r \""$2"\"" > "'$OUTPUT'" }
			if ($1 == "vd:")
			{ print "rm -rf " $2 > "'$OUTPUT'" } 
			}'

# execute and delete temporary files
chmod 700 $OUTPUT
$OUTPUT
rm -rf delete/mb* delete/vd* $OUTPUT