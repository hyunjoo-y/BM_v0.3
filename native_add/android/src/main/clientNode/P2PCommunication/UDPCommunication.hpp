// UDPCommunication.h

#ifndef UDP_COMMUNICATION_HPP
#define UDP_COMMUNICATION_HPP

#include <iostream>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <cstring>ㄴ

extern "C" __attribute__((visibility("default"))) __attribute__((used))

class UDPCommunication {
public:
    UDPCommunication();
    ~UDPCommunication();

    bool connect(const std::string& peerIP, int peerPort);
    //bool waitForConnection(int listenPort);
    bool send(const std::string& data);
    std::string receiveData();
    void closeSocket();
    bool createChannel(int listenPort);

    // 추가: 콜백 함수 설정
    void setOnMessageCallback(std::function<void(const std::string&)> callback);

private:
    int datachaanel_;
    struct sockaddr_in serverAddr_;
    struct sockaddr_in clientAddr_;
    socklen_t clientAddrLen_;

    std::function<void(const std::string&)> onMessageCallback_;
};

#endif // UDP_COMMUNICATION_H
