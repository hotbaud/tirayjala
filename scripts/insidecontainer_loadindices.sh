#!/usr/bin/bash
# 
# Author:  Anne Marie Merritt
#          anne.merritt@hpe.com
#
#
# This script is run from the tirayjala container.  It loads indices from dumped
# .json files into Elasticsearch. It also renames the indices to include the name
# of the file, and appends a random ID for the load so it can be differentiated
# more easily when looking at loaded indices.
#
# It gathers auth and IP info from passed-in environment variables. The script
# can then access those values to issue curl commands and elasticdump commands
# to format queries and load the specified files into ElasticSearch as indices.
#
# It is intended to run from INSIDE the tirarmucho:x container as that's where
# the working program 'elasticdump' is located.
#
# The container's default executable is /usr/bin/bash, so it will pass in the
# name of this script as '-c scriptname.sh' to execute it.
# otherwise the container will drop into a bash shell and one can execute the
# elasticdump command manually.
#
# We expect the output to be a mountpoint accessible EXTERNALLY in the passed-
# in OUTPUT directory.  Otherwise the container can't load indices if the data
# is not accessible from inside the container.
#

# Passed-in environment variables.
ipaddr=$IPADDR

port=$PORT

# Single input auth string is in the format of username:password
# e.g. mooby:9e3924b0-a77b-4848-ba46-9a4931e1t537
auth=$AUTH

# We only want the .json files since they contain the dumped records.
for entry in $OUTPUT/*.json
do
    # Identify the indexname to load from the filename prefix
    indexname="$(basename $entry .json)"

    # Input the file records into elasticsearch using the indexname as target
    # index

    NODE_TLS_REJECT_UNAUTHORIZED=0 /node_modules/elasticdump/bin/elasticdump \
    --bulk=true  \
    --input=$entry \
    --output=https://$auth@$ipaddr:$PORT/$indexname

done
