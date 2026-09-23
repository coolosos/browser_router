#!/usr/bin/env bash
set -e

rm -rf coverage
flutter test --coverage
lcov --summary coverage/lcov.info
lcov --list coverage/lcov.info
