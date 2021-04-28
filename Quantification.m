clc
clear all
close all
addpath(genpath(pwd))

labelDir = fullfile(pwd,'OCT Volumes','1','Ground Truth Labels');
PostprocDir = fullfile(pwd,'OCT Volumes','1','Postprocessed');
QuantDir = fullfile(pwd,'OCT Volumes','1','3DQuantification');
if numel(dir(labelDir))<=2 || numel(dir(PostprocDir))<=2 || numel(dir(labelDir))~= numel(dir(PostprocDir)) 
    ModelHelperFunctions.LabelsError
else
pdest = fullfile(pwd,'OCT Volumes','1','3DQuantification');
classes = ["BG" "H" "IRF" "SRF" "PED" "RPD" "HF" "GA" "FCE" "VMT" "ERM" "CNVM"];
labelIDs =[1 2 3 4 5 6 7 8 9 10 11 12]; 
KKE=[0 114 189;217 83 25;237 177 32;126 47 142;0 255 0;119 172 48;77 190 238;162 20 47;255 0 0;255 19 166;255 255 17;166 166 166]/255;
KKF=[0 114 189;242 157 121;212 149 4;82 31 92;0 164 0;20 163  20;7 116 163;99 12 29;200 0 0;166 0 104;179 179 0;100 100 100]/255;

SortLabelsGT = ModelHelperFunctions.sorting(labelDir);
pxdsGT = pixelLabelDatastore(SortLabelsGT,classes,labelIDs);
SortLabelsPostproc = ModelHelperFunctions.sorting(PostprocDir);
pxdsPostproc = pixelLabelDatastore(SortLabelsPostproc,classes,labelIDs);
GTLabels=readall(pxdsGT);
CatGT=cat(3,GTLabels{:, 1});  
PredLabels=readall(pxdsPostproc);
CatPred=cat(3,PredLabels{:, 1});  

[AreasPred, TotalAreaPred] = ModelHelperFunctions.ThreeDRecons(CatPred,KKE,KKF,PredLabels,classes,QuantDir);
[QGt,QPr,QD] = ModelHelperFunctions.QuantificationFunc(CatGT,GTLabels,AreasPred, TotalAreaPred);

TT=[classes(2:end)' QGt' QPr' QD'];
T = array2table(TT,...
     'VariableNames',{'Classes','Ground Truth Quantification','Predicted Labels Quantification', 'Quantification Difference'});

end










