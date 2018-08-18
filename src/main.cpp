#include <cstring>
#include <vector>
#include <string>
#include <server/RemoteFSServer.h>

#include "scanfs/scanfs.h"

using namespace std;

int main(int argc, char **argv) {
    if (argc >= 4) {
        if (strcmp(argv[1], "scan") == 0) {
            vector<string> paths_to_scan;
            for (int i = 3; i < argc; i++) {
                paths_to_scan.emplace_back(argv[i]);
            }
            scan_filesystem(paths_to_scan, string(argv[2]));
        }
    }
    if (argc == 3 && strcmp(argv[1], "serve") == 0) {
        RemoteFSServer().runServer(std::string(argv[2]));
    }
    return 0;
}
