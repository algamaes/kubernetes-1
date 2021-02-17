#!/usr/bin/env bash

# Copyright 2020 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script checks that validation files do not mutate their inputs.
# Usage: `hack/verify-non-mutating-validation.sh`.

set -o errexit
set -o nounset
set -o pipefail

KUBE_ROOT=$(dirname "${BASH_SOURCE[0]}")/..
source "${KUBE_ROOT}/hack/lib/init.sh"

mutationOutput=$(find . -name validation.go | xargs egrep -n ' = old' | grep -v '// +k8s:verify-mutation:reason=clone' || true)
foundMutation=$(echo "${mutationOutput}" | wc -c)
# when there's no match, there is a newline
if [ "$foundMutation" -gt "1" ]; then
  echo "${mutationOutput}"
  exit 1
fi

mutationOutput=$(! find . -name validation.go | xargs egrep -n 'old.* = ' | grep -v '// +k8s:verify-mutation:reason=clone' || true)
foundMutation=$(echo "${mutationOutput}" | wc -l)
# when there's no match, there is a newline
if [ "$foundMutation" -gt "1" ]; then
  echo "${mutationOutput}"
  exit 1
fi
