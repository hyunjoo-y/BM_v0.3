// NetworkInterfacesWindows.h

#ifndef NETWORK_INTERFACES_WINDOWS_H
#define NETWORK_INTERFACES_WINDOWS_H

#include "NetworkInterfaces.h" // NetworkInterfaces 클래스가 정의된 헤더 파일

extern "C" __attribute__((visibility("default"))) __attribute__((used))

class NetworkInterfacesWindows : public NetworkInterfaces {
public:
    std::vector<std::tuple<std::string, uint16_t, std::string>> getLocalIPAddresses() const override;
};

#endif // NETWORK_INTERFACES_WINDOWS_H
