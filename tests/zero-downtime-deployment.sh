#! /bin/bash
set -e

echo_sleep () {
    i=$1
    until [ "$i" -lt 0 ]; do
        printf '\r%3d' "${i}";
        sleep 1;
        i=$((i-1))
    done
    printf '\r\n';
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

# Create a session
COOKIE_FILE=cookies.txt
curl -I -c "${COOKIE_FILE}" http://localhost
trap 'rm -rf "./${COOKIE_FILE}"' 0 1 2

# store the session
SESSIONID=$(grep JSESSIONID "${COOKIE_FILE}" | awk '/./ { print $NF }')

make_another_request() {
    curl -I -b "${COOKIE_FILE}" -c "${COOKIE_FILE}" http://localhost
    # check the session cookie hasn't changed
    if [ "$(grep -c "${SESSIONID}" "${COOKIE_FILE}")" -ne "1" ]; then
        echo "session cookie has changed!"
        exit 1
    fi
}

# Show the same session is used by as the load-balancer round-robins requests
make_another_request
make_another_request
make_another_request
make_another_request
make_another_request
make_another_request

echo 'replicating rolling deployment'

redeploy() {
    app=$1
    echo "stop ${app}"
    docker-compose stop "${app}"
    echo_sleep 5
    echo "start ${app}"
    docker-compose up -d "${app}"
    echo_sleep 10
    docker-compose logs --tail 10 "${app}"
}

redeploy app_1
make_another_request

redeploy app_2
make_another_request

redeploy app_3
make_another_request

# what if we sleep, then do another request? One app instance will have a more recently-accessed
# session. Will the other 2 instances also pick that up, or might one instance expire the session
# and prematurely log someone out?

echo_sleep 50

make_another_request

echo_sleep 50

make_another_request

echo "Succeeded in doing our rolling deploy without disrupting users!"
