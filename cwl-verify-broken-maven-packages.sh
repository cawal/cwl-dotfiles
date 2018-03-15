#!/bin/bash

find  ~/.m2/repository/ -name "*jar" | xargs -L 1 zip -T | grep error | grep invalid
