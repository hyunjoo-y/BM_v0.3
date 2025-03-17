#include "ICECandidatesAdapter.h"
#include "STUNInterfaces/NATTraversalAdapter.hpp"
#include <sstream>

const uint32_t HOST_TYPE_PREFERENCE = 126;
const uint32_t SRFLX_TYPE_PREFERENCE = 100;
const uint32_t PRFLX_TYPE_PREFERENCE = 110;
const uint32_t RELAY_TYPE_PREFERENCE = 0;

const uint32_t LOCAL_PREFERENCE_TCP = 32768; // TCP 후보에 대한 최대 선호도
const uint32_t LOCAL_PREFERENCE_UDP = 65535;

extern "C"
{
    uint32_t
    ICECandidatesAdapter::calculatePriority(uint32_t typePreference, uint32_t localPreference, uint32_t componentId)
    {
        return (typePreference << 24) | (localPreference << 8) | (256 - componentId);
    }

    void ICECandidatesAdapter::gatherCandidates()
    {
        // Create NATTraversalAdapter instance to perform STUN operation
        NATTraversalAdapter natTraversalAdapter(stunServer_, stunPort_);
        natTraversalAdapter.performSTUNOperation();

        // Get local host addresses
        // auto networkInterfaces = createNetworkInterfaces();
        // std::vector<std::tuple<std::string, uint16_t, std::string>> hostAddresses = networkInterfaces->getLocalIPAddresses();

        // Add gathered ICE candidates
        // for (const auto& addr : hostAddresses) {
        // uint32_t priority = calculatePriority(HOST_TYPE_PREFERENCE, 65535, 1);
        // addICECandidate("host", std::get<0>(addr), std::get<1>(addr), std::get<2>(addr), priority);
        // }

        // Get UDP and TCP addresses from NATTraversalAdapter
        std::vector<std::pair<std::string, uint16_t>> udpAddresses = natTraversalAdapter.getUDPIPAddresses();
        std::vector<std::pair<std::string, uint16_t>> tcpAddresses = natTraversalAdapter.getTCPIPAddresses();

        // Add server reflexive ICE candidates with highest priority
        for (const auto &addr : udpAddresses)
        {
            uint32_t priority = calculatePriority(SRFLX_TYPE_PREFERENCE, LOCAL_PREFERENCE_TCP, 1);
            addICECandidate("srflx", addr.first, addr.second, "UDP", priority); // 가장 높은 우선순위로 추가
        }

        for (const auto &addr : tcpAddresses)
        {
            uint32_t priority = calculatePriority(SRFLX_TYPE_PREFERENCE, LOCAL_PREFERENCE_UDP, 1);
            addICECandidate("srflx", addr.first, addr.second, "TCP", priority); // 가장 높은 우선순위로 추가
        }
        sortCandidatesByPriority();
    }

    std::vector<IceCandidate> ICECandidatesAdapter::getICECandidates()
    {
        return iceCandidates_; // const 제거로 인해 가능
    }

    void ICECandidatesAdapter::sortCandidatesByPriority()
    {
        std::sort(iceCandidates_.begin(), iceCandidates_.end(), [](const IceCandidate &a, const IceCandidate &b)
                  {
                      return a.priority > b.priority; // 내림차순 정렬
                  });
    }

    void ICECandidatesAdapter::addICECandidate(const std::string &type, const std::string &address, uint16_t port, const std::string &protocol, int priority)
    {
        iceCandidates_.emplace_back(type, address, port, protocol, priority);
    }

    extern "C"
    {
        ICECandidatesAdapter *createICECandidatesAdapter(const char *stunServer, uint16_t stunPort)
        {
            return new ICECandidatesAdapter(std::string(stunServer), stunPort);
        }

        void gatherICECandidates(ICECandidatesAdapter *adapter)
        {
            adapter->gatherCandidates();
        }

        IceCandidate *getICECandidates(ICECandidatesAdapter *adapter, int *count)
        {
            auto candidates = adapter->getICECandidates();
            *count = candidates.size();
            return candidates.empty() ? nullptr : &candidates[0];
        }

        void deleteICECandidatesAdapter(ICECandidatesAdapter *adapter)
        {
            delete adapter;
        }

        const char *getICECandidatesJson(ICECandidatesAdapter *adapter)
        {
            const auto &candidates = adapter->getICECandidates();
            std::string json = "[";
            for (const auto &candidate : candidates)
            {
                if (json.length() > 1)
                    json += ",";
                json += "{\"type\":\"" + candidate.type + "\","
                                                          "\"address\":\"" +
                        candidate.address + "\","
                                            "\"port\":" +
                        std::to_string(candidate.port) + ","
                                                         "\"protocol\":\"" +
                        candidate.protocol + "\","
                                             "\"priority\":" +
                        std::to_string(candidate.priority) + "}";
            }
            json += "]";
            char *dynamic_json = new char[json.length() + 1];
            std::strcpy(dynamic_json, json.c_str());
            return dynamic_json;
        }
    }
}