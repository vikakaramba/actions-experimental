#!/bin/sh -l

echo "Wayway-sh!! $1"
time=$(date)
echo ::set-output name=time::$time
