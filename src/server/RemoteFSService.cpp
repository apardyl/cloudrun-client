#include "RemoteFSService.h"
#include "utils/sha256.h"

#include <grpc/grpc.h>
#include "config.h"

using grpc::Status;
using grpc::StatusCode;
using namespace remotefs;

grpc::Status RemoteFSService::GetChecksum(::grpc::ServerContext *context, const ::remotefs::FileRequest *request,
                                          ::remotefs::ChecksumResponse *response) {
    debug_print("GetChecksum: %s\n", request->path().c_str());
    int res = sha256_file(request->path(), response->mutable_checksum());
    return errno_to_status(res);
}

grpc::Status RemoteFSService::GetStat(::grpc::ServerContext *context, const ::remotefs::FileRequest *request,
                                      ::filesystem::Stat *response) {
    return Status(StatusCode::UNIMPLEMENTED, "not implemented");
}

grpc::Status RemoteFSService::GetData(::grpc::ServerContext *context, const ::remotefs::FileRequest *request,
                                      ::grpc::ServerWriter<::remotefs::DataChunkResponse> *writer) {
    return Status(StatusCode::UNIMPLEMENTED, "not implemented");
}

grpc::Status RemoteFSService::ListDirectory(::grpc::ServerContext *context, const ::remotefs::FileRequest *request,
                                            ::remotefs::FileListResponse *response) {
    return Status(StatusCode::UNIMPLEMENTED, "not implemented");
}

grpc::Status
RemoteFSService::PutFile(::grpc::ServerContext *context, ::grpc::ServerReader<::remotefs::DataChunkRequest> *reader,
                         ::remotefs::Empty *response) {
    return Status(StatusCode::UNIMPLEMENTED, "not implemented");
}

grpc::Status RemoteFSService::errno_to_status(int code) {
    switch (code) {
        case 0:
            return Status::OK;
        case ENOENT:
            return Status(StatusCode::NOT_FOUND, "ENOENT");
        case ENOTDIR:
            return Status(StatusCode::INVALID_ARGUMENT, "ENOTDIR");
        case EACCES:
            return Status(StatusCode::PERMISSION_DENIED, "EACCES");
        default:
            return Status(StatusCode::INTERNAL, "errno: " + std::to_string(code));
    }
}
