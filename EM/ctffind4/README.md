# CTFFIND

CTFFIND is a widely-used program for the estimation of objective lens defocus parameters from transmission electron micrographs. Defocus parameters are estimated by fitting a model of the microscope’s contrast transfer function (CTF) to an image’s amplitude spectrum.

https://grigoriefflab.umassmed.edu/ctffind4

## Custom changes
For ARM CPUs, I've changed the file src/core/matrix.cpp to allow to be compliled.

The previous first lines were:
```{c++}
#include "core_headers.h"

// these are needed for the simple rotation matrix creation, which uses very optimized code from an old game programming library i wrote when i was about 12,
// think i got it from a book i had about game programming in c.. it's probably slower than what the compiler would do these days.

#define AL_PI        3.14159265358979323846
#define _AL_SINCOS(x, s, c)  __asm__ ("fsincos" : "=t" (c), "=u" (s) : "0" (x))
#define FLOATSINCOS(x, s, c)  _AL_SINCOS((x) * AL_PI / 128.0, s ,c)
```

After the changes:
```{c++}
#include "core_headers.h"
#include <cmath>

// simple rotation matrix creation (portable version)

#define AL_PI 3.14159265358979323846

// replace x86 fsincos asm with standard C math
#define FLOATSINCOS(x, s, c)           \
    do {                                \
        float _angle = (x) * AL_PI / 128.0f; \
        (s) = sinf(_angle);             \
        (c) = cosf(_angle);             \
    } while (0)
```
