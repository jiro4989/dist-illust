#!/bin/bash

set -eu

function main() {
  local -r ACTOR="$1"
  : $ACTOR

  cp -r target/$ACTOR/ dist/
  cp target/README.md dist/$ACTOR/README.txt
  ( cd dist/ && zip -r $ACTOR.zip $ACTOR/ )
}

main "$@"
