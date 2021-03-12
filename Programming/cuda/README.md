# How To Install Cuda

## Download the proper Cuda version

```bash
wget https://developer.download.nvidia.com/compute/cuda/11.2.2/local_installers/cuda_11.2.2_460.32.03_linux.run
```

## Steps

0. **Run installation wizard:**
   ```bash
   sh cuda_11.2.2_460.32.03_linux.run --samples --samplespath=/opt/psi/Programming/cuda/11.2.2 --toolkit --toolkitpath=/opt/psi/Programming/cuda/11.2.2 --no-drm
   ```
1. **Accept EULA**: _accept_
   ```
   ┌──────────────────────────────────────────────────────────────────────────────┐
   │  End User License Agreement                                                  │
   │  --------------------------                                                  │
   │                                                                              │
   │  The CUDA Toolkit End User License Agreement applies to the                  │
   │  NVIDIA CUDA Toolkit, the NVIDIA CUDA Samples, the NVIDIA                    │
   │  Display Driver, NVIDIA Nsight tools (Visual Studio Edition),                │
   │  and the associated documentation on CUDA APIs, programming                  │
   │  model and development tools. If you do not agree with the                   │
   │  terms and conditions of the license agreement, then do not                  │
   │  download or use the software.                                               │
   │                                                                              │
   │  Last updated: Nov 2, 2020.                                                  │
   │                                                                              │
   │                                                                              │
   │  Preface                                                                     │
   │  -------                                                                     │
   │                                                                              │
   │  The Software License Agreement in Chapter 1 and the Supplement              │
   │  in Chapter 2 contain license terms and conditions that govern               │
   │  the use of NVIDIA software. By accepting this agreement, you                │
   │──────────────────────────────────────────────────────────────────────────────│
   │ Do you accept the above EULA? (accept/decline/quit):                         │
   │ accept                                                                       │
   └──────────────────────────────────────────────────────────────────────────────┘
   ```
2. **CUDA ToolKit:** _check all_
3. **CUDA Samples:** _check all_
4. **CUDA Demo Suite:** _check all_
5. **CUDA Documentation:** _check all_
   ```
   ┌──────────────────────────────────────────────────────────────────────────────┐
   │ CUDA Installer                                                               │
   │ - [ ] Driver                                                                 │
   │      [ ] 460.32.03                                                           │
   │ + [X] CUDA Toolkit 11.2                                                      │
   │   [X] CUDA Samples 11.2                                                      │
   │   [X] CUDA Demo Suite 11.2                                                   │
   │   [X] CUDA Documentation 11.2                                                │
   │   Options                                                                    │
   │   Install                                                                    │
   │                                                                              │
   │                                                                              │
   │                                                                              │
   │                                                                              │
   │                                                                              │
   │	                                                                          │
   │                                                                              │
   │                                                                              │
   │                                                                              │
   │                                                                              │
   │                                                                              │
   │                                                                              │
   │                                                                              │
   │ Up/Down: Move | Left/Right: Expand | 'Enter': Select | 'A': Advanced options │
   └──────────────────────────────────────────────────────────────────────────────┘
   ```
6. **Options**:
   * **Driver Options:** 
      * Do not install any of the OpenGL-related driver files: _uncheck_
      * Do not install the nvidia-drm kernel module: _check_
   * **ToolKit Options:** _uncheck all_ and:
      * **Change Toolkit Install Path:** `/opt/psi/Programming/cuda/11.2.2`
   * **Samples Options:** 
      * **Change Writeable Samples Install Path:** `/opt/psi/Programming/cuda/11.2.2`
   * **Library install path (Blank for system default):** `/opt/psi/Programming/cuda/11.2.2`
7. **Install**

## Post-Installation

1. Add the new version in the variants file:
   ```bash
   (base) [caubet_m@merlin-l-001 cuda]$ git diff files/variants.rhel7
   diff --git a/Programming/cuda/files/variants.rhel7 b/Programming/cuda/files/variants.rhel7
   index ba48643..2cb6f93 100644
   --- a/Programming/cuda/files/variants.rhel7
   +++ b/Programming/cuda/files/variants.rhel7
   @@ -7,3 +7,4 @@ cuda/10.1.105   stable
    cuda/11.0.3     stable
    cuda/11.1.0     stable
    cuda/11.1.1     stable
   +cuda/11.2.2     unstable
   ```
2. Update Module files:
   ```bash
   (base) [caubet_m@merlin-l-001 cuda]$ ./build 11.2.2 --update-modulefiles
   cuda/11.2.2: already exists, not rebuilding ...
   cuda/11.2.2: installing modulefile in '/opt/psi/Programming/modulefiles/cuda' ...
   ```
3. Commit + push:
   ```bash
   (base) [caubet_m@merlin-l-001 cuda]$ git commit -a -m "Added cuda/11.2.2 -> unstable"
   [CUDA_README db375c2] Added cuda/11.2.2 -> unstable
    Committer: Caubet Serrabou Marc <caubet_m@merlin-l-001.psi.ch>
   Your name and email address were configured automatically based
   on your username and hostname. Please check that they are accurate.
   You can suppress this message by setting them explicitly:
   
       git config --global user.name "Your Name"
       git config --global user.email you@example.com
   
   After doing this, you may fix the identity used for this commit with:
   
       git commit --amend --reset-author
   
    1 file changed, 1 insertion(+)
  
   (base) [caubet_m@merlin-l-001 cuda]$     git push --set-upstream origin CUDA_README
   Username for 'https://gitlab.psi.ch': caubet_m
   Password for 'https://caubet_m@gitlab.psi.ch': 
   Counting objects: 11, done.
   Delta compression using up to 88 threads.
   Compressing objects: 100% (6/6), done.
   Writing objects: 100% (6/6), 595 bytes | 0 bytes/s, done.
   Total 6 (delta 3), reused 0 (delta 0)
   remote: 
   remote: To create a merge request for CUDA_README, visit:
   remote:   https://gitlab.psi.ch/Pmodules/buildblocks/-/merge_requests/new?merge_request%5Bsource_branch%5D=CUDA_README
   remote: 
   To https://gitlab.psi.ch/Pmodules/buildblocks.git
    * [new branch]      CUDA_README -> CUDA_README
   Branch CUDA_README set up to track remote branch CUDA_README from origin.
   ```
4. Request merge request from the provided URL
