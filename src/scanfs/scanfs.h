#ifndef CLOUDRUN_HASHFS_UTILS_SCANFS_H
#define CLOUDRUN_HASHFS_UTILS_SCANFS_H

#include <string>
#include <vector>

int scan_filesystem(std::vector<std::string> included_dirs, const std::string &save_file);

#endif //CLOUDRUN_HASHFS_UTILS_SCANFS_H
