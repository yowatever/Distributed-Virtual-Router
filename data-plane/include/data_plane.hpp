// data-plane/include/data_plane.hpp
#pragma once

#include <iostream>
#include <string>
#include <thread>
#include <atomic>
#include <unordered_map>
#include <vector>
#include <mutex>

class DataPlane {
private:
    std::atomic<bool> running;
    std::thread worker_thread;
    
    struct Route {
        std::string destination;
        std::string next_hop;
        int metric;
    };
    
    std::unordered_map<std::string, Route> routing_table;
    std::mutex table_mutex;
    
    std::atomic<uint64_t> packets_processed;
    std::atomic<uint64_t> routes_updated;

public:
    DataPlane();
    ~DataPlane();
    
    bool initialize();
    void start();
    void stop();
    
    void add_route(const std::string& destination, const std::string& next_hop, int metric = 100);
    void delete_route(const std::string& destination);
    std::vector<Route> get_routes() const;
    void show_stats() const;

private:
    void worker_loop();
};
