# Hugging Face Space — Docker + NVIDIA GPU (T4/L4/A10G…). ORT GPU wheels bundle CUDA libs; base image supplies driver ABI.
# CPU-only local builds: use `docker build` with `--build-arg` or see README on facefusion.io for CPU images.
FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
	PIP_NO_CACHE_DIR=1 \
	PYTHONUNBUFFERED=1 \
	NVIDIA_VISIBLE_DEVICES=all \
	NVIDIA_DRIVER_CAPABILITIES=compute,utility

RUN apt-get update && apt-get install -y --no-install-recommends \
	software-properties-common \
	ca-certificates \
	curl \
	ffmpeg \
	libglib2.0-0 \
	libgl1 \
	libgomp1 \
	&& add-apt-repository -y ppa:deadsnakes/ppa \
	&& apt-get update && apt-get install -y --no-install-recommends \
	python3.12 \
	python3.12-venv \
	&& curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12 \
	&& update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1 \
	&& update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 \
	&& python -m pip install --no-cache-dir -U pip setuptools wheel \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

RUN python install.py --onnxruntime cuda --skip-conda

ENV FACEFUSION_GRADIO_HOST=0.0.0.0
EXPOSE 7860

CMD ["python", "facefusion.py", "run"]
