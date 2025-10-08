#!/bin/bash
# synology docker project rebuild
# 2025-10-07 rjadams82
# take projects down/clean, re-build
# call this from cron or run manually etc
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
logtag="docker-project-rebuild"
# logger function
log_it() {
    local priority="$1"
    local message="$2"
    # output to STDIN
    echo ${message}
    # log to journal    
    /usr/bin/logger --id=$$ -t "${logtag}" -p "${priority}" -- "${message}"
}
# call api to get list of running projects
echo "Searching running Docker projects..."
readarray -t projects < <(synowebapi --exec api=SYNO.Docker.Project version=1 method=list | jq -rc '.data[] | select(.status=="RUNNING")| { id: .id, name: .name, status: .status }')
# check for output
if [ -z "$projects" ]; then
    echo "No Docker projects found. Exiting."
    log_it "user.notice" "No running Syno Docker projects found. Exiting."
    exit 0
fi
# loop through projects
echo "Found ${#projects[@]} running Docker projects..."
echo "${projects[@]}" | jq -cr '.'
for project in "${projects[@]}"; do
    project_id=$(echo ${project} | jq -r '.id')
    project_name=$(echo ${project} | jq -r '.name')

    echo "Clean project:$project_name ID:$project_id"    
    synowebapi --exec api=SYNO.Docker.Project version=1 method=clean_stream id=\"${project_id}\"
    log_it "user.notice" "Project $project_name down and cleaned"
    #sleep 15
    echo "Build project:$project_name ID:$project_id"
    synowebapi --exec api=SYNO.Docker.Project version=1 method=build_stream id=\"${project_id}\"
    log_it "user.notice" "Project $project_name built and started"
    #sleep 15
done
echo "All project builds complete"
exit 0