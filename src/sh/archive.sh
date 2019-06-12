#!/bin/bash

set -eu

readonly ACTOR_NAME=$1

mkdir -p tmp/
rm -rf tmp/$ACTOR_NAME || true
cp -r resources/$ACTOR_NAME tmp/
cp docs/LICENSE.html tmp/$ACTOR_NAME/

( cd tmp && zip -r $ACTOR_NAME{.zip,} ) >/dev/null

mv tmp/$ACTOR_NAME.zip dist/
