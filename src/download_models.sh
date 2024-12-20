#!/bin/bash

# Function to check and create symlink or download
setup_model() {
    local src_path="/workspace/ComfyUI$1"
    local dest_path="/comfyui$1"
    local download_url="$2"
    local needs_token="${3:-false}"

    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$dest_path")"

    if [ -f "$src_path" ]; then
        echo "Found existing model at $src_path, creating symlink..."
        ln -sf "$src_path" "$dest_path"
    else
        echo "Downloading model to $src_path..."
        mkdir -p "$(dirname "$src_path")"
        if [ "$needs_token" = true ]; then
            wget --header="Authorization: Bearer ${HUGGINGFACE_ACCESS_TOKEN}" -O "$src_path" "$download_url"
        else
            wget -O "$src_path" "$download_url"
        fi
        # Create symlink to the downloaded file
        ln -sf "$src_path" "$dest_path"
    fi
}

# Create workspace directory structure if it doesn't exist
mkdir -p /workspace/ComfyUI/models/{checkpoints,vae,clip,loras,unet}

# Create ComfyUI directories if they don't exist
mkdir -p /comfyui/models/{checkpoints,vae,clip,loras,unet}

# Setup each model
echo "Setting up models..."

# Flux models (need token)
setup_model "/models/unet/flux1-dev.safetensors" \
    "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1-dev.safetensors" true

setup_model "/models/vae/ae.safetensors" \
    "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/ae.safetensors" true

# CLIP models
setup_model "/models/clip/t5xxl_fp16.safetensors" \
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors"

setup_model "/models/clip/t5xxl_fp8_e4m3fn.safetensors" \
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors"

setup_model "/models/clip/clip_l.safetensors" \
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors"

# LoRA models
setup_model "/models/loras/filmfotos.safetensors" \
    "https://huggingface.co/Shakker-Labs/FilmPortrait/resolve/main/filmfotos.safetensors?download=true"

setup_model "/models/loras/flux_realism_lora.safetensors" \
    "https://huggingface.co/comfyanonymous/flux_RealismLora_converted_comfyui/resolve/main/flux_realism_lora.safetensors"

echo "All models are set up!" 