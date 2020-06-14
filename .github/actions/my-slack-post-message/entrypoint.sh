#!/bin/sh

set -eu

if test -z "${INPUT_BOT_TOKEN}"
then
  echo "input 'bot_token' is not set"
  exit 1
fi

if test -z "${INPUT_CHANNEL_ID}"
then
  echo "input 'channel_id' is not set"
  exit 1
fi

if test -z "${INPUT_TEXT}"
then
  echo "input 'text' is not set"
  exit 1
fi

jsonfile=/tmp/result.json

curl -s -X POST \
     -H "Content-type: application/json; charset=UTF-8" \
     -H "Authorization: Bearer ${INPUT_BOT_TOKEN}" \
     -d "{\"channel\":\"${INPUT_CHANNEL_ID}\",\"text\":\"${INPUT_TEXT}\"}" \
     -o ${jsonfile} \
     https://slack.com/api/chat.postMessage

echo "::set-output name=json::$(cat ${jsonfile})"
