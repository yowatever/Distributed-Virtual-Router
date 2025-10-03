// data-plane/src/main.cpp
#include "data_plane.hpp"
#include <iostream>
#include <csignal>

DataPlane* g_data_plane = nullptr;

void signal_handler(int signum) {
    std::cout << "\nReceived signal " << signum << ", shutting down..." << std::endl;
    if (g_data_plane) {
        g_data_plane->stop();
    }
}

int main() {
    std::signal(SIGINT, signal_handler);
    
    std::cout << "🚀 Starting DVR Data Plane..." << std::endl;
    
    g_data_plane = new DataPlane();
    
    if (!g_data_plane->initialize()) {
        std::cerr << "Failed to initialize data plane" << std::endl;
        return 1;
    }
    
    g_data_plane->start();
    
    std::cout << "Data plane running. Press Ctrl+C to stop." << std::endl;
    
    // Keep main thread alive
    while (true) {
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }
    
    delete g_data_plane;
    return 0;
}
