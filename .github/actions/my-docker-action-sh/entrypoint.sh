#!/bin/sh -l

echo "Entrypoint-sh!! $1"

env

echo ">>>>> STATE_ST_ID=${STATE_ST_ID}"

echo "::debug::debug entrypoint.sh"
echo "::warning::warning entrypoint.sh"
echo "::set-env name=SETENV_ENTRYPOINT_SH::entrypoint-sh"

echo "::save-state name=ST_ID::234"

time=$(date)
echo "::set-output name=time::$time"
