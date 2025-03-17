#include "NetworkInterfacesFactory.h"
#include "NetworkInterfacesUnix.h"
#include "NetworkInterfacesWindows.h"
#include <memory>

extern "C" __attribute__((visibility("default"))) __attribute__((used))

std::unique_ptr<NetworkInterfaces> createNetworkInterfaces() {
#ifdef _WIN32
    return std::unique_ptr<NetworkInterfaces>(new NetworkInterfacesWindows());
#else
    return std::unique_ptr<NetworkInterfaces>(new NetworkInterfacesUnix());
#endif
}
