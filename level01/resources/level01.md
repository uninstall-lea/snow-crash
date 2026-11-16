# Level01 - gargoyle :

## 🔍 1. Looking for clues

Building on the methodology from **level00**, custom binaries and files were discovered neatly organized inside subfolders under `/opt/snowcrash/` for each respective level.

So we start by inspecting directly the `level01` subfolder :

```bash
level01@snowcrash:~$ ls -la /opt/snowcrash/level01/
total 32
drwxr-xr-x  2 root root  4096 Jun  9 19:03 .
drwxr-xr-x 18 root root  4096 Jun  9 19:04 ..
-rwxr-xr-x  1 root root 22656 Jun  9 19:03 gargoyle
```

Trying to run the binary throws an error, perhaps an argument is missing ?

```bash
level01@snowcrash:~$ /opt/snowcrash/level01/gargoyle 
Floating point exception (core dumped)
```

## 🔬 2. Process Inspection & Service Analysis

To find out how the system runs it, we inspect running processes with `ps aux` to look for any background tasks executing under the target user `flag01`:

```bash
level01@snowcrash:~$ ps aux | grep flag01
flag01       686  0.0  0.0   2688  1216 ?        S    15:29   0:00 /opt/snowcrash/level01/gargoyle kooda7puivaav1idi4f57q8iq0
level01     6215  0.0  0.1   6548  2276 pts/0    S+   16:34   0:00 grep --color=auto flag01
```

And verify its configuration via `systemctl` :

```bash
level01@snowcrash:/opt/snowcrash/level01$ systemctl status gargoyle.service
● gargoyle.service - Snow Crash level01 — Gargoyle data collector
     Loaded: loaded (/etc/systemd/system/gargoyle.service; enabled; preset: enabled)
     Active: active (running) since Mon 2026-11-16 16:29:38 UTC; 30min left
    Process: 583 ExecStart=/opt/snowcrash/level01/gargoyle kooda7puivaav1idi4f57q8iq0 (code=exited, status=0/SUCCESS)
   Main PID: 686 (kworker/0:1H)
      Tasks: 1 (limit: 2263)
     Memory: 240.0K (peak: 1.8M)
        CPU: 196ms
     CGroup: /system.slice/gargoyle.service
             └─686 /opt/snowcrash/level01/gargoyle kooda7puivaav1idi4f57q8iq0

Warning: some journal files were not opened due to insufficient permissions.
```

- **Observation:** Initial attempts to run the binary directly without arguments did not yield an interactive shell or immediate output. However, examining the service's `ExecStart` parameter shows that the daemon invokes the binary with a specific argument.

- **The Clue:** The argument passed by the system service `kooda7puivaav1idi4f57q8iq0` acts as the credential or parameter required by the program.

## 🛠️ 3. Resolution: Argument & Configuration Extraction

Unlike **level00** where secrets were embedded inside the binary strings, here the critical information is exposed through how the system instantiates and runs the process in the background.

The argument supplied to the service (**kooda7puivaav1idi4f57q8iq0**) serves as the password for the next user level.

## 🔑 4. Validation

```bash
$ su level02
Password: kooda7puivaav1idi4f57q8iq0
level02@snowcrash:~$
```

**Flag / Password :** `kooda7puivaav1idi4f57q8iq0`

### 💡 Key Takeaway:
- Do not limit reconnaissance to static file permissions. Inspecting active system processes (**ps aux**) and service configurations (**systemctl**) often reveals sensitive startup arguments, tokens, or credentials instantiated by the system.


