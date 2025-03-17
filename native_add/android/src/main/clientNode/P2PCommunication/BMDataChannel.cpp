#include "BMDataChannel.hpp"

BMDataChannel::BMDataChannel() {}

BMDataChannel::~BMDataChannel() {}

bool BMDataChannel::createChannel(int listenPort) {
    return udpCommunication_.createChannel(listenPort);
}

bool BMDataChannel::connect(const std::string& peerIP, int peerPort) {
    return udpCommunication_.connect(peerIP, peerPort);
}

bool BMDataChannel::send(const std::string& message) {
    return udpCommunication_.send(message);
}

void BMDataChannel::setOnMessageCallback(std::function<void(const std::string& message)> callback) {
    onMessageCallback_ = callback;
    // 수정: UDPCommunication에 새로운 콜백 함수 설정
    udpCommunication_.setOnMessageCallback([this](const std::string& message) {
        receiveCallbackWrapper(message);
    });
}

void BMDataChannel::receiveCallbackWrapper(const std::string& message) {
    if (onMessageCallback_) {
        onMessageCallback_(message);
    }
}

