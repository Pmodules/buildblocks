/**
 * This is a execv wrapper around the ctffind binary that
 * simply sets the session environment to use the C locale.
 * Otherwise the binary will likely segfault due to expecting
 * a completely different locale.
 */
#include <unistd.h>

#define CTFFIND_PATH "@CTFFINDPATH@"

int main(int argc, char* argv[])
{
	char* envp[] = {"LC_ALL=C", NULL};
	argv[0] = "ctffind";
	return execve(CTFFIND_PATH, argv, envp);
}
