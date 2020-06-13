#!/bin/sh -l

echo "Pre-sh!! $1"

env

echo "::debug::debug setup.sh"
echo "::warning::warning setup.sh"
echo "::set-env name=SETENV_SETUP_SH::setup-sh"

echo "::save-state name=ST_ID::123"
