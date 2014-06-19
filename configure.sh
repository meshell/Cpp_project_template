#! /bin/bash
WORKSPACE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${WORKSPACE_DIR}
mkdir -p build
(cd build && cmake "$@" ..)
