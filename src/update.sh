#!/usr/bin/env bash

# Navigate to the ComfyUI custom nodes directory
cd /comfyui/custom_nodes || { echo "Directory /comfyui/custom_nodes not found"; exit 1; }

# Update the repository and checkout a specific commit
echo "Updating ComfyUI custom nodes..."
git pull
git checkout 22d1241a503461c9ca4f3ad48ddec5ce6e5ee491

# Update system packages and install necessary dependencies
echo "Updating system packages..."
apt update
apt install -y build-essential libpython3.10-dev

# Upgrade Python packages related to ComfyUI
echo "Upgrading Python packages..."
pip install --upgrade opencv-python-headless
pip install --upgrade albucore
pip install insightface==0.7.3
pip install spandrel
pip install rembg[gpu]

# Install GitPython if not already installed
echo "Installing GitPython..."
python3 -m pip install gitpython

# Clone and install ComfyUI Impact Pack
echo "Cloning ComfyUI Impact Pack..."
git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git
git clone https://github.com/ltdrdata/ComfyUI-Impact-Subpack ComfyUI-Impact-Pack/impact_subpack
python3 ComfyUI-Impact-Pack/install.py

# Clone and install ComfyUI ControlNet Aux
echo "Cloning ComfyUI ControlNet Aux..."
git clone https://github.com/Fannovel16/comfyui_controlnet_aux/
pip install -r comfyui_controlnet_aux/requirements.txt

# Clone and install WAS Node Suite for ComfyUI
echo "Cloning WAS Node Suite for ComfyUI..."
git clone https://github.com/WASasquatch/was-node-suite-comfyui/
pip install -r was-node-suite-comfyui/requirements.txt

echo "ComfyUI update completed successfully."