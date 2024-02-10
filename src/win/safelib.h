#ifndef SAFELIB_H
#define SAFELIB_H

#include <stdio.h>

#ifndef STDIN_FILENO
#define STDIN_FILENO 0
#endif

#ifndef STDOUT_FILENO
#define STDOUT_FILENO 1
#endif

#ifndef STDERR_FILENO
#define STDERR_FILENO 2
#endif

FILE *safe_popen(char *, const char *);
void safe_pclose(FILE *fp);

#define popen safe_popen
#define pclose safe_pclose

#endif
