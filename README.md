# Distributed Virtual Router

A high-performance distributed virtual router implementation with separate control and data planes.

## 🚀 Features

- **Distributed Architecture** - Scalable control and data plane separation
- **Dynamic Routing** - Real-time route computation and distribution  
- **High Performance** - Optimized packet forwarding engine
- **Modular Design** - Pluggable components for flexibility

## Architecture| Component        | Language | Responsibility          |
|------------------|----------|-------------------------|
| **Control Plane** | Python   | Route management & computation |
| **Data Plane**    | C++      | High-speed packet forwarding |


##  Project Structure
dvr-project/
├── control-plane/ # Routing logic & management
│ ├── control_plane.py
│ └── requirements.txt
├── data-plane/ # Packet forwarding engine
│ ├── src/
│ ├── include/
│ └── CMakeLists.txt
└── README.md

text

## Quick Start

```bash
git clone https://github.com/yowatever/Distributed-Virtual-Router
cd dvr-project

# Build data plane
cd data-plane && mkdir build && cd build
cmake .. && make

# Run control plane  
cd ../../control-plane
python control_plane.py
📋 Requirements
C++17 compiler (GCC/Clang)

CMake 3.10+

Python 3.8+

Linux environment
