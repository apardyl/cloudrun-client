#ifndef CLOUDRUN_CLIENT_REMOTEFSSERVER_H
#define CLOUDRUN_CLIENT_REMOTEFSSERVER_H

#include <string>
#include <grpcpp/server.h>


class RemoteFSServer {
public:
    void runServer(const std::string &listen_on);
};


#endif //CLOUDRUN_CLIENT_REMOTEFSSERVER_H