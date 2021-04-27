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
