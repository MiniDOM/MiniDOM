#!/usr/bin/env bash

set -euo pipefail

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
project_root="$( cd "$script_dir" && cd .. && pwd )"

E_BADARGS=85
if [ $# -ne 3 ]; then
    echo "Usage: $(basename $0) command xml-filename metrics-filename"
    exit $E_BADARGS
fi

cmd="$1"
xml_filename="$2"
metrics_filename="$3"

cd "$project_root"
swift run PerformanceTest "$cmd" "$xml_filename" --metrics-filename="$metrics_filename"

