#! /bin/bash
set -e

echo_sleep () {
    i=$1
    until [ "$i" -lt 0 ]; do
        printf '\rWaiting ... %3d' "${i}";
        sleep 1;
        i=$((i-1))
    done
}

echo "ensuring we have a clean environment"

docker-compose down
docker-compose rm -v -f

echo "Starting a clean environment"
docker-compose up -d

echo_sleep 30

docker-compose logs --tail=10 app_1
docker-compose logs --tail=10 app_2
docker-compose logs --tail=10 app_3

# create 20 sessions
COUNTER=20
until [  $COUNTER -lt 1 ]; do
    curl -I http://localhost
    COUNTER=$((COUNTER-1))
done

echo "Checking the logs to see that sessions were created and had objects bound to them"
docker-compose logs --tail=10 app_1
docker-compose logs --tail=10 app_2
docker-compose logs --tail=10 app_3

echo "Simulating downtime by stopping all of the app servers"
docker-compose stop app_1
docker-compose stop app_2
docker-compose stop app_3

echo "Sleep long enough for all of the sessions expire"
echo_sleep 120

echo "Starting the app servers back up"
docker-compose up -d app_1
docker-compose up -d app_2
docker-compose up -d app_3

echo "Sleep to let the apps start up"
echo_sleep 30

# Check that the logs show that the object was cleaned afer the restart
echo "tail the logs to see the session expiry / object unbound events happen"
docker-compose logs -f
