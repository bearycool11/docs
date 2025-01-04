name: BroadcastingRabbitEmulation-CI/CD

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  setup-environment:
    name: Setup Environment
    runs-on: ubuntu-latest

    steps:
      - name: 🐇 Checkout Code
        uses: actions/checkout@v3

      - name: 🐇 Install Dependencies
        run: |
          sudo apt update
          sudo apt install -y docker.io clang python3-pip
          pip3 install blockcypher
  build-protocol:
    name: Build Rabbit Protocol
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]

    steps:
      - name: 🐇 Checkout Code
        uses: actions/checkout@v3

      - name: 🐇 Setup Environment
        run: |
          if [[ $RUNNER_OS == "Windows" ]]; then
            choco install golang docker
          else
            sudo apt install -y docker.io clang
            go mod tidy
      - name: 🐇 Build Rabbit Protocol
        run: clang ./cmd/main.go -o rabbit_protocol_${{ matrix.os }}

      - name: 🐇 Save Build Artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build-artifacts
          path: rabbit_protocol_${{ matrix.os }}

  broadcast-emulation:
    name: Simulate Broadcasting and Emulation
    runs-on: ubuntu-latest
    needs: [setup-environment, build-protocol]

    steps:
      - name: 🐇 Checkout Code
        uses: actions/checkout@v3

      - name: 🐇 Download Build Artifacts
        uses: actions/download-artifact@v3
        with:
          name: build-artifacts

      - name: 🐇 Emulate Broadcasting
        run: |
          echo "Starting Rabbit Protocol Emulation..."
          python3 <<EOF
import time, json
from blockcypher import simple_spend

api_token = "your-api-token"
private_key = "your-private-key"
sender_address = "your-sender-address"
recipient_address = "emulated-recipient-address"
amount_btc = 0.01
message = "Emulating Rabbit Protocol Broadcast"

def broadcast_transaction():
    print(f"Broadcasting from {sender_address} to {recipient_address}...")
    try:
        response = simple_spend(
            from_privkey=private_key,
            to_address=recipient_address,
            to_satoshis=int(amount_btc * 1e8),
            api_key=api_token
        )
        print("Broadcast response:", json.dumps(response, indent=2))
    except Exception as e:
        print("Error during broadcast:", str(e))

broadcast_transaction()
EOF

  validate-results:
    name: Validate Emulation Results
    runs-on: ubuntu-latest
    needs: broadcast-emulation

    steps:
      - name: 🐇 Check Logs
        run: |
          echo "Checking broadcast logs..."
          cat ./broadcast.log || echo "No logs found."
      - name: 🐇 Validate Results
        run: |
          echo "Validating results..."
          if grep -q "Broadcast response" broadcast.log; then
            echo "Broadcast successful!"
          else
            echo "Broadcast failed. Check logs."
