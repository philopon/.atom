#!/bin/bash

yes_no(){
    read -p "$1 [y/N]:" answer
    head=${answer:0:1}
    if [[ "$head" == "Y" || "$head" == "y" ]]; then
        return 0
    elif [[ "$head" == "N" || "$head" == "n" || "$head" == "" ]]; then
        return 1
    else
        yes_no "$1"
    fi
}


