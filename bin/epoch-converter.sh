#!/bin/bash

EPOCH=$(xclip -o | sed 's/[^0-9]*//g')

HUMAN_READABLE_DATE=$(date -d "@${EPOCH}")

notify-send "Epoch to date: ${EPOCH}" "$HUMAN_READABLE_DATE"
