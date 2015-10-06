#!/usr/bin/env bash

BASE=$HOME/.atom/scripts
source $BASE/lib.sh

################################################################################
## gist
################################################################################

gist(){
    BASE="https://api.github.com"
    USER=`git config --get remote.origin.url | awk -F"[:/]" '{print $2}'`
    HOST=`hostname`

    read -s -p "$USER's GitHub password:" PASS
    echo >&2
    read -p "$USER's OTP code:" OTP

    TMP=`mktemp /tmp/atom-install.XXXXXX`
    trap "rm $TMP" EXIT

    COMMON=("-s" "-S" "-w%{http_code}" "-o$TMP" "-u$USER:$PASS" "-HX-GitHub-OTP:$OTP")
    NOTE="atom/gist on $HOST"

    RESULT=`curl ${COMMON[@]} $BASE/authorizations`
    if [[ $RESULT -gt 299 ]]; then
        cat $TMP
        return 1
    fi

    CURRENT_ID=`jq -e ".[] | select(.note == \"$NOTE\") | .id" $TMP`
    if [[ "$?" -eq "0" ]]; then
        if ! yes_no "$NOTE token exists. delete?"; then
            echo aborted
            return 1
        fi

        RESULT=`curl -XDELETE ${COMMON[@]} $BASE/authorizations/$CURRENT_ID`

        if [[ $RESULT -gt 299 ]]; then
            cat $TMP
            return 1
        fi
    fi

    CREATE=$(cat <<EOF
    {
        "scopes": ["gist"],
        "note": "$NOTE"
    }
EOF)

    RESULT=`curl -XPOST -d "$CREATE" ${COMMON[@]} $BASE/authorizations`
    if [[ $RESULT -gt 299 ]]; then
        cat $TMP
        return 1
    fi
    jq -r '.token' $TMP > gist.token
    chmod 600 gist.token
}

if yes_no "setup gist?"; then
    gist
fi

################################################################################
## packages
################################################################################

if yes_no "install packages?"; then
    apm install --packages-file ~/.atom/packages.txt
fi
