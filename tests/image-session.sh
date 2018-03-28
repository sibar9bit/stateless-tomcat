#! /bin/sh
set -e
set +m

curdir=$(dirname "${0}")
# shellcheck source=./utils.sh
. "${curdir}/utils.sh"

bring_up_env

# Create a session. This is the first write to the session store
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
# 2nd write to the session store
make_another_request
# 3rd write to the session store
make_another_request


echo "check the logs to see if requesting an image causes a session to be loaded"

# 4th write to the session store?
curl -I -b "${COOKIE_FILE}" -c "${COOKIE_FILE}" http://localhost/1x1.gif

echo "Another image request but without a session cookie to simulate a cookie-less domain"

curl -I http://localhost/1x1.gif

docker-compose logs | grep -E 'SESSION_LOGGER|storing session'
