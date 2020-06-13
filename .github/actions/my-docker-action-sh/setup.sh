#!/bin/sh -l

echo "Pre-sh!! $1"

env

echo "::save-state name=ST_ID::123"
