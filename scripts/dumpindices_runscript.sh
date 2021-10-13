#!/usr/bin/bash
#
# Author:  Anne Marie Merritt
#          anne.marie.merritt@gmail.com
#
# This script dumps indices as specified by container's internal script 'dumpindices.sh".
# It gathers auth and IP info not available from inside the container, and passes them
# through as environment variables.  The script can then access those values to issue curl
# commands and elasticdump commands to format queries and dump the specified indices.
#
# In this case, the default dump is in service of falco indices, but a filter string can be
# specified in favor of some other index.
#
# Run from the commandline.  Optional arg to specify where the output json files should go.
#
# example:  #> runscript.sh ./foo
#
# It will make the dir 'foo' and populate it with downloaded files.  if no dir is specified,
# then the default dir will be ./ELASTICDUMP_OUTPUT.
#
# mkdir ./TIRAR
# ./dumpindices_runscript.sh "falco" "./TIRAR"
#

containername="epic/tirayjala:1.0"

# Gather ElasticSearch auth so we can format a query from within the container.
# in my universe we get our admin auth from an api on our system accessible
# from a command, but you can do this any way you like.

export auth="elastic:elastic"

# We want the address of a controller running ElasticSearch. This command ought
# to be running on a controller so this shouldn't be too hard to identify. If
# there's an issue, invoke this from the Primary Controller.

export ipaddr="192.168.1.1"

# Change this to your preferred ElasticSearch Port, usually 9200.
export port="9200"

# This was written in support of falco, so it's the default string.  Change if
# you are dumping indices for some other filtering.  This gets passed into a
# "grep" command inside a container, so don't go crazy.

if [ -z "$1" ]
  then
    filterstring="falco"
else
    filterstring=$1
fi

# If you want to specify the second arg, you'll need to specify the first. I
# don't want to over engineer this tool so we are only passing in two args at
# most. If you want more, feel free to implement more args parsing.

if [ -z "$2" ]
  then
    inputpath="./ELASTICDUMP_OUTPUT"
else
    inputpath=$2
fi

OUTPUTDIR=$(realpath $inputpath)
mkdir -p $OUTPUTDIR

currdir=`pwd`

# Generate a random 8 char string so we  can distinguish sets of indices at
# the time of loading. ElasticSearch won't load an index with uppercase in its
# name, so be sure it's all lowercase when we're done.
#
# Example:  pfyfvwfc
#
randomstring=$(cat /dev/urandom | tr -dc 'A-Za-z0-9' | tr -dc [:lower:] | fold -w 8 | head -n 1)

# Run the command within the docker container.
# The spent container will exist, so may need cleanup afterwards.
docker run -it --volume=$OUTPUTDIR:$OUTPUTDIR:rw -e AUTH=$auth -e PORT=$port -e IPADDR=$ipaddr -e OUTPUT=$OUTPUTDIR -e DUMPPREFIX=$filterstring -e INDEXPREFIX=$randomstring $containername -c /dumpindices.sh 


