#!/bin/bash

q -d , -H  "select lower(solresol) from ${HOME}/bin/data-sources/solresol-gosteen.csv where english like '%${1}%' limit 1" \
    | sed "s/do/c /g;
           s/re/d /g; 
           s/mi/e /g; 
           s/fa/f /g; 
           s/sol/g /g; 
           s/la/a /g; 
           s/si/b /g; 
        " \
    | play-notes-from-stdin.sh
