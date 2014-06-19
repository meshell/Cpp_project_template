#! /bin/bash
WORKSPACE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${WORKSPACE_DIR}
make prepare
make clean
make unittests
make specs
make igloo-tests
make features
make doc

