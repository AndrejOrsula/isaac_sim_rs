### Isaac Sim image <https://catalog.ngc.nvidia.com/orgs/nvidia/containers/isaac-sim>
ARG ISAAC_SIM_IMAGE_NAME="nvcr.io/nvidia/isaac-sim"
ARG ISAAC_SIM_IMAGE_TAG="2023.1.1"

### Base image <https://hub.docker.com/_/ubuntu>
ARG BASE_IMAGE_NAME="ubuntu"
ARG BASE_IMAGE_TAG="jammy"

FROM ${ISAAC_SIM_IMAGE_NAME}:${ISAAC_SIM_IMAGE_TAG} AS isaac_sim
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG} AS base

### Use bash as the default shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

### Create a barebones entrypoint that is conditionally updated throughout the Dockerfile
RUN echo "#!/usr/bin/env bash" >> /entrypoint.bash && \
    chmod +x /entrypoint.bash

### Copy Isaac Sim into the base image
ARG ISAAC_SIM_PATH="/root/isaac_sim"
ARG CARB_APP_PATH="${ISAAC_SIM_PATH}/kit"
COPY --from=isaac_sim /isaac-sim "${ISAAC_SIM_PATH}"
COPY --from=isaac_sim /root/.nvidia-omniverse/config /root/.nvidia-omniverse/config
COPY --from=isaac_sim /etc/vulkan/icd.d/nvidia_icd.json /etc/vulkan/icd.d/nvidia_icd.json
RUN ISAAC_SIM_VERSION="$(cut -d'-' -f1 < "${ISAAC_SIM_PATH}/VERSION")" && \
    echo -e "\n# Isaac Sim ${ISAAC_SIM_VERSION}" >> /entrypoint.bash && \
    echo "export ISAAC_SIM_VERSION=\"${ISAAC_SIM_VERSION}\"" >> /entrypoint.bash && \
    echo "export ISAAC_SIM_PATH=\"${ISAAC_SIM_PATH}\"" >> /entrypoint.bash && \
    echo "export CARB_APP_PATH=\"${CARB_APP_PATH}\"" >> /entrypoint.bash && \
    echo "export OMNI_SERVER=\"http://omniverse-content-production.s3-us-west-2.amazonaws.com/Assets/Isaac/${ISAAC_SIM_VERSION}\"" >> /entrypoint.bash && \
    echo "export PYTHONEXE=\"$(which python3)\"" >> /entrypoint.bash && \
    echo "export OMNI_KIT_ALLOW_ROOT=\"1\"" >> /entrypoint.bash && \
    echo "# source \"${CARB_APP_PATH}/setup_python_env.sh\" --" >> /entrypoint.bash && \
    echo "# source \"${ISAAC_SIM_PATH}/setup_python_env.sh\" --" >> /entrypoint.bash

### Redownload Carbonite
#   Reason: Isaac Sim 2023.1.X Docker image seems to have some issues with symbolic links (or something) and it causes problems with linking OpenUSD libraries
ARG CARB_APP_REDOWNLOAD=true
ARG CARB_APP_REDOWNLOAD_VERSION="105.1.2"
ARG CARB_APP_REDOWNLOAD_BUILD_HASH="release.133510.b82c1e1e"
ARG CARB_APP_REDOWNLOAD_URL="https://d4i3qtqj3r0z5.cloudfront.net/kit-sdk%40${CARB_APP_REDOWNLOAD_VERSION}%2B${CARB_APP_REDOWNLOAD_BUILD_HASH}.tc.linux-x86_64.release.7z"
RUN if [[ "${CARB_APP_REDOWNLOAD,,}" = true ]]; then \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    ca-certificates \
    curl \
    p7zip-full && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf "${CARB_APP_PATH}" && \
    CARB_APP_DL_PATH="/tmp/kit-sdk-${CARB_APP_REDOWNLOAD_VERSION}+${CARB_APP_REDOWNLOAD_BUILD_HASH}.tc.linux-x86_64.release.7z" && \
    curl --proto "=https" --tlsv1.2 -sSfL "${CARB_APP_REDOWNLOAD_URL}" -o "${CARB_APP_DL_PATH}" && \
    7z x "${CARB_APP_DL_PATH}" -o"${CARB_APP_PATH}" && \
    rm "${CARB_APP_DL_PATH}" ; \
    fi

### Install Rust
ARG RUST_VERSION="1.74"
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    ca-certificates \
    curl && \
    rm -rf /var/lib/apt/lists/* && \
    curl --proto "=https" --tlsv1.2 -sSfL "https://sh.rustup.rs" | sh -s -- --no-modify-path -y --default-toolchain "${RUST_VERSION}" --profile default && \
    echo -e "\n# Rust ${RUST_VERSION}" >> /entrypoint.bash && \
    echo "source \"${HOME}/.cargo/env\" --" >> /entrypoint.bash && \
    echo "export CARGO_TARGET_DIR=\"${HOME}/ws_target\"" >> /entrypoint.bash && \
    echo "export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_RUSTFLAGS=\"-Clink-arg=-fuse-ld=mold -Ctarget-cpu=native\"" >> /entrypoint.bash

### Finalize the entrypoint and source it in the ~/.bashrc
# hadolint ignore=SC2016
RUN echo -e "\n# Execute the command" >> /entrypoint.bash && \
    echo -en 'exec "${@}"\n' >> /entrypoint.bash && \
    echo -e "\n# Source the entrypoint" >> "${HOME}/.bashrc" && \
    echo -en "source /entrypoint.bash --\n" >> "${HOME}/.bashrc"
ENTRYPOINT ["/entrypoint.bash"]

### Configure the workspace
ARG WORKSPACE="/root/ws"
ENV WORKSPACE="${WORKSPACE}"
WORKDIR ${WORKSPACE}

### Install dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    clang \
    cmake \
    libarchive-dev \
    libgl-dev \
    libglu-dev \
    libilmbase-dev \
    libssl-dev \
    libx11-dev \
    libxt-dev \
    mold \
    nvidia-cuda-dev \
    pkg-config \
    pybind11-dev \
    python3-dev && \
    rm -rf /var/lib/apt/lists/*

### Copy the source
COPY . "${WORKSPACE}"

### Build the project
RUN source /entrypoint.bash -- && \
    cargo build --release --all-targets

### Set the default command
CMD ["bash"]
