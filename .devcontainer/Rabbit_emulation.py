import subprocess
import time
import os

# Helper Functions
def run_command(command, description):
    """Run a shell command and log the output."""
    print(f"\n=== {description} ===")
    print(f"Running: {command}")
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True, check=True)
        print(result.stdout)
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(e.stderr)
        raise

def log_step(step):
    """Log a step in the emulation."""
    print(f"\n--- Step: {step} ---")

# Emulation Starts Here
try:
    log_step("Initialize CI/CD Workflow")

    # Step 1: Clone Repository
    repo_url = "https://github.com/bearycool11/RabbitProtocol.git"
    run_command(f"git clone {repo_url} RabbitProtocol", "Clone Repository")

    os.chdir("RabbitProtocol")  # Change to the repo directory

    # Step 2: Install Dependencies
    run_command("go mod tidy && go mod vendor", "Install Dependencies for RabbitProtocol")
    run_command("sudo apt-get install -y docker.io clang", "Install Docker and Clang")

    # Step 3: Build Components
    run_command("clang ./cmd/main.go -o rabbit_protocol_clang", "Build Rabbit Protocol Components")
    run_command("gcc brain.c -o modular_brain_executable", "Build Modular Brain Component")
    run_command("gcc pml_logic_loop.c -o logic_module", "Build Logic Module")

    # Step 4: Run Tests
    run_command("./modular_brain_executable --test", "Run Tests for Modular Brain")
    run_command("./logic_module --run-tests", "Run Tests for Logic Module")
    run_command("docker build -t rabbit_protocol ./docker_context", "Build Docker Image for RabbitProtocol")

    # Step 5: Scan for Rogue Code
    run_command("grep -r 'pesterbot' ./cmd || echo 'No rogue code found'", "Scan for Rogue Code")
    run_command("sed -i '/pesterbot/d' ./cmd/main.go", "Remove Rogue Code")

    # Step 6: Integrate Azure PMLL
    run_command(
        "az login --service-principal --username $AZURE_USER --password $AZURE_PASSWORD --tenant $AZURE_TENANT",
        "Login to Azure"
    )
    run_command(
        "az cosmosdb create --name ModularBrainDB --resource-group ModularBrain --locations regionName=EastUS",
        "Create Azure CosmosDB"
    )

    # Step 7: Package and Deploy
    run_command("docker build -t modular_brain_toolbelt:latest .", "Build Docker Image for Toolbelt")
    run_command("docker push modular_brain_toolbelt:latest", "Push Docker Image to Registry")

    # Step 8: Clean Up
    run_command("docker image prune -f && docker container prune -f", "Clean Up Unused Docker Resources")
    run_command("rm -rf ./builds", "Clean Up Build Artifacts")

    log_step("Workflow Emulation Complete!")

except Exception as e:
    print(f"An error occurred during the emulation: {e}")
 139 changes: 139 additions & 0 deletions139  
.devcontainer/run-runner-image.sh
Viewed
Original file line number	Diff line number	Diff line change
@@ -0,0 +1,139 @@
#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
set -e

CMAKE_VERSION=${1:-"none"}

if [ "${CMAKE_VERSION}" = "none" ]; then
    echo "No CMake version specified, skipping CMake reinstallation"
    exit 0
fi

# Cleanup temporary directory and associated files when exiting the script.
cleanup() {
    EXIT_CODE=$?
    set +e
    if [[ -n "${TMP_DIR}" ]]; then
        echo "Executing cleanup of tmp files"
        rm -Rf "${TMP_DIR}"
    fi
    exit $EXIT_CODE
}
trap cleanup EXIT


echo "Installing CMake..."
apt-get -y purge --auto-remove cmake
mkdir -p /opt/cmake

architecture=$(dpkg --print-architecture)
case "${architecture}" in
    arm64)
        ARCH=aarch64 ;;
    amd64)
        ARCH=x86_64 ;;
    *)
        echo "Unsupported architecture ${architecture}."
        exit 1
        ;;
esac

CMAKE_BINARY_NAME="cmake-${CMAKE_VERSION}-linux-${ARCH}.sh"
CMAKE_CHECKSUM_NAME="cmake-${CMAKE_VERSION}-SHA-256.txt"
TMP_DIR=$(mktemp -d -t cmake-XXXXXXXXXX)

