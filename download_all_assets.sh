#!/bin/bash

# Function to check if a file exists and move it from root if needed
check_and_move_file() {
    local destination="$1"
    local filename=$(basename "$destination")

    # Check if the file already exists in the destination
    if [ -f "$destination" ]; then
        echo "File $destination already exists, skipping download."
        return 0
    fi

    # Check if the file exists in the root directory
    if [ -f "./$filename" ]; then
        echo "Found $filename in root directory, moving to $destination"
        mkdir -p "$(dirname "$destination")"
        mv "./$filename" "$destination"
        return 0
    fi

    # File doesn't exist, need to download
    return 1
}

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

# Execute EMOCA download script if needed
if [ ! -d "./submodules/INFERNO/assets/EMOCA" ] || [ -z "$(ls -A ./submodules/INFERNO/assets/EMOCA)" ]; then
    echo "Downloading EMOCA assets..."
    (cd ./submodules/INFERNO/inferno_apps/EMOCA/demos && ./download_assets.sh)
else
    echo "EMOCA assets already exist, skipping download."
fi

# Execute FaceReconstruction download script if needed
if [ ! -d "./submodules/INFERNO/assets/FaceReconstruction" ] || [ -z "$(ls -A ./submodules/INFERNO/assets/FaceReconstruction)" ]; then
    echo "Downloading FaceReconstruction assets..."
    (cd ./submodules/INFERNO/inferno_apps/FaceReconstruction && ./download_assets.sh)
else
    echo "FaceReconstruction assets already exist, skipping download."
fi

# Download pre-trained segmentation model if needed
SEGMENTATION_MODEL="./submodules/face-parsing.PyTorch/res/cp/79999_iter.pth"
if ! check_and_move_file "$SEGMENTATION_MODEL"; then
    echo "Downloading pre-trained segmentation model..."
    mkdir -p "$(dirname "$SEGMENTATION_MODEL")"
    gdown 154JgKpzCPW82qINcVieuPH3fZ2e0P812 -O "$SEGMENTATION_MODEL"
fi

# Download pre-trained MODNet model if needed
MODNET_MODEL="./submodules/MODNet/pretrained/modnet_webcam_portrait_matting.ckpt"
if ! check_and_move_file "$MODNET_MODEL"; then
    echo "Downloading pre-trained MODNet model..."
    mkdir -p "$(dirname "$MODNET_MODEL")"
    gdown 1Nf1ZxeJZJL8Qx9KadcYYyEmmlKhTADxX -O "$MODNET_MODEL"
fi

# Download pre-trained SMIRK model if needed
SMIRK_MODEL="./submodules/SMIRK/pretrained_models/SMIRK_em1.pt"
if ! check_and_move_file "$SMIRK_MODEL"; then
    echo "Downloading pre-trained SMIRK model..."
    mkdir -p "$(dirname "$SMIRK_MODEL")"
    gdown 1T65uEd9dVLHgVw5KiUYL66NUee-MCzoE -O "$SMIRK_MODEL"
fi

# Commented out Omnidata download for consistency with original script
# if ! check_and_move_file "submodules/omnidata/pretrained_models/omnidata_dpt_normal_v2.ckpt"; then
#   echo "Downloading pre-trained Omnidata normal estimation model..."
#   (cd submodules/omnidata && sh omnidata_tools/torch/tools/download_surface_normal_models.sh && mv 'pretrained_models/omnidata_dpt_normal_v2.ckpt?download=1' 'pretrained_models/omnidata_dpt_normal_v2.ckpt')
# fi

# Download pre-trained DSINE normal estimation model if needed
DSINE_MODEL="./submodules/DSINE/projects/dsine/checkpoints/exp001_cvpr2024/dsine.pt"
if ! check_and_move_file "$DSINE_MODEL"; then
    echo "Downloading pre-trained DSINE normal estimation model..."
    (cd submodules/DSINE && mkdir -p ./projects/dsine/checkpoints/exp001_cvpr2024 && gdown 1Wyiei4a-lVM6izjTNoBLIC5-Rcy4jnaC -O ./projects/dsine/checkpoints/exp001_cvpr2024/dsine.pt)
fi

# Download the file after face-parsing.PyTorch is set up since ./pull_submodules.sh for some reason doesn't
echo "Downloading required model file for face-parsing.PyTorch"
download_gdrive_file

# Avoid the warning /CT/eeg-3d-face/work/micromamba/envs/SPARK-MonoFaceCompute/lib/python3.9/site-packages/pytorch3d/io/obj_io.py:551: UserWarning: Mtl file does not exist: /CT/eeg-3d-face/work/MonoFaceCompute/submodules/INFERNO/assets/FLAME/geometry/template.mtl
# warnings.warn(f"Mtl file does not exist: {f}")
if [ ! -f "submodules/INFERNO/assets/FLAME/geometry/mean_texture.jpg" ]; then
    echo "mean_texture.jpg not found in submodules/INFERNO/assets/FLAME/geometry/"
    echo "Copying mean_texture.jpg to submodules/INFERNO/assets/FLAME/geometry/"
    cp submodules/INFERNO/assets/DECA/data/mean_texture.jpg submodules/INFERNO/assets/FLAME/geometry/
else
    echo "mean_texture.jpg already exists in submodules/INFERNO/assets/FLAME/geometry/, skipping copy"
fi

if [ ! -f "submodules/INFERNO/assets/FLAME/geometry/template.mtl" ]; then
    echo "template.mtl not found in submodules/INFERNO/assets/FLAME/geometry/"
    echo "Creating template.mtl file to avoid warning 'Mtl file does not exist: {f}'"
    cat <<EOL >submodules/INFERNO/assets/FLAME/geometry/template.mtl
newmtl FaceTexture
map_Kd mean_texture.jpg
EOL
else
    echo "template.mtl already exists in submodules/INFERNO/assets/FLAME/geometry/, skipping creation"
fi

echo "All downloads completed or skipped as files already exist."
