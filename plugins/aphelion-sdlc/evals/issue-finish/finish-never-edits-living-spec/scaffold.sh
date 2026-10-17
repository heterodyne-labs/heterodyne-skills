#!/usr/bin/env bash
# Builds this case's workspace from the shared fixture in ../../_fixtures/.
# Runs only with `claude plugin eval --scaffold` (evals/README.md).
set -euo pipefail
# shellcheck source=../../_fixtures/repo.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../_fixtures/repo.sh"
fixture_base
fixture_finish_ready
fixture_warm_openspec
