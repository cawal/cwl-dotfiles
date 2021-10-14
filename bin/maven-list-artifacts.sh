#!/bin/bash

mvn -q -Dexec.executable='echo' -Dexec.args='${project.groupId}:${project.artifactId}:${project.version} (${project.packaging})' exec:exec
