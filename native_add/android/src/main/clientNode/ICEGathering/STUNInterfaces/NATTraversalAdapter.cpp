#include "NATTraversalAdapter.hpp"
#include <iostream>
#include <vector>
#include <cstring>
#include <cstdlib>
#include <sys/socket.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <netdb.h>

extern "C"
{
    // Constructor
    NATTraversalAdapter::NATTraversalAdapter(const std::string &server, uint16_t port) : server_(server), port_(port), magicCookie_(0x2112A442) {}

    // Destructor
    NATTraversalAdapter::~NATTraversalAdapter() {}

    // Perform STUN operations (UDP and TCP)
    void NATTraversalAdapter::performSTUNOperation()
    {
        sendUDPRequest();
        sendTCPRequest();
    }

    std::vector<std::pair<std::string, uint16_t>> NATTraversalAdapter::getUDPIPAddresses() const
    {
        return udpIPAddresses_;
    }

    std::vector<std::pair<std::string, uint16_t>> NATTraversalAdapter::getTCPIPAddresses() const
    {
        return tcpIPAddresses_;
    }

    // Create a STUN binding request
    void NATTraversalAdapter::createSTUNBindingRequest(std::vector<unsigned char> &buffer)
    {
        buffer.clear();
        buffer.resize(sizeof(STUNHeader));
        STUNHeader *header = reinterpret_cast<STUNHeader *>(buffer.data());
        header->type = htons(STUN_BINDING_REQUEST);
        header->length = 0;
        header->magic_cookie = htonl(STUN_MAGIC_COOKIE);
        for (auto &tid : header->tid)
        {
            tid = rand();
        }
    }

    void NATTraversalAdapter::extractSTUNMappedAddress(const std::vector<unsigned char> &buffer, size_t length, bool isUDP)
    {
        size_t pos = sizeof(STUNHeader);
        while (pos + sizeof(STUNAttributeHeader) <= length)
        {
            const STUNAttributeHeader *attr = reinterpret_cast<const STUNAttributeHeader *>(buffer.data() + pos);
            if (attr->type == htons(STUN_MAPPED_ADDRESS) || attr->type == htons(STUN_XOR_MAPPED_ADDRESS))
            {
                const STUNMappedAddressAttribute *mapped = reinterpret_cast<const STUNMappedAddressAttribute *>(attr + 1);
                uint16_t actual_port = ntohs(mapped->port) ^ (STUN_MAGIC_COOKIE >> 16);
                struct in_addr actual_ip = {mapped->ip_addr.s_addr ^ htonl(STUN_MAGIC_COOKIE)};
                std::string ip_str = inet_ntoa(actual_ip);
                isUDP ? addUDPIPAddress(ip_str, actual_port) : addTCPIPAddress(ip_str, actual_port);
            }
            pos += sizeof(STUNAttributeHeader) + ntohs(attr->length);
        }
    }

    // Extract STUN mapped address from the response
    void NATTraversalAdapter::addUDPIPAddress(const std::string &ip, uint16_t port)
    {
        udpIPAddresses_.push_back(std::make_pair(ip, port));
    }

    void NATTraversalAdapter::addTCPIPAddress(const std::string &ip, uint16_t port)
    {
        tcpIPAddresses_.push_back(std::make_pair(ip, port));
    }

    // Send a STUN request via UDP
    // STUN 요청 함수에서 예외 처리 강화
    void NATTraversalAdapter::sendUDPRequest()
    {
        // Creating UDP socket
        int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
        if (sockfd < 0)
        {
            throw std::runtime_error("Failed to create UDP socket");
        }

        // Setting up the STUN server address
        struct sockaddr_in server_addr;
        memset(&server_addr, 0, sizeof(server_addr));
        server_addr.sin_family = AF_INET;
        server_addr.sin_port = htons(port_);
         server_addr.sin_addr.s_addr = inet_addr(server_.c_str()); // In production, use DNS resolution

        try
        {
            // Creating a STUN binding request
            std::vector<unsigned char> request;
            createSTUNBindingRequest(request);

            // Sending STUN request to the server
            if (sendto(sockfd, request.data(), request.size(), 0, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0)
            {
                close(sockfd);
                throw std::runtime_error("Failed to send data via UDP");
            }
 
            // Receiving STUN response from the server
            std::vector<unsigned char> buffer(1024);
            socklen_t len = sizeof(server_addr);
            ssize_t n = recvfrom(sockfd, buffer.data(), buffer.size(), 0, (struct sockaddr *)&server_addr, &len);

            if (n > 0)
            {
                extractSTUNMappedAddress(buffer, n, true);
            }
            else
            {
                close(sockfd);
                throw std::runtime_error("Failed to receive data via UDP");
            }
        }
        catch (const std::exception &e)
        {
            std::cerr << "Exception: " << e.what() << std::endl;
        }
        close(sockfd);
    }

    // Send a STUN request via TCP
    void NATTraversalAdapter::sendTCPRequest()
    {
        // Creating TCP socket
        int sockfd = socket(AF_INET, SOCK_STREAM, 0);
        if (sockfd < 0)
        {
            throw std::runtime_error("Failed to create TCP socket");
        }

        // Setting up the STUN server address
        struct sockaddr_in server_addr;
        memset(&server_addr, 0, sizeof(server_addr));
        server_addr.sin_family = AF_INET;
        server_addr.sin_port = htons(port_);
        server_addr.sin_addr.s_addr = inet_addr(server_.c_str()); // In production, use DNS resolution

        // Connecting to the STUN server
        if (connect(sockfd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0)
        {
            close(sockfd);
            throw std::runtime_error("Failed to connect to STUN server via TCP");
        }

        // Creating a STUN binding request
        std::vector<unsigned char> request;
        createSTUNBindingRequest(request);

        // Sending STUN request to the server
        if (write(sockfd, request.data(), request.size()) < 0)
        {
            close(sockfd);
            throw std::runtime_error("Failed to send data via TCP");
        }

        // Receiving STUN response from the server
        std::vector<unsigned char> buffer(1024);
        ssize_t n = read(sockfd, buffer.data(), buffer.size());
        if (n > 0)
        {
            extractSTUNMappedAddress(buffer, n, false);
        }
        else
        {
            close(sockfd);
            throw std::runtime_error("Failed to receive data via TCP");
        }

        // Closing socket
        close(sockfd);
    }
    // NATTraversalAdapter 인스턴스 생성 함수
    NATTraversalAdapter *createNATTraversalAdapter(const char *server, uint16_t port)
    {
        return new NATTraversalAdapter(std::string(server), port);
    }

    // NATTraversalAdapter 인스턴스 파괴 함수
    void deleteNATTraversalAdapter(NATTraversalAdapter *adapter)
    {
        delete adapter;
    }

    // STUN 작업 수행
    void performSTUNOperation(NATTraversalAdapter *adapter)
    {
        adapter->performSTUNOperation();
    }

    char *getAllAddresses(NATTraversalAdapter *adapter)
    {
        static std::string addresses;
        addresses.clear();

        auto udpAddresses = adapter->getUDPIPAddresses();
        for (const auto &addr : udpAddresses)
        {
            addresses += "UDP: " + addr.first + ":" + std::to_string(addr.second) + "\n";
        }

        auto tcpAddresses = adapter->getTCPIPAddresses();
        for (const auto &addr : tcpAddresses)
        {
            addresses += "TCP: " + addr.first + ":" + std::to_string(addr.second) + "\n";
        }

        return const_cast<char *>(addresses.c_str());
    }
}
