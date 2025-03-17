#ifndef NETWORK_INTERFACES_H
#define NETWORK_INTERFACES_H

#include <vector>
#include <string>

extern "C" __attribute__((visibility("default"))) __attribute__((used))

class NetworkInterfaces {
public:
    virtual ~NetworkInterfaces() = default;
    virtual std::vector<std::tuple<std::string, uint16_t, std::string>> getLocalIPAddresses() const = 0;
};

#endif // NETWORK_INTERFACES_H
