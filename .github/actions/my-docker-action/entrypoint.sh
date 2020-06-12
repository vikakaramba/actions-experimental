#!/bin/sh -l

echo "Wayway!! $1"
time=$(date)
echo ::set-output name=time::$time
