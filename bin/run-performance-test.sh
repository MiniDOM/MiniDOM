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

xml_basename=$(basename "$xml_filename")
timestamp=$(date +%Y-%m-%d_%H.%M.%S%z)

# We cannot invoke `swift run` from `xctrace` so we have to build first...
cd "$project_root"
swift build

# ...which writes the executable here
executable=".build/debug/PerformanceTest"

cd "$project_root"
xcrun xctrace record \
    --template 'Time Profiler' \
    --output "PerformanceTest [$cmd $xml_basename] $timestamp.trace" \
    --target-stdout - \
    --launch -- \
    "$executable" "$cmd" "$xml_filename" --metrics-filename="$metrics_filename"

