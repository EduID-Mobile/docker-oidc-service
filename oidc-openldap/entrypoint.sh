#!/bin/sh

ulimit -n 8000
/usr/sbin/slapd -d stats -h ldap:///