name: BroadcastingRabbitEmulation-CI/CD

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  setup-environment:
    name: Setup Environment
    runs-on: ubuntu-latest

    steps:
      - name: 🐇 Checkout Code
        uses: actions/checkout@v3

      - name: 🐇 Install Dependencies
        run: |
          sudo apt update
          sudo apt install -y docker.io clang golang python3-pip
          pip3 install blockcypher
  build-protocol:
    name: Build Rabbit Protocol
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]

    steps:
      - name: 🐇 Checkout Code
        uses: actions/checkout@v3

      - name: 🐇 Setup Environment
        run: |
          if [[ $RUNNER_OS == "Windows" ]]; then
            choco install golang docker
          else
            sudo apt install -y docker.io clang golang
            go mod tidy
      - name: 🐇 Build Rabbit Protocol
        run: |
          echo "Building Rabbit Protocol for ${{ matrix.os }}..."
          go build -o rabbit_protocol_go ./cmd/main.go
          clang ./cmd/main.go -o rabbit_protocol_clang
      - name: 🐇 Save Build Artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build-artifacts
          path: |
            rabbit_protocol_go
            rabbit_protocol_clang
  pesterbot-scan:
    name: Scan and Log Pesterbot Code
    runs-on: ubuntu-latest
    needs: build-protocol

    steps:
      - name: 🐇 Checkout Code
        uses: actions/checkout@v3

      - name: 🐇 Scan for Pesterbot Code
        run: |
          echo "Scanning for rogue 'pesterbot' code..."
          grep -r "pesterbot" ./cmd || echo "No pesterbot found!" > pesterbot_scan.log
      - name: 🐇 Log Pesterbot Issues
        run: |
          echo "Logging pesterbot issues..."
          if grep -q "pesterbot" pesterbot_scan.log; then
            echo "Pesterbot code found!" >> pesterbot_scan.log
          else
            echo "No rogue code found." >> pesterbot_scan.log
      - name: 🐇 Upload Pesterbot Logs
        uses: actions/upload-artifact@v3
        with:
          name: pesterbot-scan-log
          path: pesterbot_scan.log

  broadcast-emulation:
    name: Simulate Broadcasting and Emulation
    runs-on: ubuntu-latest
    needs: [setup-environment, build-protocol, pesterbot-scan]

    steps:
      - name: 🐇 Checkout Code
        uses: actions/checkout@v3

      - name: 🐇 Download Build Artifacts
        uses: actions/download-artifact@v3
        with:
          name: build-artifacts

      - name: 🐇 Emulate Broadcasting
        run: |
          echo "Starting Rabbit Protocol Emulation..."
          python3 <<EOF
import time, json
from blockcypher import simple_spend

api_token = "your-api-token"
private_key = "your-private-key"
sender_address = "your-sender-address"
recipient_address = "emulated-recipient-address"
amount_btc = 0.01
message = "Emulating Rabbit Protocol Broadcast"

def broadcast_transaction():
    print(f"Broadcasting from {sender_address} to {recipient_address}...")
    try:
        response = simple_spend(
            from_privkey=private_key,
            to_address=recipient_address,
            to_satoshis=int(amount_btc * 1e8),
            api_key=api_token
        )
        print("Broadcast response:", json.dumps(response, indent=2))
    except Exception as e:
        print("Error during broadcast:", str(e))

broadcast_transaction()
EOF

  bugzap-validation:
    name: BugZap Validation and Logging
    runs-on: ubuntu-latest
    needs: broadcast-emulation

    steps:
      - name: 🐇 Checkout Code
        uses: actions/checkout@v3

      - name: 🐇 Validate BugZap Logs
        run: |
          echo "Validating and logging BugZap issues..."
          if grep -q "error" broadcast.log; then
            echo "Issues found during broadcasting. Check logs!" >> bugzap.log
          else
            echo "No errors found in broadcast." >> bugzap.log
      - name: 🐇 Upload BugZap Logs
        uses: actions/upload-artifact@v3
        with:
          name: bugzap-log
          path: bugzap.log

  validate-results:
    name: Validate Emulation Results
    runs-on: ubuntu-latest
    needs: bugzap-validation

    steps:
      - name: 🐇 Check Logs
        run: |
          echo "Checking broadcast logs..."
          cat ./broadcast.log || echo "No logs found."
      - name: 🐇 Validate Results
        run: |
          echo "Validating results..."
          if grep -q "Broadcast response" broadcast.log; then
            echo "Broadcast successful!"
          else
            echo "Broadcast failed. Check logs."
 35 changes: 35 additions & 0 deletions35  
.devcontainer/Clangfile.json
Viewed
Original file line number	Diff line number	Diff line change
@@ -0,0 +1,35 @@
{
  "version": "2025",
  "clang_versions": {
    "default": "18.0.0",
    "supported": ["14.0.0", "16.0.0", "18.0.0"]
  },
  "toolchain": {
    "compiler": "clang++",
    "options": {
      "optimization": "-O2",
      "warnings": "-Wall",
      "standard": "c++20"
    }
  },
  "tasks": [
    {
      "name": "Build Project",
      "command": "clang++ -O2 -Wall -std=c++20 main.cpp -o main"
    },
    {
      "name": "Run Tests",
      "command": "./test_suite --run"
    }
  ],
  "dependencies": [
    {
      "name": "libstdc++",
      "version": ">=12.0"
    },
    {
      "name": "glibc",
      "version": ">=2.31"
    }
  ]
}
 133 changes: 133 additions & 0 deletions133  
