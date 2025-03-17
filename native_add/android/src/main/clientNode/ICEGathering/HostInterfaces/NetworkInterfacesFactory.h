#ifndef NETWORK_INTERFACES_FACTORY_H
#define NETWORK_INTERFACES_FACTORY_H

#include <memory>
#include "NetworkInterfaces.h"


extern "C" __attribute__((visibility("default"))) __attribute__((used))

std::unique_ptr<NetworkInterfaces> createNetworkInterfaces();

#endif // NETWORK_INTERFACES_FACTORY_H
