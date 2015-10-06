#!/bin/bash

exec < /dev/tty

BASE=$HOME/.atom/scripts
source $BASE/lib.sh

if which colordiff > /dev/null; then
  DIFF=colordiff
else
  DIFF=diff
fi

FILE="packages.txt"
FULL="$HOME/.atom/$FILE"

OLD=`mktemp packages.OLD.txt.XXXXXX`
NEW=`mktemp packages.NEW.txt.XXXXXX`

trap "rm $OLD; rm $NEW" EXIT

git show :$FILE > $OLD
apm list --installed --bare | sed 's/@.*//' > $NEW

if ! $DIFF -u $OLD $NEW; then
  if yes_no 'update?'; then
    cp $NEW $FULL
    git add $FULL
  else
    exit 1
  fi
fi
