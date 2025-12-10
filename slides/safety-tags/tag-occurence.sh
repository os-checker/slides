#!/bin/bash

set -eoux pipefail

jq "
.metrics
| .used
| to_entries
| map({ tag: .key, val: .value.occurence })
" ./stat/stat_rfl-X64/kernel.json
