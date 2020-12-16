#!/bin/bash

CHROMEDRIVER_PATH="/home/unclejamal/data/dev/ruby/projects/hasbean"
export PATH="$PATH:$CHROMEDRIVER_PATH"
echo "Path is: $PATH"

export APP_MODE="TEST"
export RURL="$1"

ruby main.rb
