#! /bin/bash
WORKSPACE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${WORKSPACE_DIR}
cmake --build build --target external_dependencies "$@"
cmake --build build --target all "$@"

