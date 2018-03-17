#!/bin/sh
set +m

echo_sleep () {
    i=$1
    until [ "$i" -lt 0 ]; do
        printf '\rWaiting ... %3d' "${i}";
        sleep 1;
        i=$((i-1))
    done
    printf '\r\n';
}

poll_logs() {
    search=$1
    count=$2

    logs_pipe=$(mktemp -u)
    mkfifo "${logs_pipe}"

    docker-compose logs -f --tail="0" > "${logs_pipe}" &
    LOG_PID=$!

    cleanup_pipe() {
        kill "${LOG_PID}" > /dev/null 2>&1
        rm "${logs_pipe}"
    }

    trap cleanup_pipe 0 1 2

    MATCHING_COUNT=0
    while read -r line; do
        echo "${line}"
        if [ "$(echo "${line}" | grep -c "${search}")" = "1" ]; then
            MATCHING_COUNT=$((MATCHING_COUNT+1))
            if [ "${MATCHING_COUNT}" = "${count}" ]; then
                break
            fi
        fi
    done < "${logs_pipe}"

    cleanup_pipe

    trap - 0 1 2
}
