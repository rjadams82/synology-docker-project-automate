#!/bin/sh
# scratch notes for synology docker project api usage
# 2025-10-07 rjadams82
# rewriting with synowebapi calls 
# synowebapi --exec api=SYNO.Docker.Project version=1 method=list

synowebapi --exec api=SYNO.Docker.Project version=1 
method=list | jq -rc '.data[] | { id: .id, name: .name, status: .status }'
method=get id=
method=clean_stream id=
method=build_stream id=


# list all projects
synowebapi --exec api=SYNO.Docker.Project version=1 method=list | jq -rc '.data[] | { id: .id, name: .name, status: .status }'
# list running projects
synowebapi --exec api=SYNO.Docker.Project version=1 method=list | jq -rc '.data[] | select(.status=="RUNNING") | { id: .id, name: .name, status: .status }'
# get project details
synowebapi --exec api=SYNO.Docker.Project version=1 method=get id=\"3bf47c59-6b5c-472f-8420-dbb9db0da9f0\" | jq '.data'

# stop a project
synowebapi --exec api=SYNO.Docker.Project version=1 method=stop_stream id=\"${project_id}\"

# get project details
synowebapi --exec api=SYNO.Docker.Project version=1 method=get 'id="97506ed6-bac4-4a85-af18-3d2ab4cf4e0d"'

# get container list
synowebapi --exec api=SYNO.Docker.Container version=1 method=list limit=-1 offset=0 | jq -r '.data[]' 
synowebapi --exec api=SYNO.Docker.Container version=1 method=list limit=-1 offset=0 | jq -rc '.data.containers[]|{name: .name, id: .id, status: .status, image: .Image, imageid: .ImageID}'
synowebapi --exec api=SYNO.Docker.Container version=1 method=list limit=-1 offset=0 | jq -r '.data.containers[] | select (.) | {name: .name, id: .id, status: .status, image: .Image, imageid: .ImageID}'

# down/clean
synowebapi --exec api=SYNO.Docker.Project version=1 method=clean_stream 'id=""'
synowebapi --exec api=SYNO.Docker.Project version=1 method=clean_stream id=\"${project_id}\"

# up/build
synowebapi --exec api=SYNO.Docker.Project version=1 method=build_stream 'id=""'
synowebapi --exec api=SYNO.Docker.Project version=1 method=build_stream id=\"${project_id}\"

# check docker images
synowebapi --exec api=SYNO.Docker.Image version=1 method=list limit=-1 offset=0 show_dsm=false | jq -c '.data.images[] '
synowebapi --exec api=SYNO.Docker.Image version=1 method=list limit=-1 offset=0 show_dsm=false | jq -rc '.data.images[] | { repo: .repository, tags: .tags, upgradable: .upgradable}'
synowebapi --exec api=SYNO.Docker.Image version=1 method=list limit=-1 offset=0 show_dsm=false | jq -rc '.data.images[] | select(.upgradable==true and .tags[]=="latest") | { repo: .repository, tags: .tags, upgradable: .upgradable}'
synowebapi --exec api=SYNO.Docker.Image version=1 method=list limit=-1 offset=0 show_dsm=false | jq -rc '.data.images[] | select(.upgradable==true and .tags[]=="latest") | { repo: .repository, id: .id, digest: .digest, tags: .tags, upgradable: .upgradable}'

# upgrade image
api=SYNO.Docker.Image version=1 method=upgrade_start repository=%22linuxserver%2Funifi-network-application%22
api=SYNO.Docker.Image method=upgrade_start version=1 repository=%22homeassistant%2Fhome-assistant%22

# auto upgrade iterate - use this instead?
readarray -t imagesupgradable < <(synowebapi --exec api=SYNO.Docker.Image version=1 method=list limit=-1 offset=0 show_dsm=false | jq -rc '.data.images[] | select(.upgradable==true and .tags[]=="latest") | { repo: .repository, id: .id, digest: .digest, tags: .tags, upgradable: .upgradable}')
echo ${imagesupgradable[@]} | jq
for image in "${imagesupgradable[@]}"; do
    image_repo=$(echo ${image} | jq -r '.repo')
    echo "Upgrading image: $image_repo"
    synowebapi --exec api=SYNO.Docker.Image version=1 method=upgrade_start repository=\"${image_repo}\"
    sleep 5
done

# remove unused images
api=SYNO.Docker.Image version=1 method=prune 
