#ifndef NETWORK_INTERFACES_UNIX_H
#define NETWORK_INTERFACES_UNIX_H

#include "NetworkInterfaces.h"
#include <vector>
#include <string>


extern "C" __attribute__((visibility("default"))) __attribute__((used))

class NetworkInterfacesUnix : public NetworkInterfaces {
public:
    std::vector<std::tuple<std::string, uint16_t, std::string>> getLocalIPAddresses() const override;
};

#endif // NETWORK_INTERFACES_UNIX_H
