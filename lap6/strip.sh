#!/bin/sh

cut -c11- "$1" | grep -v '^[ ]*$' | sed 's/^    //'
