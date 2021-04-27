# OCT-Biomarker-Segmentation
This repository provides the official implementation of the paper titled <b>“Joint Segmentation and Quantification of Chorioretinal Biomarkers in Optical Coherence Tomography Scans: A Deep Learning Approach.”</b> The paper has been accepted and is expected to be published in IEEE Transactions on Instrumentation and Measurement.

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
A residual-learning-based asymmetric encoder-decoder network (RASP-Net) is proposed in this research. RASP-Net provides semantic segmentation and quantification of the following 11 OCT imaging-based chorioretinal biomarkers (CRBMs): (i) health (H), (ii) intraretinal fluid (IRF), (iii) subretinal fluid (SRF), (iv) serous pigment epithelial detachment (PED), (v) drusen/ reticular pseudodrusen (RPD), (vi) hard exudates or hyperreflective foci (HF), (vii) chorioretinal or geographic atrophy (GA), (viii) focal choroidal excavation (FCE), (ix) vitreomacular traction (VMT), (x) epiretinal membrane (ERM), and (xi) choroidal neovascular membrane (CNVM). RASP-Net operates at OCT B-scan level and requires pixel-wise annotations of 11 CRBMs against each scan. The overview of the proposed RASP-Net framework is presented below: 

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

<b>Network Training and Validation </b>

  3.	The network requires the preprocessed scans for training as stored in the “…\Preprocessed” folder in the previous step.
  4.	To train the network from scratch, use the “Trainingcode.m” file and specify the training hyper-parameters. The data is split in the ratio of 60:20:20 for the train, validate, and test subsets. The IDs of each relevant subset are stored in the “Idx.mat” file. 
  5.	Once the network training is completed, the trained instances are saved as a “TrainedNet.mat” file. While the predicted labels are stored in the “…\Predicted Labels” folder.
  
<b>Data Postprocessing </b>

  6.  In the next step, the network predicted results are cleaned using the postprocessing scheme. For this purpose, use the “Postprocessing.m” file.
  7.  This step requires the predicted scans for postprocessing stored in the “…\Predicted Labels” folder in the previous step.
  8.  The final postprocessed scans are stored in the “…\PostProcessed” folder. 

<b>CRBMs Quantification </b>

  9.  The quantification of CRBMs can be performed at the B-scan level or the eye level using OCT volumes.
  10. This step requires the postprocessed scans stored in the “...\OCT Volumes\1\Postprocessed” folder, generated using the postprocessing scheme. Put the corresponding ground truth labels in the “...\OCT Volumes\1\Ground Truth Labels” folder.
  11. Run the “Quantification.m” file for CRBMs quantification. This step also generates the 3D macular profile of the candidate OCT volume along with the quantification results and saves them in the “...\OCT Volumes\1\3DQuantification” folder.
</p>

## Results
We have provided the results of 20 sample OCT scans in the “...\Other” directory.

## Contact
If you have any query, please feel free to contact us at bilalhassan@buaa.edu.cn 

	



  
