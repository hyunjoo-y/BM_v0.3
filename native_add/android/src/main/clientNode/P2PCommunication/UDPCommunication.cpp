// UDPCommunication.cpp

#include "UDPCommunication.hpp"


extern "C" __attribute__((visibility("default"))) __attribute__((used))


UDPCommunication::UDPCommunication() : datachaanel_(-1) {}

UDPCommunication::~UDPCommunication() {
    closeSocket();
}

bool UDPCommunication::createChannel(int listenPort){
    datachaanel_ = socket(AF_INET, SOCK_DGRAM, 0);
    if (datachaanel_ < 0) {
        std::cerr << "Error creating UDP socket\n";
        return -1;
    }

    struct sockaddr_in myAddr;
    memset(&myAddr, 0, sizeof(myAddr));
    myAddr.sin_family = AF_INET;
    myAddr.sin_addr.s_addr = INADDR_ANY;
    myAddr.sin_port = htons(listenPort);

    if (bind(datachaanel_, (struct sockaddr *)&myAddr, sizeof(myAddr)) < 0) {
        std::cerr << "Error binding UDP socket\n";
        return -1;
    }

    return true;
}

bool UDPCommunication::connect(const std::string& peerIP, int peerPort) {
    datachaanel_ = socket(AF_INET, SOCK_DGRAM, 0);
    if (datachaanel_ < 0) {
        std::cerr << "Error creating socket" << std::endl;
        return false;
    }

    serverAddr_.sin_family = AF_INET;
    serverAddr_.sin_addr.s_addr = inet_addr(peerIP.c_str());
    serverAddr_.sin_port = htons(peerPort);
    std::string data = "connection create";

    if (sendto(datachaanel_, data.c_str(), data.length(), 0, (struct sockaddr *)&serverAddr_, sizeof(serverAddr_)) < 0) {
        std::cerr << "Error sending data" << std::endl;
        return false;
    }

    return true;
}

bool UDPCommunication::send(const std::string& data) {
    if (sendto(datachaanel_, data.c_str(), data.length(), 0, (struct sockaddr *)&serverAddr_, sizeof(serverAddr_)) < 0) {
        std::cerr << "Error sending data" << std::endl;
        return false;
    }
    return true;
}

std::string UDPCommunication::receiveData() {
    char buffer[1024];
    bzero(buffer, sizeof(buffer));
    if (recvfrom(datachaanel_, buffer, sizeof(buffer), 0, (struct sockaddr *)&clientAddr_, &clientAddrLen_) < 0) {
        std::cerr << "Error receiving data" << std::endl;
        return "";
    }

    // 수정: 콜백 함수가 셋팅되어 있는 경우에만 호출
    if (onMessageCallback_) {
        onMessageCallback_(std::string(buffer));
    }

    return std::string(buffer);
}

void UDPCommunication::closeSocket() {
    close(datachaanel_);
}

// 추가: 콜백 함수 설정
void UDPCommunication::setOnMessageCallback(std::function<void(const std::string&)> callback) {
    onMessageCallback_ = callback;
}

