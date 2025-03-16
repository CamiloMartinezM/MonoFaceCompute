#!/bin/bash

echo "Checking and pulling submodules if needed"

# Download function for Google Drive files
download_gdrive_file() {
    # See https://github.com/zllrunning/face-parsing.PyTorch
    # File: https://drive.google.com/file/d/154JgKpzCPW82qINcVieuPH3fZ2e0P812/view
    local file_id="154JgKpzCPW82qINcVieuPH3fZ2e0P812"
    local destination="submodules/face-parsing.PyTorch/res/cp/"
    local filename="79999_iter.pth"

    # Create destination directory if it doesn't exist
    mkdir -p "$destination"

    # Check if file already exists
    if [ -f "$destination/$filename" ]; then
        echo "File $filename already exists. Skipping download."
        return
    fi

    echo "Downloading file from Google Drive..."

    # Get confirmation token
    CONFIRM=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate "https://drive.google.com/uc?export=download&id=$file_id" -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')

    # Download file
    wget --load-cookies /tmp/cookies.txt "https://drive.google.com/uc?export=download&confirm=$CONFIRM&id=$file_id" -O "$destination/$filename"

    # Clean up cookies
    rm -f /tmp/cookies.txt

    echo "File downloaded to $destination/$filename"
}

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

# Download the file after face-parsing.PyTorch is set up since ./pull_submodules.sh for some reason doesn't
echo "Downloading required model file for face-parsing.PyTorch"
download_gdrive_file

# Avoid the warning /CT/eeg-3d-face/work/micromamba/envs/SPARK-MonoFaceCompute/lib/python3.9/site-packages/pytorch3d/io/obj_io.py:551: UserWarning: Mtl file does not exist: /CT/eeg-3d-face/work/MonoFaceCompute/submodules/INFERNO/assets/FLAME/geometry/template.mtl
# warnings.warn(f"Mtl file does not exist: {f}")
echo "Copying mean_texture.jpg to submodules/INFERNO/assets/FLAME/geometry/"
cp submodules/INFERNO/assets/DECA/data/mean_texture.jpg submodules/INFERNO/assets/FLAME/geometry/

echo "Creating template.mtl file to avoid warning 'Mtl file does not exist: {f}'"
cat <<EOL > submodules/INFERNO/assets/FLAME/geometry/template.mtl
newmtl FaceTexture
map_Kd mean_texture.jpg
EOL

echo "Setup completed successfully!"
