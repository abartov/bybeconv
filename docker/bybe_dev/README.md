This folder contains docker-compose configuration for development environment

## Preparing development environment for using docker

NOTE: all `docker-compose` calls commands should be done from folder containing `docker-compose.yml` file.

### 1 .Setting file permissions
We mount project directory into a docker image, so it will write some files there (e.g. server pids or logs).
By default docker would write them with root permissions and this can cause some problems.
You can override permissions used by docker service by providing proper user and group ids to docker-compose.

To achieve this simply copy `docker-compose.override.example.yml` file to `docker-compose.override.yml` and fill `user`
attribute with `UID:GID` of desired host user, e.g.:
```
  app:
    user: '1000:1000'
```

NOTE: You can find your uid and gid using `id` command:
```
# id
uid=1000(myuser) gid=1000(myuser) groups=1000(myuser),1001(docker)
```

### 2. Updating memory preferences

In order to use elasticsearch with docker we need to update vm memory preferences, so open as root `/etc/sysctl.conf`
and add there a line:
```
vm.max_map_count=262144
```

### 3. Update configuration files

You need to update set of configuration files in `config` folder:
- `chewy.yml` - just copy content of `chewy.yml.docker`
- `database.yml` - just copy content of `database.yml.docker`
- `constants.yml` and `storage.yml` - simply copy content of `constants.yml.sample` and `storage.yml.sample`
- `s3.yml` - you can copy content of `s3.yml.sample` but to have images properly loaded you'll need real keys for our server. 


### 4. Install required gems

```
# docker-compose run --rm app bundle install
```

### 5. Prepare databases
At first you need to create databases:
```
# docker-compose run --rm app rails db:create
```

You'll probably want to use snapshot of production db for development. So you need to restore it from dump:
```
# cat <PATH_TO_DUMP_FILE> | docker exec -i bybe_dev_mysql_1 mysql -u root --password=root bybe_dev
```

Now we need to migrate this db:
```
# docker-compose run --rm app rails db:migrate
```
And migrate test database as well:
```
# docker-compose run --rm app rails db:migrate RAILS_ENV=test
```

### 6. Rebuild Elasticsearch indices
```
# docker-compose run --rm app rake chewy:reset
```

### 7. Running tests

Now you can try to run specs to check your setup 
```
# docker-compose run --rm app rspec
```

### 8. Staring app
```
# docker-compose up -d
```

App should be available at http://localhost:3001
Also you should have kibana working at http://localhost:5602
And you can connect to MySQL at localhost:3307, using root/root credentials

## Useful hints

### Starting and stopping containers

To create and start containers defined in docker-compose file simply run:
```
# docker-compose up -d
```

If you have changed docker images config you may need to provide additional keys to force image rebuild:
```
# docker-compose up --build -d 
```

To stop containers temporarily run:
```
# docker-compose stop
```

To start stopped containers run:
```
# docker-compose start
```

To stop and remove all containers
```
# docker-compose down
```

If you also want to remove all volumes used by containers, add `-v' key:
```
# docker-compose down -v
```
NOTE: this will remove all database and elastic search data, as well as bundler cache

### Getting into app's bash

If you need to get bash console on app container use:
```
# docker-compose run --rm app bash
```

You can replace `bash`command with any other program you want to run.

NOTE: `run` command creates new container, so `--rm` is added to remove this new container after command is executed.



### Creating DB dump
```
# docker exec bybe_dev_mysql_1 mysqldump -u root --password=root <DB_NAME> | cat > <PATH_TO_DUMP_FILE>
```

### Restoring DB dump

```
# cat <PATH_TO_DUMP_FILE> | docker exec -i bybe_dev_mysql_1 mysql -u root --password=root <DB_NAME>
```
