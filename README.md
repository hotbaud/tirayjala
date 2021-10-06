# tirayjala
#
# author:  Anne Marie Merritt
#          anne.merritt@hpe.com
#

Push/Throw and Pull ElasticSearch indices via a containerized version of ElasticDump

ElasticDump can dump ElasticSearch indices as well as load them into ElasticSearch.

------

Why does this exist?

Unfortunately, the older versions of ElasticDump have incompatibility issues with
older versions of ElasticSearch - such that the two don't work and play well together
when we include fun things like TLS or json header specification.

The answer is to containerize a version of ElasticDump that can work against any of
the versions and contains all the bugfixes.

In addition, included are some example scripts for downloading and uploading indices
to and from files.

ElasticDump can also transfer records from host to host, but this doesn't perform
that action.  Feel free to expand your repertoire of ElasticDump scripts and let me
know!  We can add them to the pool.

-------

Version for arbitrary environments, with or without a proxy.

For fun we also include a script that builds and packages the image into a tar.gz
file.  Why?  Because we can.  The image is also just as easily uploaded to dockerhub
or wherever once you customize it to your heart's content.  Or you can just build it
from scratch all the time to ensure you get the latest patched version of Centos, as
people are constantly running package scanners against containers.

Note that it's also possible, if you are feeling frisky, to mount an executable
file within the container as a volume.  Then you can run it in an automated way
while still being able to edit the script for debug while not constantly rebuilding
the container each time.

In this case, we include the file within the container, so editing it can only
happen BEFORE creating the container.  This just makes it easier for folks to run.

But for more flexibility, feel free to mount your own script, and access it using
the -c scriptname facility.

The container will run bash automagically, so all args to the container are
with respect to bash, e.g.

Container Entrypoint:
/usr/bin/bash

We add:
-c loadindices.sh

We also add a bunch of env values to the container runtime so we can pass in
things like auth and IP addresses of ElasticSearch from outside.  Since your
way of doing auth will be different for each environment, feel free to edit the
invocation outside-container scripts to do auth your way.
