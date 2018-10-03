#!/bin/bash

set -eu

join -t , --header data/actor.csv data/character.csv
