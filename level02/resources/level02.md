# Level02 - kourier :

## 🔍 1. Looking for clues

Building on the methodology from previous levels, we inspect the `level02` subfolder:

```bash
level02@snowcrash:~$ ls -la /opt/snowcrash/level02/
total 32
drwxr-xr-x  2 root root  4096 Jun  9 19:03 .
drwxr-xr-x 18 root root  4096 Jun  9 19:04 ..
-rwxr-xr-x  1 root root 26696 Jun  9 19:03 kourier
```

We first tried running the executable directly, which gave no output. Process inspection (`ps aux`) didn't reveal any background arguments or clues either.

Faced with these dead ends, we fell back to our **level00** methodology by running a static analysis on the binary using strings:

```bash
strings /opt/snowcrash/level02/kourier
```

Scanning through the output, a clear hardcoded string instantly stands out as the target credential: `qi0mauch9ahksha8b6dfe3p0kq`.

## 🔑 2. Validation

```bash
$ su level03
Password: qi0mauch9ahksha8b6dfe3p0kq
level02@snowcrash:~$
```

**Flag / Password :** `qi0mauch9ahksha8b6dfe3p0kq`

### 💡 Key Takeaway:
- **Methodology rotation & pattern recognition** prove that cybersecurity heavily relies on a consistent toolkit because core vulnerabilities often repeat. When a dynamic or advanced approach hits a dead end, systematically cycling back to fundamental techniques (here: static analysis) is often the most direct path to uncovering hardcoded flaws.


