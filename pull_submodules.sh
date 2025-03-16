#!/bin/bash

echo "Checking and pulling submodules if needed"

# for repo in INFERNO face-parsing.PyTorch MODNet SMIRK DSINE omnidata
for repo in INFERNO face-parsing.PyTorch MODNet SMIRK DSINE; do
    echo "Processing $repo"

    # Check if submodule is already initialized
    if [ ! -f "submodules/$repo/.git" ]; then
        # Pull non-recursively
        git submodule update --init submodules/$repo &&
            # Apply the patch
            cd submodules/$repo
        patch -p1 <../../submodules/$repo.patch
        cd ../../
        # Pull recursively
        git submodule update --recursive submodules/$repo
    else
        echo "Submodule $repo is already initialized. Skipping pull and patch."
    fi
done