#ifndef BM_DATA_CHANNEL_HPP
#define BM_DATA_CHANNEL_HPP

#include "UDPCommunication.hpp"
#include <string>
#include <functional>

extern "C" __attribute__((visibility("default"))) __attribute__((used))

/**
 * The RTCDataChannel class represents a data channel in WebRTC.
 * Data channels are used to transmit non-audio/video data over a WebRTC peer
 * connection. This class provides a base interface for data channels to
 * implement, allowing them to be used with WebRTC's data channel mechanisms.
 */
class BMDataChannel
{
public:
  BMDataChannel();
  ~BMDataChannel();

  bool createChannel(int listenPort);
  bool connect(const std::string &peerIP, int peerPort);
  bool waitForConnection(int listenPort);
  bool send(const std::string &message);
  void setOnMessageCallback(std::function<void(const std::string &message)> callback);

private:
  UDPCommunication udpCommunication_;
  std::function<void(const std::string &message)> onMessageCallback_;
  void receiveCallbackWrapper(const std::string &message);
};

#endif