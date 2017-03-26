#!/usr/bin/env bash

set -euo pipefail

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
project_root="$( cd "$script_dir" && cd .. && pwd )"
output_dir="$project_root/../MiniDOM.github.io"

jazzy \
    --clean \
    --author "MiniDOM" \
    --author_url "https://minidom.github.io" \
    --github_url "https://github.com/MiniDOM/MiniDOM" \
    --root-url "https://minidom.github.io" \
    --module "MiniDOM" \
    --output "$output_dir"

