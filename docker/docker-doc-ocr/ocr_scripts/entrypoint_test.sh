#!/usr/bin/env bash

echo "Total num. of input args.: $#"
echo ""
echo "Args. list:"
IDX_VARS=1
for VAR in "$@"; do
    echo "$IDX_VARS: $VAR"
    IDX_VARS = $(($IDX_VARS+1))
done