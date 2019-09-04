This environment adds some dependencies to talos_36.yml via pip install.

#######
$ conda env create -f talos_py36.yml

$ pip install talos
######
This brings in talos-0.4.9 at the time of this writing.

The talos install will produce some warnings, but will still install.

################# Part of output
...
  Stored in directory: /afs/psi.ch/user/f/feichtinger-adm/.cache/pip/wheels/a3/85/27/2179469128bd1f663d3563a8e2166223b2c0fc409c91f83b48                                                         
Successfully built talos astetik sklearn chances kerasplotlib wrangle                                                                                                
ERROR: wrangle 0.6.5 has requirement scipy==1.2, but you'll have scipy 1.3.0 which is incompatible.                                                                                              
Installing collected packages: sklearn, wrangle, geonamescache, astetik, tqdm, matplotlib, chardet, urllib3, idna, requests, chances, kerasplotlib, talos                                       
  Found existing installation: matplotlib 3.1.1                                                                                                                                                  
    Uninstalling matplotlib-3.1.1:                                                                                                                                                 
      Successfully uninstalled matplotlib-3.1.1                                                                                                                 
Successfully installed astetik-1.9.8 chances-0.1.6 chardet-3.0.4 geonamescache-1.0.2 idna-2.8 kerasplotlib-0.1.4 matplotlib-2.2.3 requests-2.22.0 sklearn-0.0 talos-0.4.9 tqdm-4.32.2 urllib3-1.25.3 wrangle-0.6.5
###################

The tests by users (A. Adelmann) succeeded. I did not replace
scipy. Talos will replace a number of dependencies, matplotlib among
them. After the pip installs the environment should be considered
tainted. Further changes of the environment by conda may reflect this
inconsistent state, so it might be better to regenerate the whole
environment using first conda, then pip.

2019-07-16 Derek
