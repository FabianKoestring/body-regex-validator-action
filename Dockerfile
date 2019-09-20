FROM alpine:latest

LABEL "com.github.actions.name"="Issue/Pull-Request guideline checker"
LABEL "com.github.actions.description"="Check if issue or pr descriptions met specific guidelines."
LABEL "com.github.actions.icon"="message-square"
LABEL "com.github.actions.color"="gray-dark"

LABEL "repository"="https://github.com/FabianKoestring/issue-guideline-checker"
LABEL "homepage"="https://github.com/FabianKoestring/issue-guideline-checker"
LABEL "maintainer"="Fabian Köstring"

RUN apk add --no-cache bash curl jq

COPY "entrypoint.sh" "/entrypoint.sh"
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