.devcontainer/Dockerfile
Viewed
Original file line number	Diff line number	Diff line change
@@ -0,0 +1,133 @@
# Use the base image for C++ development
FROM mcr.microsoft.com/devcontainers/cpp:1-debian-12

# Set the CMake version to reinstall if needed
ARG REINSTALL_CMAKE_VERSION_FROM_SOURCE="none"

# Copy the script to reinstall CMake from source
COPY ./reinstall-cmake.sh /tmp/

# Run the script to reinstall CMake if specified
RUN if [ "${REINSTALL_CMAKE_VERSION_FROM_SOURCE}" != "none" ]; then \
        chmod +x /tmp/reinstall-cmake.sh && /tmp/reinstall-cmake.sh ${REINSTALL_CMAKE_VERSION_FROM_SOURCE}; \
    fi \
    && rm -f /tmp/reinstall-cmake.sh

# [Optional] Install additional vcpkg ports
# RUN su vscode -c "${VCPKG_ROOT}/vcpkg install <your-port-name-here>"

# [Optional] Install additional packages
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# Set environment variables for your project
ENV VCPKG_INSTALLATION_ROOT /usr/local/vcpkg
ENV JAVA_HOME_17_X64 /usr/lib/jvm/java-17-openjdk-amd64
# Add more environment variables as needed

# Install necessary software
# Note: Since this is a Debian-based image, we'll use apt for package management
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
       python3-pip \
       nodejs \
       npm \
       openjdk-17-jdk \
       git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Python setup
RUN python3 -m pip install --upgrade pip

# Node.js setup
RUN npm install -g yarn

# Install vcpkg if not already present (assuming it's not in the base image)
RUN git clone https://github.com/microsoft/vcpkg.git $VCPKG_INSTALLATION_ROOT \
    && cd $VCPKG_INSTALLATION_ROOT \
    && ./bootstrap-vcpkg.sh

# Copy project files into the container
COPY . /workspace

# Set the working directory in the container
WORKDIR /workspace

# Default command when container starts
CMD ["bash"]
# Use base images for C++ development
FROM mcr.microsoft.com/devcontainers/cpp:1-ubuntu-24.04 AS ubuntu-base
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2022 AS windows-base

# Ubuntu Environment Setup
FROM ubuntu-base AS ubuntu-setup
ARG REINSTALL_CMAKE_VERSION_FROM_SOURCE="none"
COPY ./reinstall-cmake.sh /tmp/
RUN if [ "${REINSTALL_CMAKE_VERSION_FROM_SOURCE}" != "none" ]; then \
        chmod +x /tmp/reinstall-cmake.sh && /tmp/reinstall-cmake.sh ${REINSTALL_CMAKE_VERSION_FROM_SOURCE}; \
    fi \
    && rm -f /tmp/reinstall-cmake.sh \
    && apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
       python3-pip \
       nodejs \
       npm \
       openjdk-17-jdk \
       gdb \
       valgrind \
       lsof \
       git \
       clang-18 \
       libstdc++-12-dev \
       glibc-source \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Python setup
RUN python3 -m pip install --upgrade pip

# Node.js setup
RUN npm install -g yarn

# Install vcpkg if not already present
ENV VCPKG_INSTALLATION_ROOT=/vcpkg
RUN git clone https://github.com/microsoft/vcpkg.git $VCPKG_INSTALLATION_ROOT \
    && cd $VCPKG_INSTALLATION_ROOT \
    && ./bootstrap-vcpkg.sh

# Copy project files into the container
COPY . /workspace
WORKDIR /workspace
CMD ["bash"]

