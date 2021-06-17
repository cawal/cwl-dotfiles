#"/bin/bash

# checks if a program will run if called
function is_installed(){
    if command -v $1 &> /dev/null; then
        return 0
    else
        return 1
    fi
}
