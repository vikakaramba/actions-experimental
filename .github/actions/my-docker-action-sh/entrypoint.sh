#!/bin/sh -l

echo "Entrypoint-sh!! $1"

env

echo "STATE_ST_ID=${STATE_ST_ID}"

echo "::debug::debug entrypoint.sh"
echo "::warning::warning entrypoint.sh"
echo "::set-env name=SETENV_SH::shsh"

time=$(date)
echo "::set-output name=time::$time"
