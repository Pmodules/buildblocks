TODO


Installation done on pmod7

```
conda env create -f jupyterhub-4.0.2_lab3_py3.11 

conda activatejupyterhub-4.0.2_lab3_py3.11
```

The current production versions of the spawners (e.g. batchspawner-1.0.0) are
not compatible with jupyterhub-1.0.0. So, one is forced to deploy the
development versions. This is coded in the yaml file as pip dependency, 
pointing to the latest commit available

Also, jupyterlab 4 and jupyter-server 2.11 are not yet supported
