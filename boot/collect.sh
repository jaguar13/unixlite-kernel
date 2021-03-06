#!/bin/sh

[ $# -eq 0 ] && { echo "Usage: collect.sh executablefile"; exit 1; }
rm -f collect.log
rm -f collect.h
exec 3>&1 >collect.h

echo "/* this file is generated by collect.sh */"
echo "unsigned long ctorlist[] = {"
echo "0x19790106UL,"

nm --demangle --radix=x $1 > collect.nm

cat collect.nm | grep __ctor1979 | grep -v __func__ | grep -v "global constructors keyed to" | \
sort -k 3,3 | tee collect.log |
awk '{ print "0x"$1"UL,"; }'
echo "0x19790106UL,"
echo "};"

cat collect.nm | grep __ctorlist0106 | tee -a collect.log |
awk '{ print "#define CTORLISTVADDR 0x"$1"UL"; }'

exec 1>&3
set -e
g++ -O -o collect collect.cc
./collect $1
