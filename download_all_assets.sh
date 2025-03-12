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

# Execute EMOCA download script if needed
if [ ! -d "./submodules/INFERNO/inferno_apps/EMOCA/assets" ]; then
  echo "Downloading EMOCA assets..."
  (cd ./submodules/INFERNO/inferno_apps/EMOCA/demos && ./download_assets.sh)
else
  echo "EMOCA assets already exist, skipping download."
fi

# Execute FaceReconstruction download script if needed
if [ ! -d "./submodules/INFERNO/inferno_apps/FaceReconstruction/assets" ]; then
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

echo "All downloads completed or skipped as files already exist."