# Windows Environment Setup
FROM windows-base AS windows-setup
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); \
    choco install -y \
    msys2 \
    cmake \
    clang \
    python \
    nodejs \
    git \
    jdk17 \
    visualstudio2022buildtools --package-parameters "--add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"

# Setup environment variables
ENV PATH="${PATH};C:\msys64\usr\bin;C:\Program Files\Git\cmd"

# Install vcpkg for Windows
RUN git clone https://github.com/microsoft/vcpkg.git C:\vcpkg \
    && cd C:\vcpkg \
    && .\bootstrap-vcpkg.bat

# Copy project files into the container
COPY . C:\workspace
WORKDIR C:\workspace
CMD ["powershell"]

Describe "WSL2" {
    It "WSL status should return zero exit code" {
        "wsl --status" | Should -ReturnZeroExitCode
    }
}
 121 changes: 121 additions & 0 deletions121  
.devcontainer/Rabbit.yml
Viewed
Original file line number	Diff line number	Diff line change
@@ -0,0 +1,121 @@
name: RabbitProtocol-CI/CD

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  rabbit-build:
    name: 🛠️ Build the Rabbit Protocol
    runs-on: ubuntu-latest
    strategy:
      matrix:
        os: [ubuntu-24.04, windows-2025, macos-2025]
    steps:
      - name: 🐇 Checkout Code
        uses: actions/checkout@v3

      - name: 🐇 Setup Go Environment
        uses: actions/setup-go@v4
        with:
          go-version: '1.20'

      - name: 🐇 Install Dependencies
        run: |
          go mod tidy
          go mod vendor
      - name: 🐇 Install Docker and Clang
        run: |
          sudo apt-get update
          sudo apt-get install -y docker.io clang
      - name: 🐇 Build Docker and Clang ISOs
        run: |
          mkdir -p iso_mount
          echo "Building Docker ISO..."
          dd if=/dev/zero of=docker_iso.img bs=1M count=1024
          mkfs.ext4 docker_iso.img
          echo "Building Clang ISO..."
          dd if=/dev/zero of=clang_iso.img bs=1M count=1024
          mkfs.ext4 clang_iso.img
      - name: 🐇 Mount Docker ISO
        run: |
          sudo mount -o loop docker_iso.img iso_mount
          docker build -t docker_iso_tool ./iso_mount
      - name: 🐇 Build with Clang
        run: |
          sudo mount -o loop clang_iso.img iso_mount
          clang --version
          clang ./cmd/main.go -o rabbit_protocol_clang
      - name: 🐇 Save Build Artifacts
        uses: actions/upload-artifact@v3
        with:
          name: rabbit_protocol_${{ matrix.os }}
          path: |
            rabbit_protocol
            rabbit_protocol_clang
            docker_iso.img
            clang_iso.img
  rabbit-run:
    name: 🚀 Run the Rabbit Protocol
    runs-on: ${{ matrix.os }}
    needs: rabbit-build
    steps:
      - name: 🐇 Checkout Code
        uses: actions/checkout@v3

      - name: 🐇 Run Docker and Clang Tests
        run: |
          docker run --rm -v $(pwd):/usr/src/app -w /usr/src/app docker_iso_tool ./rabbit_protocol
          ./rabbit_protocol_clang
  bugzap-pesterbot:
    name: 🐇 BugZap PesterBot
    runs-on: ubuntu-latest
    needs: rabbit-run
    steps:
      - name: 🐇 Scan for Rogue Code
        run: |
          echo "Scanning for pesterbot code..."
          grep -r "pesterbot" ./cmd || echo "No pesterbot found!"
      - name: 🐇 Fix and Remove Bugs
        run: |
          # Example remediation
          sed -i '/pesterbot/d' ./cmd/main.go
  package-toolbelt:
    name: 📦 Package Toolbelt/Kit
    runs-on: ubuntu-latest
    needs: bugzap-pesterbot
    steps:
      - name: 🐇 Download Build Artifacts
        uses: actions/download-artifact@v3
        with:
          name: rabbit_protocol_${{ matrix.os }}
          path: ./builds

      - name: 🐇 Create Container Image
        run: |
          mkdir -p container
          mv ./builds/* ./container/
          docker build -t rabbit_toolbelt:latest ./container
      - name: 🐇 Push Container to Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      - run: |
          docker tag rabbit_toolbelt:latest ghcr.io/${{ github.repository }}/rabbit_toolbelt:latest
          docker push ghcr.io/${{ github.repository }}/rabbit_toolbelt:latest
 226 changes: 226 additions & 0 deletions226  
.devcontainer/Sequoiarabbit.yml
Viewed
Original file line number	Diff line number	Diff line change
@@ -0,0 +1,226 @@
@@ -0,0 +1,251 @@
name: RabbitProtocol-CI/CD
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
jobs:
  rabbit-build:
    name: 🛠️ Build the Rabbit Protocol
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-2025, macos-15]
    steps:
      - name: 🐇 Checkout Code
        uses: actions/checkout@v3
      - name: 🐇 Setup Environment
        run: |
          if [[ "${{ matrix.os }}" == "windows-2025" ]]; then
            choco install -y golang docker-desktop
            powershell Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/microsoft/Windows-Containers/main/helpful_tools/Install-DockerCE/install-docker-ce.ps1" -OutFile install-docker-ce.ps1
            powershell .\install-docker-ce.ps1
          elif [[ "${{ matrix.os }}" == "macos-15" ]]; then
            brew install go docker
          else
            sudo apt-get update
            sudo apt-get install -y docker.io clang
      - name: 🐇 Install Dependencies
        run: |
          go mod tidy
          go mod vendor
      - name: 🐇 Build Docker and Clang ISOs
        if: ${{ matrix.os == 'ubuntu-latest' }}
        run: |
          mkdir -p iso_mount
          dd if=/dev/zero of=docker_iso.img bs=1M count=1024
          mkfs.ext4 docker_iso.img
          dd if=/dev/zero of=clang_iso.img bs=1M count=1024
          mkfs.ext4 clang_iso.img
      - name: 🐇 Build the Rabbit Protocol
        run: |
          if [[ "${{ matrix.os }}" == "windows-2025" ]]; then
            powershell clang ./cmd/main.go -o rabbit_protocol_clang.exe
          else
            clang ./cmd/main.go -o rabbit_protocol_clang
      - name: 🐇 Save Build Artifacts
        uses: actions/upload-artifact@v3
        with:
          name: rabbit_protocol_${{ matrix.os }}
          path: |
            rabbit_protocol_clang
            docker_iso.img
            clang_iso.img
  rabbit-run:
    name: 🚀 Run the Rabbit Protocol
    runs-on: ${{ matrix.os }}
    needs: rabbit-build
    steps:
      - name: 🐇 Checkout Code
        uses: actions/checkout@v3
      - name: 🐇 Run Docker and Clang Tests
        run: |
          if [[ "${{ matrix.os }}" == "windows-2025" ]]; then
            powershell docker run --rm -v $(pwd):/usr/src/app -w /usr/src/app docker_iso_tool rabbit_protocol_clang.exe
          else
            docker run --rm -v $(pwd):/usr/src/app -w /usr/src/app docker_iso_tool ./rabbit_protocol_clang
  bugzap-pesterbot:
    name: 🐇 BugZap PesterBot
    runs-on: ubuntu-latest
    needs: rabbit-run
    steps:
      - name: 🐇 Scan for Rogue Code
        run: |
          echo "Scanning for pesterbot code..."
          grep -r "pesterbot" ./cmd || echo "No pesterbot found!"
      - name: 🐇 Fix and Remove Bugs
        run: |
          sed -i '/pesterbot/d' ./cmd/main.go
  package-toolbelt:
    name: 📦 Package Toolbelt/Kit
    runs-on: ubuntu-latest
    needs: bugzap-pesterbot
    steps:
      - name: 🐇 Download Build Artifacts
        uses: actions/download-artifact@v3
        with:
          name: rabbit_protocol_${{ matrix.os }}
          path: ./builds
      - name: 🐇 Create Container Image
        run: |
          mkdir -p container
          mv ./builds/* ./container/
          docker build -t rabbit_toolbelt:latest ./container
      - name: 🐇 Push Container to Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      - run: |
          docker tag rabbit_toolbelt:latest ghcr.io/${{ github.repository }}/rabbit_toolbelt:latest
          docker push ghcr.io/${{ github.repository }}/rabbit_toolbelt:latest
name: RabbitProtocol-CI/CD
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
jobs:
  rabbit-build:
    name: 🛠️ Build the Rabbit Protocol
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-24.04, windows-2025, macos-15, ios-latest, android-latest]
    steps:
      - name: 🐇 Checkout Code
        uses: actions/checkout@v3
      - name: 🐇 Setup Environment
        run: |
          if [[ "${{ matrix.os }}" == "windows-2025" ]]; then
            choco install -y golang docker-desktop
            powershell Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/microsoft/Windows-Containers/main/helpful_tools/Install-DockerCE/install-docker-ce.ps1" -OutFile install-docker-ce.ps1
            powershell .\install-docker-ce.ps1
          elif [[ "${{ matrix.os }}" == "macos-15" ]]; then
            brew install go docker
          elif [[ "${{ matrix.os }}" == "ios-latest" ]]; then
            gem install cocoapods
            brew install go
          elif [[ "${{ matrix.os }}" == "android-latest" ]]; then
            sudo apt-get install -y android-sdk-go
          else
            sudo apt-get update
            sudo apt-get install -y docker.io clang
      - name: 🐇 Install Dependencies
        run: |
          go mod tidy
          go mod vendor
      - name: 🐇 Build for Specific Platform
        run: |
          if [[ "${{ matrix.os }}" == "ios-latest" ]]; then
            xcodebuild -scheme RabbitProtocol -sdk iphoneos
          elif [[ "${{ matrix.os }}" == "android-latest" ]]; then
            ./gradlew build
          else
            clang ./cmd/main.go -o rabbit_protocol_clang
      - name: 🐇 Save Build Artifacts
        uses: actions/upload-artifact@v3
        with:
          name: rabbit_protocol_${{ matrix.os }}
          path: |
            rabbit_protocol_clang
            ios_build
            android_build
  rabbit-run:
    name: 🚀 Run the Rabbit Protocol
    runs-on: ${{ matrix.os }}
    needs: rabbit-build
    steps:
      - name: 🐇 Checkout Code
        uses: actions/checkout@v3
      - name: 🐇 Run Tests on Specific Platforms
        run: |
          if [[ "${{ matrix.os }}" == "ios-latest" ]]; then
            xcodebuild test -scheme RabbitProtocol -sdk iphoneos
          elif [[ "${{ matrix.os }}" == "android-latest" ]]; then
            ./gradlew test
          else
            docker run --rm -v $(pwd):/usr/src/app -w /usr/src/app docker_iso_tool ./rabbit_protocol_clang
  bugzap-pesterbot:
    name: 🐇 BugZap PesterBot
    runs-on: ubuntu-latest
    needs: rabbit-run
    steps:
      - name: 🐇 Scan for Rogue Code
        run: |
          echo "Scanning for pesterbot code..."
          grep -r "pesterbot" ./cmd || echo "No pesterbot found!"
      - name: 🐇 Fix and Remove Bugs
        run: |
          sed -i '/pesterbot/d' ./cmd/main.go
  azure-pmll:
    name: 🚀 Azure PMLL Integration
    runs-on: ubuntu-latest
    needs: bugzap-pesterbot
    steps:
      - name: 🐇 Set Up Azure PMLL
        run: |
          az login --service-principal -u ${{ secrets.AZURE_CLIENT_ID }} -p ${{ secrets.AZURE_CLIENT_SECRET }} --tenant ${{ secrets.AZURE_TENANT_ID }}
          az pmll create --name RabbitProtocolDB --tier Premium --size 15GB --region eastus
      - name: 🐇 Run Azure PMLL Tests
        run: |
          az pmll test --name RabbitProtocolDB
  package-toolbelt:
    name: 📦 Package Toolbelt/Kit
    runs-on: ubuntu-latest
    needs: azure-pmll
    steps:
      - name: 🐇 Download Build Artifacts
        uses: actions/download-artifact@v3
        with:
          name: rabbit_protocol_${{ matrix.os }}
          path: ./builds
      - name: 🐇 Create Container Image
        run: |
          mkdir -p container
          mv ./builds/* ./container/
          docker build -t rabbit_toolbelt:latest ./container
      - name: 🐇 Push Container to Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      - run: |
          docker tag rabbit_toolbelt:latest ghcr.io/${{ github.repository }}/rabbit_toolbelt:latest
          docker push ghcr.io/${{ github.repository }}/rabbit_toolbelt:latest
0 commit comments
Comments
0
 (0)
 37 changes: 37 additions & 0 deletions37  
.devcontainer/devcontainer.json
Viewed
Original file line number	Diff line number	Diff line change
@@ -0,0 +1,37 @@
{
  "name": "Multi-Platform CI/CD Development",
  "build": {
    "dockerfile": "Dockerfile",
    "context": ".",
    "args": {
      "INSTALL_DEPENDENCIES": "true",
      "REINSTALL_CMAKE_VERSION_FROM_SOURCE": "none"
    }
  },
  "features": {
    "ghcr.io/elanhasson/devcontainer-features/dotnet-aspire-daily:1": {},
    "ghcr.io/nikiforovall/devcontainer-features/dotnet-aspire:1": {},
    "ghcr.io/nikiforovall/devcontainer-features/dotnet-csharpier:1": {}
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-vscode.cmake-tools",
        "ms-dotnettools.csharp",
        "ms-vscode.cpptools",
        "ms-python.python",
        "ms-vscode.powershell",
        "github.vscode-github-actions"
      ]
    }
  },
  "forwardPorts": [55787],
  "postCreateCommand": "gcc --version && cmake . && make && ./run_tests",
  "remoteUser": "root",
  "mounts": [
    "source=/var/run/docker.sock,target=/var/run/docker.sock,type=bind"
  ],
  "workspaceMount": "source=${localWorkspaceFolder},target=/workspace,type=bind,consistency=cached",
  "workspaceFolder": "/workspace/runner-images",
  "initializeCommand": "PORT=$(shuf -i 55000-55999 -n 1) && echo $PORT"
}
 611 changes: 611 additions & 0 deletions611  
.devcontainer/internal.windows-2025.json
Viewed
Large diffs are not rendered by default.

 37 changes: 37 additions & 0 deletions37  
.devcontainer/nternal.ubuntu.24.04.json
Viewed
Original file line number	Diff line number	Diff line change
@@ -0,0 +1,37 @@
{
  "os": {
    "name": "Ubuntu",
    "version": "24.04",
    "base_image": "ubuntu:24.04"
  },
  "packages": {
    "preinstalled": [
      "clang-18",
      "python3.12",
      "nodejs-20",
      "libsdl2-dev",
      "astyle",
      "ccache"
    ],
    "removed": [
      "terraform",
      "mono"
    ]
  },
  "toolchains": [
    {
      "name": "clang",
      "version": "18.0.0",
      "path": "/usr/bin/clang"
    },
    {
      "name": "gcc",
      "version": "14.0.0",
      "path": "/usr/bin/gcc"
    }
  ],
  "compatibility": {
    "preferred_lts": "22.04",
    "notes": "Transitioning to 24.04 image. Recommended to update dependencies."
  }
}
 71 changes: 71 additions & 0 deletions71  
.devcontainer/rabbit_emulation.py
Viewed
Original file line number	Diff line number	Diff line change
@@ -0,0 +1,71 @@
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
Footer
© 2025 GitHub, Inc.
Footer navigation
Terms
Privacy
Security
Status
Docs
