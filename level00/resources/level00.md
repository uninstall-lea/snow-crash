# Level00 - hiro :

## 🔍 1. Looking for clues

Upon logging in as `level00`, the home directory only contains a flavor-text `README` file with no actionable clues:

```
$ cat README
Hiro Protagonist. Last of the freelance hackers. Or so he thinks.
```

One of the standard first step is to look for any binaries with the SUID bit set, allowing privilege escalation or enumeration.


```bash
find / -perm -4000 2>/dev/null
```

Among standard system utilities, one custom binary stands out:

```bash
/opt/snowcrash/level00/hiro
```

## 🔬 2. Binary Inspection & Runtime Behavior

Checking the file's permissions and ownership with ls -l:

```bash
level00@snowcrash:~$ ls -l /opt/snowcrash/level00/
total 28
-r-sr-x--- 1 flag00 level00 27112 Jun  9 19:03 hiro
```

- Owner: flag00
- Permissions: The s bit (-r-sr-x---) ensures the executable runs with the effective privileges of its owner (flag00) rather than the user launching it.

```bash
level00@snowcrash:~$ /opt/snowcrash/level00/hiro
[*] Checking credentials...
[*] Access granted — welcome, flag00

flag00@snowcrash:~$ cat .flag
cat: permission denied
```

In reality, this is a decoy (honeypot) simulating a shell prompt without actually elevating privileges or granting access to the target files.

## 🛠️ 3. Resolution: Static Analysis

Since dynamic execution leads to a dead end, the next logical step is static analysis to inspect the binary's internal structure without running it.

Using the strings utility extracts all printable character sequences embedded within the compiled executable:

```bash
level00@snowcrash:~$ strings /opt/snowcrash/level00/hiro
>@f2av5il02puano7naaf6adaf3a
```

A specific string clearly stands out from standard compiler/library symbols.

## 🔑 4. Validation

```
$ su level01
Password: f2av5il02puano7naaf6adaf3a
level01@snowcrash:~$
```

**Flag / Password :** `f2av5il02puano7naaf6adaf3a`

### 💡 Key Takeaway:
- When dealing with a SUID binary that behaves like a dead end at runtime, performing basic static analysis with tools like strings should always be an early reflex to uncover hardcoded secrets or passwords before diving into deeper reverse engineering.


