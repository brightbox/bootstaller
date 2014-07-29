#!/bin/bash

set -e
image_type=typ-g7u1p

clean_up() {
   echo "Cleaning up server"
   if [ "${server}" ]
   then
     brightbox servers destroy ${server}
   fi
   echo "Cleaning up image"
   if [ "${image}" ]
   then
     brightbox images destroy ${image}
   fi
}

clean_up_and_die() {
  clean_up
  exit 2
}

trap clean_up_and_die 1 2 3 15

if [ $# -ne 3 ]
then
  echo "Usage: $(basename $0) <image-id> <kickstart> <output file>" >&2
  exit 1
fi
output_file="$3"

server=$(brightbox -s servers create -f ${2} -t ${image_type} ${1} 2> /dev/null | cut -f1)

if [ -z "${server}" ]
then
  echo "Failed to create build server" >&2
  exit 1
fi
echo "Building with ${2} using server '${server}'"
echo -n "Waiting for build to complete"

status=$(brightbox -s servers list ${server} 2>/dev/null | cut -f2)
while [ "${status}" != 'inactive' ]
do
  echo -n "."
  sleep 5
  status=$(brightbox -s servers list ${server} 2>/dev/null | cut -f2)
done

echo
echo "${server} build complete"
brightbox servers snapshot ${server}

image=$(brightbox -s images list -t snapshot | grep "Snapshot of ${server}" | cut -f1)

echo "Snapshot image is ${image}"
echo -n "Waiting for snapshot to complete"
status=$(brightbox -s images list ${image} 2>/dev/null | cut -f5)
while [ "${status}" != 'private' ]
do
  echo -n "."
  sleep 5
  status=$(brightbox -s images list ${image} 2>/dev/null | cut -f5)
done

echo
echo "${image} snapshot complete"

if [ "$CLIENT" ]
then
   grep_str="^\\*\\?${CLIENT}"
else
   grep_str='^\*'
fi

user_creds=$(brightbox -s config 2>/dev/null | grep "${grep_str}" | cut -f2-3 | sed 's/\([^\t]*\)\t*\([^\t]*\)/-U \1 -K \2/')

echo "Downloading image ${image}"
swift -A https://files.gb1s.brightbox.com/v1 \
	${user_creds} download --output "${output_file}" images ${image}
echo "Cleaning up"
clean_up
exit 0
