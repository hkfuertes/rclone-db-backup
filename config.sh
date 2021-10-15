#!/bin/bash
docker build -t rclone-backup .
docker run -it --rm -v `pwd`/rclone:/root/.config/rclone --network devenv_project rclone-backup /bin/bash -c "rclone config && bash"