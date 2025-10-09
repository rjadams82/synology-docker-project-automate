# synology-docker-project-automate
## Automating Synology Container Manager Projects

> These scripts are under development. If you accept the risk you can install or run the script manually to evaluate results. Feedback is welcome. 

## What this is for
Synology Container Manager (docker) "Projects" are used to maintain docker compose applications within the Synology platform.
When docker images are updated/released in docker repositories it requires a clean of the Project, pull of the latest image and re-build of the Project.

> Why not use [portainer] [watchtower] [diun] [whatsupdocker] [dockcheck] [etc] ??
Native docker management/update tools engage directly with dockerd to manage compose, containers, images, volumes etc. 
Synology wraps dockerd in their Container Manager and includes a Projects module that stores the compose yaml as well as container/image/volume state and integrates with the Synology application portal (reverse proxy) to allow you to publish docker entry points on the synology web front end (Web Station).

This means that if you use ''#>docker compose '' commands on a Synology Diskstation, the docker container, volumes, network WILL build and start, but the "Projects" module will not be aware, and the Web Station portal may not be aware of the docker applications and/or map/connect the ports required.


*Note: *

### How the script works
1. First you would setup OpenVPN site-to-site VPN connection(s) in Unifi Application. (Since the remote endpoint may be behind CGNAT (LTE modem) or might have a DHCP WAN address, you would enter 0.0.0.0 as the "Remote IP Address".)
2. Next a task runs (calling the fix script) at regular intervals (using cron) to parse the configured site-to-site connections; if they have a Remote IP Address of "0.0.0.0" the fix adds the --float option and comments out the --remote option.
3. Then for any site-to-site config the fix has modified, it grabs the PID and kills the process, which automatically restarts (watchdog) with the updated config (--float #--remote).
4. Finally the fix will log any actions to "/var/log/ovpn-ptp-fix.log".

## Install the tool
*installer is under development. run at your own risk.*



The fix script will be automatically installed and ran from /data/custom/ - this should not be overwritten during Unifi software upgrades:
```
curl -L https://raw.githubusercontent.com/rjadams82/unifi-nextgen-openvpn/main/install.sh | bash
```

## Run the script manually (for testing)
if you just want to test the script, or need to debug, use this option.

upload the fix script to the device "/homes/user/project-rebuild.sh" using SCP or other file transfer tool

make the script executable then run the script
```
chmod 744 project-rebuild.sh
./project-rebuild.sh
```
