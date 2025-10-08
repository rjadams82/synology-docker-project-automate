#!/bin/sh

# scratch 


# rewriting with synowebapi calls 
# synowebapi --exec api=SYNO.Docker.Project version=1 method=list

synowebapi --exec api=SYNO.Docker.Project version=1 method=list | jq -rc '.data[] | { id: .id, name: .name, status: .status }'
method=get id=
method=clean_stream id=
method=build_stream id=

# list all projects
synowebapi --exec api=SYNO.Docker.Project version=1 method=list | jq -rc '.data[] | { id: .id, name: .name, status: .status }'
synowebapi --exec api=SYNO.Docker.Project version=1 method=list | jq -rc '.data[] | select(.status=="RUNNING") | { id: .id, name: .name, status: .status }'
# get project details
synowebapi --exec api=SYNO.Docker.Project version=1 method=get 'id="97506ed6-bac4-4a85-af18-3d2ab4cf4e0d"'
# down/clean
synowebapi --exec api=SYNO.Docker.Project version=1 method=clean_stream 'id=""'
synowebapi --exec api=SYNO.Docker.Project version=1 method=clean_stream id=\"${project_id}\"
# up/build
synowebapi --exec api=SYNO.Docker.Project version=1 method=build_stream 'id=""'

# check docker images
synowebapi --exec api=SYNO.Docker.Image version=1 method=list limit=-1 offset=0 show_dsm=false | jq '.data.images[] | select(.upgradable==true)'
synowebapi --exec api=SYNO.Docker.Image version=1 method=list limit=-1 offset=0 show_dsm=false | jq '.data.images[] | select(.upgradable==false and .tags[]=="latest") | { repo: .repository, tags: .tags, upgradable: .upgradable}'
