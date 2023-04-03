# MotionCor2 Installation

1. Download MotionCor2 manually from https://emcore.ucsf.edu/ucsf-motioncor2
2. Update files/variants
3. Run `./build <version>`
4. Move all executables to /opt/psi/EM/MotionCor2/$VERSION/bin
5. Move user manual to /opt/psi/EM/MotionCor2/$VERSION/
6. Fix permissions: chmod 755 /opt/psi/EM/MotionCor2/$VERSION/bin
7. Create bin/MotionCor2 wrapper for each version


## Cuda versions

| MotionCor2 | Cuda Versions                                              |
|------------|------------------------------------------------------------|
| 1.0.5      | 8.0 9.1                                                    |
| 1.1.0      | 8.0 9.0 9.1                                                |
| 1.2.0      | 8.0 9.1 9.2                                                |
| 1.2.6      | 8.0 9.2 10.1                                               |
| 1.3.0      | 8.0 9.2 10.1                                               |
| 1.3.1      | 9.2 10.1 10.2                                              |
| 1.3.2      | 8.0 9.2 10.0 10.1 10.2                                     |
| 1.4.0      | 9.2 10.0 10.1 10.2 11.0                                    |
| 1.4.5      | 10.0 10.1 10.2 11.1 11.2 11.3                              |
| 1.4.7      | 10.2 11.1 11.2 11.3 11.4 11.5                              |
| 1.5.0      | 10.1 10.2 11.1 11.2 11.3 11.4 11.5 11.6                    |
| 1.6.4      | 9.2 10.1 10.2 11.1 11.2 11.3 11.4 11.5 11.6 11.7 11.8 12.1 |

