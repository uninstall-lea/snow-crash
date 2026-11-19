file(READ "/home/flag03/.flag" FLAG_CONTENT)
file(WRITE "/var/lib/burbclave/staging/flag.txt" "#FLAG: ${FLAG_CONTENT}\n")