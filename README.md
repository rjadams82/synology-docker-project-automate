# synology-docker-project-automate
### Automating Synology Container Manager Projects

> These scripts are under development. If you accept the risk you can use the script to evaluate your results. Feedback is welcome. 

## What this is for
Synology Container Manager (docker) "Projects" are used to maintain docker compose-like applications on the Synology diskstation platform. Projects use a yaml file (compose format) to define a collection of containers/volumes/networks. Projects work just like compose and building a project brings up all objects defined in the yaml.

When docker image maintainers update or release new versions in the docker repository it requires a manual clean of the Project, a pull of the latest image (update in the webui) and re-build of the Project. As far as I can tell there are no notifications for image updates.

This is an attempt at a hands-off method to handle rebuilding any running projects with the latest available image.

### How it works

Synology uses an API to handle the administration of most tasks on a diskstation. We can utilize the **synowebapi** binary on the local Synology system to feed requests to the Synology API.

The **SYNO.Docker.Project** API namespace allows us to start(up) and stop(down) Projects as well as clean (container/volume/network removal) and build (container/volume/network creation) Projects from the defined Project yaml file.

We use a simple bash script and the Synology API to perform actions on the Synology Container Manager Projects available on the target Synology system.

1. Call the API to get a list of Projects in the "RUNNING" state
2. Iterate through the list of Projects, obtain the id of each project and 
    - execute the 'clean_stream' method to bring the Projecct down
    - execute the 'build_stream' method to bring the Project back up
3. Logs each action to the system log


**Why not use portainer/watchtower/diun/whatsupdocker/dockcheck/etc ?**

Native docker management/update tools engage directly with dockerd to manage compose, containers, images, volumes etc.

Synology wraps dockerd in their Container Manager and includes a Projects module that stores the compose yaml as well as container/image/volume state and integrates with the Synology application portal (reverse proxy) to allow you to publish docker entrypoints on the synology web front end (Web Station).

This means that if you use ''#>docker compose '' commands on a Synology Diskstation, the docker container, volumes, network WILL build/start/run fine, but the "Projects" module will not be aware, and the Web Station portal may not be aware of the docker applications and/or map/connect the ports required.


*Note: *

## Use this tool
*script is under development. run at your own risk.*

### Run manually

If you just want to test the script, or need to debug, use this option.

1. Upload the script to the device using file transfer tool or curl
    ```
    cd ~

    curl -LO https://raw.githubusercontent.com/rjadams82/synology-docker-project-automate/refs/heads/main/project-rebuild.sh
    ```
2. make the script executable
3. run the script with sudo

    ```
    chmod 744 project-rebuild.sh
    sudo ./project-rebuild.sh
    ```


### Run on a schedule

The intended (easiest) way to use this tool is to create a scheduled task in DSM Control Panel, set the schedule to something appropriate (monthly/weekly/daily), choosing a time that is least impactful and paste the entire script contents into the task settings. The task needs to be run as the root user, or the API calls may fail.


### Check logs

`journalctl -t docker-project-rebuild`