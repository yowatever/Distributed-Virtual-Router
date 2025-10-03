// data-plane/src/data_plane.cpp
#include "data_plane.hpp"
#include <iostream>
#include <iomanip>
#include <chrono>
#include <thread>

DataPlane::DataPlane() 
    : running(false)
    , packets_processed(0)
    , routes_updated(0) {
}

DataPlane::~DataPlane() {
    stop();
}

bool DataPlane::initialize() {
    std::cout << "Initializing Data Plane..." << std::endl;
    
    add_route("10.0.0.0/24", "192.168.1.1", 100);
    add_route("172.16.0.0/16", "192.168.1.2", 200);
    
    std::cout << "Data Plane initialized with " << routing_table.size() << " default routes" << std::endl;
    return true;
}

void DataPlane::start() {
    if (running) return;
    
    running = true;
    worker_thread = std::thread(&DataPlane::worker_loop, this);
    std::cout << "Data Plane started" << std::endl;
}

void DataPlane::stop() {
    if (!running) return;
    
    running = false;
    if (worker_thread.joinable()) {
        worker_thread.join();
    }
    std::cout << "Data Plane stopped" << std::endl;
}

void DataPlane::add_route(const std::string& destination, const std::string& next_hop, int metric) {
    std::lock_guard<std::mutex> lock(table_mutex);
    
    Route route;
    route.destination = destination;
    route.next_hop = next_hop;
    route.metric = metric;
    
    routing_table[destination] = route;
    routes_updated++;
    
    std::cout << "✓ Added route: " << destination << " -> " << next_hop 
              << " (metric: " << metric << ")" << std::endl;
}

void DataPlane::delete_route(const std::string& destination) {
    std::lock_guard<std::mutex> lock(table_mutex);
    
    auto it = routing_table.find(destination);
    if (it != routing_table.end()) {
        routing_table.erase(it);
        routes_updated++;
        std::cout << "✗ Deleted route: " << destination << std::endl;
    } else {
        std::cout << "! Route not found: " << destination << std::endl;
    }
}

std::vector<DataPlane::Route> DataPlane::get_routes() const {
    std::lock_guard<std::mutex> lock(table_mutex);
    std::vector<Route> routes;
    for (const auto& entry : routing_table) {
        routes.push_back(entry.second);
    }
    return routes;
}

void DataPlane::show_stats() const {
    std::cout << "=== Data Plane Statistics ===" << std::endl;
    std::cout << "Packets processed: " << packets_processed << std::endl;
    std::cout << "Routes updated: " << routes_updated << std::endl;
    std::cout << "Active routes: " << routing_table.size() << std::endl;
}

void DataPlane::worker_loop() {
    int iteration = 0;
    while (running) {
        std::this_thread::sleep_for(std::chrono::seconds(2));
        packets_processed += 5; // Simulate packet processing
        
        if (iteration++ % 5 == 0) {
            std::cout << "Data plane processing packets... (" << packets_processed << " total)" << std::endl;
        }
    }
}
