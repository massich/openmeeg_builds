These are the scripts, tools, notes, etc. that I use in order to replicate
[OpenMEEG](https://github.com/openmeeg/openmeeg) builds and tests.


Execute a vanilla travis image in docker (taken from 
[stackoverflow](https://stackoverflow.com/questions/21053657/how-to-run-travis-ci-locally/24936720)):

```sh
RANDOM-ID=00031
BUILDID="build-${RANDOM-ID}"
INSTANCE="travisci/ci-garnet:packer-1515445631-7dfb2e1"
docker run --name $BUILDID -dit $INSTANCE /sbin/init
docker exec -it $BUILDID bash -l\n
```
