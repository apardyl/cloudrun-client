# cloudrun-client
A client for cloudrun

**WARNING: this project is under development,, there are many issues to be
addressed (including major security vulnerabilities), DO NOT USE IN PRODUCTION ENVIRONMENT**

## Requirements
* protobuf (protoc and protobuf-cpp) >= 3.0
* grpc >=1.13.0
* rsync
* openssh (both client and server - server binary is used by cloudrun-worker on remote host)
* inotify-tools
* systemd (not required by cloudrun-client itself, but cloudrun-worker currently does not support running systems not based on systemd)

*For Arch linux install following packages: protobuf, (AUR) grpc, rsync, openssh and inotify-tools*

## Install
```bash
git clone --recurse-submodules https://github.com/apardyl/cloudrun-client.git
cd cloudrun-client
make -j"$(nproc)"
sudo make install
```

## Configuration
cloudrun-client does not require any configuration to run,
but if you want to change the defaults all settings are located in `/etc/cloudrun/client.conf`.

## Usage
### cloudrun-scan
Before using cloudrun for the first time and after every system update run:
```
cloudrun-scan
```
The first scan can take several minutes, subsequent runs will be faster
(depending on the number of changed files since last scan; usually several seconds).

### cloudrun-connect
To start cloudrun session with a remote worker run:
```
cloudrun-connect <hostname>
```
This will connect to the remote machine, start worker and on success go to background.

**The machine you are connecting to needs to have `cloudrun-worker` installed AND allow logon as `root` using public key authentication!**
Next releases of cloudrun will not require root login (use either setuid/sudo for privileged tasks or a virtualization backend). Work on automatic cloudrun node creation is also underway.

For details on cloudrun-worker setup consult [https://github.com/apardyl/cloudrun-worker](https://github.com/apardyl/cloudrun-worker)

### cloudrun
Once you have an open session you can run commands on the remote machine by using:
```
cloudrun <command> [args]...
```
Cloudrun will seamlessly execute it on the remote worker as if it was running on your local machine!
#### OR
Start an interactive session simply using
```
cloudrun
```
without any parameters.

**Syncing changes back from node to host is not yet supported, for now you can use sftp/scp/rsync**
```bash
source /etc/cloudrun/client.conf
sftp -P "$SSH_PORT" localhost
```
### cloudrun-disconnect
To end your cloudrun session type:
```
cloudrun-disconnect
```
