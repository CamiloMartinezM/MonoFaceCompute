#!/bin/bash

# Source the mamba configuration
source configure_environment.sh

# Create the environment if it doesn't exist
if ! micromamba env list | grep -q "$ENV_NAME"; then
    echo "Creating environment $ENV_NAME..."
    micromamba create -n $ENV_NAME python=3.9 -c conda-forge -c nvidia -c pytorch -y
else
    echo "Environment $ENV_NAME already exists. Skipping creation."
fi

# Activate the environment
eval "$(micromamba shell hook --shell bash)"
micromamba activate $ENV_NAME

# From environment.yaml
pip install --upgrade pip wheel setuptools # Otherwise, use pip~=23.3

pip install albumentations==1.0.3

pip install librosa==0.9.2 loguru==0.6.0 pandas==1.4.2 pyrender==0.1.45 scikit-image==0.19.2 scikit-learn==1.0.2 scikit-video==1.1.11 imgaug==0.4.0 omegaconf~=2.0 pyyaml~=6.0 tqdm==4.66.5 Cython~=0.29 imageio==2.33.1

pip install onnx onnx2torch onnxruntime-gpu lightning torchmetrics hickle==5.0.2 munch==2.5.0 torchfile==0.1.0 compress-pickle==1.2.0 face-alignment==1.3.4 facenet-pytorch==2.5.2 gdown==4.5.1 insightface==0.6.2 transformers==4.22.2 trimesh==3.6.43 wandb~=0.10 face-detection-tflite==0.6.0 timm==0.9.16 opencv-python-headless==4.9.0.80

pip install matplotlib

# There is an issue: https://github.com/mattloper/chumpy/issues/55 caused by
# ImportError: cannot import name 'bool' from 'numpy' (/usr/local/lib/python3.9/site-packages/numpy/__init__.py)
# Workaround 1:
# pip install numpy==1.23 chumpy==0.70
# Workaround 2:
pip install 'numpy<2'
pip install git+https://github.com/mattloper/chumpy # @0.71

# PyTorch3D
pip install git+https://github.com/facebookresearch/pytorch3d.git

# Install MediaPipe (we have to do it separately to avoid conflits with protobuf's version from face-detection-tflite)
pip install mediapipe==0.10.11

# Install ffmpeg separately for similar reasons
micromamba install ffmpeg~=4.3 -y

# Downgrade GCC
micromamba install gcc=12.1.0 -c conda-forge -y

pip install -e ./submodules/INFERNO

#################### Omnidata ####################
# conda install -c conda-forge aria2
# (cd submodules/omnidata && pip install 'omnidata-tools')

#################### DSINE ####################
pip install geffnet
