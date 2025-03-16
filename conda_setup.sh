# Source the mamba configuration
source configure_environment.sh

ENV_NAME=MonoFaceCompute-original

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

echo "Installing dependencies"
micromamba env update -n $ENV_NAME --file ./conda_environment.yaml -y

# PyTorch3D
pip install git+https://github.com/facebookresearch/pytorch3d.git@v0.6.2
# Install MediaPipe (we have to do it separately to avoid conflits with protobuf's version from face-detection-tflite)
pip install mediapipe==0.10.11
# Install ffmpeg separately for similar reasons
micromamba install ffmpeg~=4.3 -y
# Downgrade GCC
micromamba install gcc=12.1.0 -c conda-forge -y

pip install -e ./submodules/INFERNO

#################### Omnidata ####################
# micromamba install -c conda-forge aria2
# (cd submodules/omnidata && pip install 'omnidata-tools')

#################### DSINE ####################
pip install geffnet