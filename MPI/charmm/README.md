# CHARMM

## Installation

1. [Request a license](https://charmm.chemistry.harvard.edu/)

Here is the brief description I submitted: "PSI is a federal research institute
in Switzerland. Charmm will be installed on the HPC cluster, upon request from
structural biology groups."

2. Following accepting the license I got a [download
link](http://charmm.chemistry.harvard.edu/download_charmm.php) by email.

3. Save the tarball as `/opt/psi/var/distfiles/charmm-47.2.tar.gz` (converting
from `c${V_MAJOR}b${V_MINOR}.tar.gz`

4. Run `./build`

5. Check the output directory for symlinks. These seem to come from
post_install, but I don't have time to debug the script more so I'm going to
just copy the directories manually.

