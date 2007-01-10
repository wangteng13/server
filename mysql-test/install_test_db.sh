#!/bin/sh
# Copyright (C) 1997-2006 MySQL AB
# For a more info consult the file COPYRIGHT distributed with this file

# This scripts creates the privilege tables db, host, user, tables_priv,
# columns_priv in the mysql database, as well as the func table.

if [ x$1 = x"--bin" ]; then
  shift 1
  BINARY_DIST=1

  bindir=../bin
  scriptdir=../bin
  libexecdir=../libexec

  # Check if it's a binary distribution or a 'make install'
  if test -x ../libexec/mysqld
  then
    execdir=../libexec
  elif test -x ../../sbin/mysqld  # RPM installation
  then
    execdir=../../sbin
    bindir=../../bin
    scriptdir=../../bin
    libexecdir=../../libexec
  else
    execdir=../bin
  fi
  fix_bin=mysql-test
else
  execdir=../sql
  bindir=../client
  fix_bin=.
  scriptdir=../scripts
  libexecdir=../libexec
fi

vardir=var
logdir=$vardir/log
if [ x$1 = x"-slave" ] 
then
 shift 1
 data=var/slave-data
 ldata=$fix_bin/var/slave-data
else
 if [ x$1 = x"-1" ] 
 then
   data=var/master-data1
 else
   data=var/master-data
 fi
 ldata=$fix_bin/$data
fi

mdata=$data/mysql
EXTRA_ARG=""

mysqld=
if test -x $execdir/mysqld
then
  mysqld=$execdir/mysqld
else
  if test ! -x $libexecdir/mysqld
  then
    echo "mysqld is missing - looked in $execdir and in $libexecdir"
    exit 1
  else
    mysqld=$libexecdir/mysqld
  fi
fi

# On IRIX hostname is in /usr/bsd so add this to the path
PATH=$PATH:/usr/bsd
hostname=`hostname`		# Install this too in the user table
hostname="$hostname%"		# Fix if not fully qualified hostname


#create the directories
[ -d $vardir ] || mkdir $vardir
[ -d $logdir ] || mkdir $logdir

# Create database directories mysql & test
if [ -d $data ] ; then rm -rf $data ; fi
mkdir $data $data/mysql $data/test 

#for error messages
if [ x$BINARY_DIST = x1 ] ; then
basedir=..
else
basedir=.
EXTRA_ARG="--language=../sql/share/english/ --character-sets-dir=../sql/share/charsets/"
fi

mysqld_boot="${MYSQLD_BOOTSTRAP-$mysqld}"

mysqld_boot="$mysqld_boot --no-defaults --bootstrap --skip-grant-tables \
    --basedir=$basedir --datadir=$ldata \
    --skip-innodb --skip-ndbcluster --skip-bdb \
    $EXTRA_ARG"
echo "running $mysqld_boot"

if $scriptdir/mysql_create_system_tables test $mdata $hostname | $mysqld_boot
then
    exit 0
else
    echo "Error executing mysqld --bootstrap"
    exit 1
fi
