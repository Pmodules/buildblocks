 Installation remarks for Tomodrgn: 

1.) function in tomodrgn/analysis.py is not valid with matplotlib v3.8 anymore, this is why the function is substituted in the build script:
sed -i 's/cbar.draw_all/cbar._draw_all/' tomodrgn/analysis.py 

2.) the tomodrgn quicktest script can be exectued by : 
python /opt/psi/EM/tomodrgn/0.2.2/tomodrgn/testing/quicktest.py
REMARK: This file was changed in order to provide the argument --datadir /opt/psi/EM/tomodrgn/0.2.2/tomodrgn/testing/, otherwise it will look for the "data" folder in the current working dir. 

3.) quicktest is run without the two arguments: --num-workers (dafault =0) and --prefetch-factor (default should be None, but is actually 2), which throws an error,was fixed by changing the default of --prefetch-factor to None in the file /opt/psi/EM/tomodrgn/0.2.2/miniconda/envs/tomodrgn_0.2.2/lib/python3.9/site-packages/tomodrgn/commands/train_vae.py   