echo "${TMP_DIR}"
cd "${TMP_DIR}"

curl -sSL "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/${CMAKE_BINARY_NAME}" -O
curl -sSL "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/${CMAKE_CHECKSUM_NAME}" -O

sha256sum -c --ignore-missing "${CMAKE_CHECKSUM_NAME}"
sh "${TMP_DIR}/${CMAKE_BINARY_NAME}" --prefix=/opt/cmake --skip-license

ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake
ln -s /opt/cmake/bin/ctest /usr/local/bin/ctest

#!/bin/bash

# Script to build and run Runner Images for Ubuntu 24.04 and Windows Server 2025 debugging
# with Clang setup

# Variables
UBUNTU_IMAGE_NAME="runner-images-ubuntu-24.04"
WINDOWS_IMAGE_NAME="runner-images-windows-2025"
CONTAINER_NAME="runner-images-container"
UBUNTU_DOCKERFILE_PATH="./Dockerfile.ubuntu"  # Adjust if Dockerfile for Ubuntu is in a different location
WINDOWS_DOCKERFILE_PATH="./Dockerfile.windows"  # Adjust if Dockerfile for Windows is in a different location
CONTEXT_DIR="."                # Adjust if the context is a different directory
WORKSPACE_DIR="$(pwd)"         # Current directory as the workspace
UBUNTU_CLANGFILE_PATH="clangfile.ubuntu.json"
WINDOWS_CLANGFILE_PATH="clangfile.windows.json"
LOG_FILE="runner-images-build.log"

# Functions

# Cleanup Function
cleanup() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Cleaning up any existing container with the same name..."
    if docker rm -f ${CONTAINER_NAME} 2>/dev/null; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] Container ${CONTAINER_NAME} successfully removed."
    else
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] No container named ${CONTAINER_NAME} found or removal failed."
    fi
}

# Build Image Function
build_image() {
    local image_name="$1"
    local dockerfile_path="$2"
    local clangfile_path="$3"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Building Docker image: ${image_name}..."
    if docker build -t ${image_name} -f ${dockerfile_path} --build-arg CLANGFILE=${clangfile_path} ${CONTEXT_DIR} | tee -a ${LOG_FILE}; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] Docker image ${image_name} built successfully."
    else
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: Docker image build for ${image_name} failed. Check ${LOG_FILE} for details."
        exit 1
    fi
}

# Run Container Function
run_container() {
    local image_name="$1"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Running Docker container: ${CONTAINER_NAME} for ${image_name}..."
    docker run -it --rm \
        --name ${CONTAINER_NAME} \
        --mount type=bind,source=${WORKSPACE_DIR},target=/workspace \
        --network none \  # Ensures no network access for isolation
        ${image_name}
    if [ $? -eq 0 ]; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] Container ${CONTAINER_NAME} for ${image_name} ran successfully."
    else
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: Failed to run container ${CONTAINER_NAME} for ${image_name}."
        exit 1
    fi
}

# Main Execution Workflow
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Starting Runner Image Setup for Ubuntu 24.04 and Windows Server 2025 with Clang configurations..."

# Clean up any previous runs
cleanup

# Build the Ubuntu Docker image with Clang configuration
build_image ${UBUNTU_IMAGE_NAME} ${UBUNTU_DOCKERFILE_PATH} ${UBUNTU_CLANGFILE_PATH}

# Run the Ubuntu container
run_container ${UBUNTU_IMAGE_NAME}

# Build the Windows Docker image with Clang configuration
build_image ${WINDOWS_IMAGE_NAME} ${WINDOWS_DOCKERFILE_PATH} ${WINDOWS_CLANGFILE_PATH}

# Run the Windows container
run_container ${WINDOWS_IMAGE_NAME}

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Runner Image Setup for both Ubuntu 24.04 and Windows Server 2025 with Clang configurations completed.
 3 changes: 2 additions & 1 deletion3  
images/ubuntu/scripts/build/install-azure-devops-cli.sh
Viewed
Original file line number	Diff line number	Diff line change
@@ -1,7 +1,8 @@
#!/bin/bash -e
################################################################################
##  File:  install-azure-devops-cli.sh
##  Desc:  Install Azure DevOps CLI (az devops)
##  Desc:
  Install Azure DevOps CLI (az devops)
################################################################################

# Source the helpers for use with the script
