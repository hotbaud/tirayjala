#!/usr/bin/bash
#
# Author:  Anne Marie Merritt
#          anne.marie.merritt@gmail.com
#
#
# This script is run from inside the tirayjala container to identify indices,
# then dump them to files in the specified directory OUTPUT using elasticdump.
# All args are passed through as environment variables defined in all caps as
# below.

# Passed-in environment variables from the container invocation commandline

ipaddr=$IPADDR

port=$PORT

# Single input auth string is in the format of username:password
# e.g. mooby:9e3924b0-a77b-4848-ba46-9a4931e1t537

auth=$AUTH

# dumpprefix is a grep-able string to search for when dumping.

dumpprefix=$DUMPPREFIX

# randomid allows us to group all the dumped indices together later so we
# know they came from the same host download batch. This way when we load
# them later we can distinguish in a large directory between indices from
# various sources, especially if we want to prune out certain uploads all
# from the same previous batch later on.

randomid=$INDEXPREFIX

# Locate the indices to dump
indexlist=($(curl --insecure  -u $auth --silent https://$ipaddr:9210/_cat/indices -s | grep $dumpprefix | awk '{ print $3 }' | uniq | sort ))

for i in "${indexlist[@]}"
do : 
    # Dump the indices with the filename specified as this pattern:
    # Source IP - Random String - original indexname - .json

    NODE_TLS_REJECT_UNAUTHORIZED=0 /node_modules/elasticdump/bin/elasticdump  \
    --input https://$auth@$ipaddr:9210/$i  \
    --output $OUTPUT/$ipaddr-$randomid-$i.json \
    --type=data  \
    --headers='{"Content-Type": "application/json"}'

done

