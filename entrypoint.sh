#!/bin/bash

set -e

if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Set the GITHUB_TOKEN env variable."
  exit 1
fi

if [[ -z "$GITHUB_REPOSITORY" ]]; then
  echo "Set the GITHUB_REPOSITORY env variable."
  exit 1
fi

if [[ -z "$GITHUB_EVENT_PATH" ]]; then
  echo "Set the GITHUB_EVENT_PATH env variable."
  exit 1
fi

if [[ -z "$GITHUB_EVENT_NAME" ]]; then
  echo "Set the GITHUB_EVENT_NAME env variable."
  exit 1
fi

if [[ -z "$PULL_REQUEST_PATTERN" && -z "$ISSUE_PATTERN" ]]; then
  echo "Set either the PULL_REQUEST_PATTERN or the ISSUE_PATTERN env variables."
  exit 1
fi

if [[ ! -z "$PULL_REQUEST_PATTERN" && -z "$PULL_REQUEST_COMMENT" ]]; then
  echo "Set the PULL_REQUEST_COMMENT env variable."
  exit 1
fi

if [[ ! -z "$ISSUE_PATTERN" && -z "$ISSUE_COMMENT" ]]; then
  echo "Set the ISSUE_COMMENT env variable."
  exit 1
fi

sendReaction() {
    local GITHUB_ISSUE_NUMBER="$1"

    curl -sSL \
         -H "Authorization: token ${GITHUB_TOKEN}" \
         -H "Accept: application/vnd.github.squirrel-girl-preview+json" \
         -X POST \
         -H "Content-Type: application/json" \
         -d "{\"content\":\"heart\"}" \
            "https://api.github.com/repos/${GITHUB_REPOSITORY}/issues/${GITHUB_ISSUE_NUMBER}/reactions"
}

sendComment() {
    local GITHUB_ISSUE_NUMBER="$1"
    local GITHUB_ISSUE_COMMENT="$2"

    curl -sSL \
         -H "Authorization: token ${GITHUB_TOKEN}" \
         -H "Accept: application/vnd.github.v3+json" \
         -X POST \
         -H "Content-Type: application/json" \
         -d "{\"body\":\"${GITHUB_ISSUE_COMMENT}\"}" \
            "https://api.github.com/repos/${GITHUB_REPOSITORY}/issues/${GITHUB_ISSUE_NUMBER}/comments"
}

closeIssue() {
    local GITHUB_ISSUE_NUMBER="$1"

    curl -sSL \
         -H "Authorization: token ${GITHUB_TOKEN}" \
         -H "Accept: application/vnd.github.v3+json" \
         -X POST \
         -H "Content-Type: application/json" \
         -d "{\"state\":\"closed\"}" \
            "https://api.github.com/repos/${GITHUB_REPOSITORY}/issues/${GITHUB_ISSUE_NUMBER}"
}

main() {
    GITHUB_EVENT_ACTION=$(jq --raw-output .action "$GITHUB_EVENT_PATH")

    # handle pull_request
    if [[ "$GITHUB_EVENT_NAME" == "pull_request" && "$GITHUB_EVENT_ACTION" == "opened" ]]; then
        GITHUB_PULL_REQUEST_EVENT_NUMBER=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")
        GITHUB_PULL_REQUEST_EVENT_BODY=$(jq --raw-output .pull_request.body "$GITHUB_EVENT_PATH")

        if [[ "$GITHUB_PULL_REQUEST_EVENT_BODY" =~ $PULL_REQUEST_PATTERN ]]
        then
            sendReaction "$GITHUB_PULL_REQUEST_EVENT_NUMBER"
        else
            sendComment "$GITHUB_PULL_REQUEST_EVENT_NUMBER" "$PULL_REQUEST_COMMENT"
            closeIssue "$GITHUB_PULL_REQUEST_EVENT_NUMBER"
        fi
    fi

    # handle issues
    if [[ "$GITHUB_EVENT_NAME" == "issues" && "$GITHUB_EVENT_ACTION" == "opened" ]]; then
        GITHUB_ISSUE_EVENT_NUMBER=$(jq --raw-output .issue.number "$GITHUB_EVENT_PATH")
        GITHUB_ISSUE_EVENT_BODY=$(jq --raw-output .issue.body "$GITHUB_EVENT_PATH")

        if [[ "$GITHUB_ISSUE_EVENT_BODY" =~ $ISSUE_PATTERN ]]
        then
            sendReaction "$GITHUB_ISSUE_EVENT_NUMBER"
        else
            sendComment "$GITHUB_ISSUE_EVENT_NUMBER" "$ISSUE_COMMENT"
            closeIssue "$GITHUB_ISSUE_EVENT_NUMBER"
        fi
    fi
    exit 0
}

main
