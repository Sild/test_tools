#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m'

target_addr="${1}"

if [ "${target_addr}" = "" ]; then
    echo "Usage: ./run.sh {http://ip_addr:port}"
    exit 1
fi

user_dir="$(pwd)"
root_dir="$(git rev-parse --show-toplevel)"

cd "${root_dir}" || (echo "Fail to change dir" && exit 1)

# git clone https://github.com/wg/wrk && cd wrk && make && cp wrk /usr/local/bin
cd "$(dirname "$(realpath -- "$0")")" || (echo "Fail to change dir" && exit 1)

echo "warming up..."
wrk -c 100 -d 5 -t 5 --latency --timeout=1s -s multiple-url-path.lua "${target_addr}" >/dev/null 2>&1

run_wrk () {
    conns=$1
    threads=$2
    echo ""
    echo -e "${GREEN}running wrk with ${conns} connections, ${threads} threads:${NC}"
    wrk -c ${conns} -d 5 -t ${threads} --latency --timeout=1s -s multiple-url-path.lua "${target_addr}" 2>&1
}

run_wrk 600 16
run_wrk 1200 32
run_wrk 1500 32

# shutdown server if required
if ${run_server}; then
    kill -SIGINT ${indexerd_pid}
    cd "${user_dir}" || (echo "fail to go back in your dir" && exit 0)
    echo "logs can be found here: ${log_file}"
fi
