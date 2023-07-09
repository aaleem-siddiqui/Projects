#/bin/bash

sed  -i '
s/^ *//
s/ *$//
/^$/d
' "$@"
