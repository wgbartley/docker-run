#!/bin/bash

CONTAINER=`basename $(pwd)`

do_cmd() {
	CMD="${1}"
	if [ "$EUID" -ne 0 ]; then
		CMD="sudo ${CMD}"
	fi
}

# Check if the container already exists in some state
CMD="docker ps -a | grep \"${CONTAINER}\" | wc -l"
do_cmd "${CMD}"
is_exists=`eval $CMD`


if [ $is_exists -eq 1 ]; then
	# Get the container ID
	CMD="docker ps -a | grep \"${CONTAINER}\" | awk '{ print \$1 }'"
	do_cmd "${CMD}"

	container_id=`eval $CMD`
	echo "${CONTAINER} container ID is ${container_id}"

	#Check if the container is running
	CMD="docker ps -f status=running | grep \"${CONTAINER}\" | wc -l"
	do_cmd "${CMD}"
	is_running=`eval $CMD`

	if [ $is_running -eq 1 ]; then
		echo -n "${CONTAINER} is running.  Stopping  . . ."
		CMD="docker stop ${container_id}"
		do_cmd "${CMD}"

		tmp=`eval $CMD`
		echo "done."
	fi


	echo -n "Deleting ${CONTAINER} . . . "
	CMD="docker rm ${container_id}"
	do_cmd "${CMD}"
	tmp=`eval $CMD`
	echo "done."
fi


echo -n "Running ${CONTAINER} . . . "

CMD="docker run $*"

do_cmd "${CMD}"

tmp=`eval $CMD`
echo "done."

echo "New container ID is ${tmp}."
