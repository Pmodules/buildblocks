# DeepEMhancer 

DeepEMhancer is a Python package for post-processing cryo-EM maps, as described in DeepEMhancer: a deep learning solution for cryo-EM volume post-processing by Sanchez-Garcia et al. (2021).

DeepEMhancer was trained on pairs of experimental volumes and atomic model-corrected volumes. Its preferred inputs are unprocessed half-maps. Post-translational modifications and ligands were not included in the training set, so results for these features may be inaccurate.

DeepEMhancer performs nonlinear post-processing with two main effects:

- Local sharpening-like post-processing.
- Automatic masking and denoising.

https://github.com/rsanchezgarc/deepEMhancer
