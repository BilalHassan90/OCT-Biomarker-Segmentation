# OCT-Biomarker-Segmentation
This repository provides the official implementation of the paper titled "Joint Segmentation and Quantification of Chorioretinal Biomarkers in Optical Coherence Tomography Scans: A Deep Learning Approach." The paper has been accepted and is expected to be published in IEEE Transactions on Instrumentation and Measurement.
## Citation
If you use any part of the provided code in your research, please consider citing the paper as follows:
```
@article{Hassan2021,
  title={Joint Segmentation and Quantification of Chorioretinal Biomarkers in Optical Coherence Tomography Scans: A Deep Learning Approach},
  author={Hassan, Bilal and Qin, Shiyin and Hassan, Taimur and Ahmed, Ramsha and Werghi, Naoufel},
  journal={IEEE Transactions on Instrumentation and Measurement},
  year={2021},
  publisher={IEEE},
}
```
## Introduction
A residual-learning-based asymmetric encoder-decoder network (RASP-Net) is proposed in this research. RASP-Net provides semantic segmentation and quantification of the following 11 OCT imaging-based chorioretinal biomarkers (CRBMs): (1) health, (2) intraretinal fluid, (3) subretinal fluid, (4) serous pigment epithelial detachment, (5) drusen/ reticular pseudodrusen, (6) hard exudates or hyperreflective foci, (7) chorioretinal or geographic atrophy, (8) focal choroidal excavation, (9) vitreomacular traction, (10) epiretinal membrane, and (11) choroidal neovascular membrane. RASP-Net operates at OCT B-scan level and requires pixel-wise annotations of 11 CRBMs against each scan. The overview of the proposed RASP-Net framework is presented below: 

<p align="center">
<img width=800 align="center" src = "https://github.com/BilalHassan90/OCT-Biomarker-Segmentation/blob/main/Images/Overview.jpg" alt="Introduction"> </br>
</p>

**Figure:** Overview of the proposed method. The RASP-Net framework integrated with coherent pre- and post-processing to perform the joint segmentation, quantification, and 3-D visualization of OCT imaging-based chorioretinal biomarkers.

## Prerequisites
MATLAB R2020a platform with deep learning, image processing, and computer vision toolboxes. 

## Stepwise Operations
We provide separate main files for four operations, including preprocessing, network training and validation, postprocessing, and quantification.

<p align="justify">
<b>Data Preprocessing </b>
1.	Put the raw OCT scans data in the “…\Raw Scans” folder and pixel-wise ground truth annotations in the “…\Ground Truth Labels” folder. The label IDs corresponding to each class pixel are provided in the “Classes_ID.mat” file.
2.	To preprocess the scans, use the “Preprocessor.m” file. The scans containing VMT CRBM are preprocessed differently. Please select the option “Yes” if the candidate OCT scan has the VMT CRBM and “No” otherwise. The preprocessed scans are stored in the “…\Preprocessed” folder. The values of preprocessing parameters are empirically adjusted, generating adequate results in most cases. 

  
