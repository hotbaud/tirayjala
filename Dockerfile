################################################################################
# This Dockerfile builds a centos container with elasticdump. It then adds
# some scripts that invoke elasticdump so we can dump indices to files and
# load indices from files.
#
# Author:  Anne Marie Merritt
#          anne.marie.merritt@gmail.com
#
################################################################################

FROM centos:latest

# If run from inside my current universe, we have to set the proxies, so here
# are some examples of how to do that.

#RUN export HTTP_PROXY="http://proxy.someplace.net:8080"
#RUN export http_proxy="$HTTP_PROXY"
#RUN export https_proxy="$HTTP_PROXY"
#RUN export proxy="$HTTP_PROXY"
#RUN echo "proxy=${HTTP_PROXY}" >> /etc/yum.conf

# This seemed necessary for some reason.
RUN echo "diskspacecheck=0" >> /etc/yum.conf

RUN yum -y install nodejs npm which

# the elasticdump app is why we're here.
RUN npm i elasticdump

# Put our scripts into the / dir of the container we're building.
ADD scripts/insidecontainer_loadindices.sh /loadindices.sh
ADD scripts/insidecontainer_dumpindices.sh /dumpindices.sh

# We talk to ElasticSearch via elasticdump so lets expose the ports
# we care most about. Comment out the one you're not using, or change
# it as needed.

EXPOSE 9200

# This lets us just start the container at a bash commandline. Or as
# we do in our scripts, pass the arg -c /loadindices.sh or whatever
# is present inside the container.  We do this to allow debugging.

ENTRYPOINT ["/usr/bin/bash"]


################################################################################
# End of Dockerfile
################################################################################
