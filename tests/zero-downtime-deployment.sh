#! /bin/sh
set -e
set +m

curdir=$(dirname "${0}")
# shellcheck source=./utils.sh
. "${curdir}/utils.sh"

echo "ensuring we have a clean environment"

docker-compose down
docker-compose rm -v -f

echo "Starting a clean environment"
docker-compose up -d

poll_logs "${STARTUP_REGEX}" 3

echo "everything looks up, testing"
echo_sleep 3

# Create a session
COOKIE_FILE=cookies.txt
curl -I -c "${COOKIE_FILE}" http://localhost

cleanup() {
    rm "${COOKIE_FILE}"
}

trap cleanup 0 1 2

# store the initial session ID to check whether we use the same sesssion all the time.
#
# * Vanilla Tomcat uses JSESSIONID
# * Spring Boot session with JDBC uses SESSION
#
# SESSION is common and sufficiently unique.
SESSIONID=$(grep SESSION "${COOKIE_FILE}" | awk '/./ { print $NF }')

make_another_request() {
    curl -I -b "${COOKIE_FILE}" -c "${COOKIE_FILE}" http://localhost
    # check the session cookie hasn't changed
    if [ "$(grep -c "${SESSIONID}" "${COOKIE_FILE}")" -ne "1" ]; then
        echo "session cookie has changed!"
        echo "Expected: ${SESSIONID} but was: $(cat ${COOKIE_FILE})"
        exit 1
    fi
}

# Show the same session is used by the client as the load-balancer round-robins requests
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
    poll_logs "${STARTUP_REGEX}" 1
    # poll_logs resets traps so we need to add this back. Time to rewrite in Go?
    trap cleanup 0 1 2
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

# Tomcat PersistentValve handles that by having a list of active sessions. After each request,
# the session is stored in the persisent store and removed from the list of active sessions
# for that Tomcat. It thus becomes ineligible for being expired by that instance. Expiry will be
# detected if a subsequent request is made after the session has expired.

echo_sleep 50

make_another_request

echo_sleep 50

make_another_request

echo "Succeeded in doing our rolling deploy without disrupting users!"
