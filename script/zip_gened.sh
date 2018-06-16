#!/bin/bash

set -eu

function main() {
  local -r ACTOR="$1"
  : $ACTOR

  cp -r target/$ACTOR/ dist/
  cp target/README.html dist/$ACTOR/
  ( cd dist/ && zip -r $ACTOR.zip $ACTOR/ )
}

main "$@"
