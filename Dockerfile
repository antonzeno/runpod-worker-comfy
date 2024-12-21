# Stage 1: Base image with common dependencies
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04 as base

# Prevents prompts from packages asking for user input during installation
ENV DEBIAN_FRONTEND=noninteractive
# Prefer binary wheels over source distributions for faster pip installations
ENV PIP_PREFER_BINARY=1
# Ensures output from python is printed immediately to the terminal without buffering
ENV PYTHONUNBUFFERED=1 
# Speed up some cmake builds
ENV CMAKE_BUILD_PARALLEL_LEVEL=8

# Install Python, git and other necessary tools
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    git \
    wget \
    libgl1 \
    && ln -sf /usr/bin/python3.10 /usr/bin/python \
    && ln -sf /usr/bin/pip3 /usr/bin/pip

# Clean up to reduce image size
RUN apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install comfy-cli
RUN pip install comfy-cli

# Install ComfyUI
RUN /usr/bin/yes | comfy --workspace /comfyui install --cuda-version 11.8 --nvidia --version 0.2.7

# Change working directory to ComfyUI
WORKDIR /comfyui

# Install runpod
RUN pip install runpod requests

# Support for the network volume
ADD src/extra_model_paths.yaml ./

# Go back to the root
WORKDIR /

# Add scripts and fix line endings
ADD src/start.sh src/restore_snapshot.sh src/rp_handler.py test_input.json ./
RUN sed -i 's/\r$//' /start.sh /restore_snapshot.sh && \
    chmod +x /start.sh /restore_snapshot.sh

# Optionally copy the snapshot file
ADD *snapshot*.json /

# Restore the snapshot to install custom nodes
RUN /restore_snapshot.sh

# Stage 2: Download models
FROM base as downloader

ENV HUGGINGFACE_ACCESS_TOKEN=""

# Change working directory to ComfyUI
WORKDIR /comfyui

# Create necessary directories including custom_models
RUN mkdir -p models/checkpoints models/vae models/clip models/loras models/unet models/loras custom_nodes 

# Custom nodes
RUN git clone https://github.com/bash-j/mikey_nodes.git custom_nodes/mikey_nodes

# Copy the download script from src
COPY src/download_models.sh /download_models.sh
RUN chmod +x /download_models.sh

# Execute the download script
RUN /download_models.sh

# Stage 3: Final image
FROM base as final

# Copy models directory structure
COPY --from=downloader /comfyui/models /comfyui/models
COPY --from=downloader /comfyui/custom_nodes /comfyui/custom_nodes

# Copy the update script from src
COPY src/update.sh /update.sh
RUN chmod +x /update.sh

# Modify start.sh to run download script first
RUN sed -i '1i /download_models.sh' /start.sh

# Optionally run the update script (uncomment if you want to run it during build)
# RUN /update.sh

CMD ["/start.sh"]