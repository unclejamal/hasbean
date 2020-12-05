#!/bin/bash

CHROMEDRIVER_PATH="/home/unclejamal/data/dev/ruby/projects/hasbean"
export PATH="$PATH:$CHROMEDRIVER_PATH"
echo "Path is: $PATH"

ruby lib/main.rb
