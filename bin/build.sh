#!/usr/bin/env bash

set -euo pipefail

echo "Building analyzer" 
crystal build src/analyzer.cr --release -o bin/analyzer
