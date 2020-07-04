#!/bin/sh

set -eu

if [ -z "${INPUT_BOT_TOKEN}" ]
then
  echo "input 'bot_token' is not set"
  exit 1
fi

if [ -z "${INPUT_CHANNEL_ID}" ]
then
  echo "input 'channel_id' is not set"
  exit 1
fi

if [ -z "${INPUT_TEXT}" ]
then
  echo "input 'text' is not set"
  exit 1
fi

ATTACHMENTS="[]"
if [ ! -z "${INPUT_ATTACHMENTS}" ]
then
  ATTACHMENTS=${INPUT_ATTACHMENTS}
fi

jsonfile=/tmp/result.json

# See:
# - channel: https://api.slack.com/methods/chat.postMessage#arg_channel
# - text: https://api.slack.com/methods/chat.postMessage#arg_text
# - attachments: https://api.slack.com/methods/chat.postMessage#arg_attachments
curl -s -X POST \
     -H "Content-type: application/json; charset=UTF-8" \
     -H "Authorization: Bearer ${INPUT_BOT_TOKEN}" \
     -d "{\"channel\":\"${INPUT_CHANNEL_ID}\",\"text\":\"${INPUT_TEXT}\",\"attachments\":${ATTACHMENTS}}" \
     -o ${jsonfile} \
     https://slack.com/api/chat.postMessage

echo "::set-output name=json::$(cat ${jsonfile})"

grep '"error":' ${jsonfile}
if [ $? -eq 0 ]
then
  echo "slack returned error response"
  exit 1
fi
