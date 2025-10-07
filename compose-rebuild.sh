#!/bin/bash
# docker compose automate
# 2025-10-07 rjadams82
# clean, re-pull, re-build by calling this from cron or running manually etc
#
# error handling
#set -x # full xtrace output
set -o errtrace
handle_error() {
    echo "FAILED: line $1, exit code $2"
    exit 1
}
trap 'handle_error $LINENO $?' ERR
#
logtag="compose-rebuild"
# logger function
log_it() {
    local priority="$1"
    local message="$2"
    # output to STDIN
    echo ${message}
    # log to journal    
    /usr/bin/logger --id=$$ -t "${logtag}" -p "${priority}" -- "${message}"
}

echo "Gathering Docker Compose projects..."
composeprojects=$(docker compose ls --format json)
projects=$(echo $composeprojects | grep -o '"Name":"[^"]*' | grep -o '[^"]*$')
projectsyaml=$(echo $composeprojects | grep -o '"ConfigFiles":"[^"]*' | grep -o '[^"]*$')
# check for output
if [ -z "$projects" ]; then
    echo "No Docker Compose projects found. Exiting."
    log_it "user.notice" "No Docker Compose projects found. Exiting."
    exit 0
fi
# loop through projects
echo "Bringing down projects..."
#for project in $(echo $composeprojects | grep -o '"Name":"[^"]*' | grep -o '[^"]*$'); do
for project in $projects; do
    echo "Bringing down project: $project"
    docker compose -p "$project" down
    log_it "user.notice" "Project $project brought down"
done

echo "Rebuilding all projects..."
for yaml in $projectsyaml; do
    echo "Building yaml: $yaml"
    docker compose -f "$yaml" up --build
    log_it "user.notice" "$yaml build complete"
done

echo "All project builds complete"
exit 0