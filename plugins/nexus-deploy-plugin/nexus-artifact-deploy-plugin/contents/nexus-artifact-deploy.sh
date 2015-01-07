#!/usr/bin/env bash


set -eu
set -vx

NEXUS_USER=admin
NEXUS_PASSWORD=admin123
NEXUS_URL=http://192.168.50.20:8081/nexus

if [[ $# -ne 5 ]] 
then
   echo >&2 "usage: $0 <repo> <group> <artifact> <version> <installdir>"
   exit 2
fi

REPO=$1
GROUP=$2
ARTIFACT=$3
VERSION=$4
INSTALLDIR=$5

echo "DEBUG: hostname:$(hostname), nexus:${NEXUS_URL}..."
set -eu

CURL="curl -s --fail -L -u $NEXUS_USER:$NEXUS_PASSWORD"

if ! $CURL "${NEXUS_URL}/service/local/artifact/maven/redirect?r=${REPO}&g=${GROUP}&a=${ARTIFACT}&v=${VERSION}" -o /tmp/out$$
then
   echo >&2 "Failed requesting artifact from nexus: $NEXUS_URL"
   exit 1
fi

mkdir -p $INSTALLDIR

mv /tmp/out$$ $INSTALLDIR

echo >&2 "DEBUG: copied $ARTIFACT to $INSTALLDIR"
ls -l $INSTALLDIR
