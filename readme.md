## Rclone Database Backup
Simple docker image to `cron` a database backup to a popular cloud service.

### Uploaded to public registry!
Using `ghcr.io` the image is now public and on github repository:

To get the config for rclone:
```shell
docker run -it --rm -v `pwd`:/root/.config/rclone ghcr.io/hkfuertes/rclone-db-backup /bin/bash -c "rclone config"
```

```yaml
version: '2'

services:
  rclone:
    image: ghcr.io/hkfuertes/rclone-db-backup
    environment:
      - DATABASE_USER=${DATABASE_USER}
      - DATABASE_PASSWORD=${DATABASE_PASSWORD}
      - DATABASE_NAME=${DATABASE_NAME}
      - DATABASE_HOST=${DATABASE_HOST}
      - DATABASE_PORT=${DATABASE_PORT}
      - REMOTE_SERVICE=${REMOTE_SERVICE}
      - REMOTE_FOLDER=${REMOTE_FOLDER}
      - CRON_EXPRESION=${CRON_EXPRESION}
      - REMOTE_KEEP_TIME=${REMOTE_KEEP_TIME:-5d}
    volumes:
      - ./:/root/.config/rclone
    restart: unless-stopped
```

### Configure
First you need to setup your remotes `rclone config`, to do so run the following commands and follow the steps:

```shell
docker build -t rclone-backup .
docker run -it --rm -v `pwd`:/root/.config/rclone rclone-backup /bin/bash -c "rclone config"
```

This will produce a file called `rclone.conf` similar to this:

```conf
[nextcloud]
type = webdav
url = <some_url>
vendor = nextcloud
user = <some_user>
pass = <some_password>
```

### Run
You can run it via docker-compose, but there are several environment variables that need to be passed on:

| Variable | Example Value | Description |
|--------- | ------------- | ----------- |
| DATABASE_NAME | csbookdb | Name of the database. |
| DATABASE_USER | admin | Database user to be used. |
| DATABASE_PASSWORD | **** | Database user's password. |
| DATABASE_HOST | localhost | Database url. |
| DATABASE_PORT | 3306 | Database port. |
| REMOTE_SERVICE | nextcloud | Service to be used from the `rclone.conf` file. (ex. _[nextcloud]_) |
| REMOTE_FOLDER | csbookdb/ | Folder inside the remote. |
| CRON_EXPRESION | * * * * * | CRON expresion for the backup to happen. |
| REMOTE_KEEP_TIME | 5d | Retention days to keep backups. |

To run it:

```shell
cp .env.dist .env
nano .env #And edit all the variables
docker-compose up -d
```

### Pro Tip
You can add the docker compose file to a larger docker-compose file, and as they all would be in the same network you can use `database` as host.

```yaml
version: '2'

services:
  rclone:
    build:
      context: .
    environment:
      - DATABASE_USER=${DATABASE_USER}
      - DATABASE_PASSWORD=${DATABASE_PASSWORD}
      - DATABASE_NAME=${DATABASE_NAME}
      - DATABASE_HOST=${DATABASE_HOST}
      - DATABASE_PORT=${DATABASE_PORT}
      - REMOTE_SERVICE=${REMOTE_SERVICE}
      - REMOTE_FOLDER=${REMOTE_FOLDER}
      - CRON_EXPRESION=${CRON_EXPRESION}
      - REMOTE_KEEP_TIME=${REMOTE_KEEP_TIME:-5d}
    volumes:
      - ./:/root/.config/rclone
    restart: unless-stopped
```