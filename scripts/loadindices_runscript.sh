#!/usr/bin/bash
#
# Author:  Anne Marie Merritt
#          anne.marie.merritt@gmail.com
#
# This script loads indices as specified by the container's internal script 'loadindices.sh".
# It gathers auth and IP info not available from inside the container, and passes them
# through as environment variables.  The script can then access those values to issue curl
# commands and elasticdump commands to format queries and load the specified files into
# ElasticSearch as indices..
#
# Run from the commandline. If the dir containing the dumped indices is not specified, a
# default path of ELASTICDUMP_OUTPUT will be assumed.
#
# example:  #> loadindices_runscript.sh.sh ./foo
#

# In my universe the container name is as below, but you do you.
containername="epic/tirayjala:1.0"

# in my universe we get our admin auth from an api on our system accessible
# from a command, but you can do this any way you like.

export auth="elastic:elastic"

# Again, this is the host ip of the ElasticSearch cluster you want. So if you're
# using different tools, go ahead and change this as needed.

export ipaddr="192.168.1.1"

# Change this to your preferred ElasticSearch Port, usually 9200.
export port="9200"

if [ -z "$1" ]
  then
    inputpath="./ELASTICDUMP_OUTPUT"
else
    inputpath=$1
fi

if [ -d $inputpath ] 
then
    echo "Directory $inputpath exists.  Proceeding..." 
else
    echo "Error: Directory $inputpath  does not exist. Exiting."
    exit 1
fi

OUTPUTDIR=$(realpath $inputpath)

# Run the container. As you can see, the loadindices.sh script is inside
# the container in dir / so you can run it directly from there, and pass
# it the docker env variables as noted below.
#
# You should check the size of the indices before running this; larger
# indices will have more records and will thus take longer, in direct
# proportion. But you can also ^C out of it if you like, and only get a
# subset of indices while debugging.

docker run -it --volume=$OUTPUTDIR:$OUTPUTDIR:rw -e AUTH=$auth -e PORT=$port -e IPADDR=$ipaddr -e OUTPUT=$OUTPUTDIR $containername -c /loadindices.sh

