 Installation remarks for cryocare: 

 - pip installation from https://pypi.org/project/cryoCARE/,   (see environment.yaml)
 - creation of conda env with miniconda 

Usage with Relion: module does not need to be activated , BUT : 
- executables need to be provided in the relion GUI
- the modulefile in RELION needs to add the cryocare bin to the LD_LIBRARY_PATH, otherwise the libraries will not be found 



