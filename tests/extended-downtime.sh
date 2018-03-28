#! /bin/sh
set -e
set +m

curdir=$(dirname "${0}")
# shellcheck source=./utils.sh
. "${curdir}/utils.sh"

bring_up_env

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
echo_sleep 60

echo "Starting the app servers back up"
docker-compose up -d app_1
docker-compose up -d app_2
docker-compose up -d app_3

poll_logs "${STARTUP_REGEX}" 3

echo "Checking the session expiry / object unbound events happen"

poll_logs 'Unbound CleanupObject' 20

echo "Completed successfully!"
