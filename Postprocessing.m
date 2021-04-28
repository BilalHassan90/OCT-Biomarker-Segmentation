clc
clear all
close all
addpath(genpath(pwd))

imgDir = fullfile(pwd,'Resized Scans');
labelDir = fullfile(pwd,'Ground Truth Labels');
PredDir = fullfile(pwd,'Predicted Labels');
pdest = fullfile(pwd,'PostProcessed');
load('Idx.mat')

classes = ["BG" "H" "IRF" "SRF" "PED" "RPD" "HF" "GA" "FCE" "VMT" "ERM" "CNVM"];
labelIDs =[1 2 3 4 5 6 7 8 9 10 11 12]; 
SortLabelsImds = ModelHelperFunctions.sorting(imgDir);
imds = imageDatastore(SortLabelsImds);
SortLabelsGT = ModelHelperFunctions.sorting(labelDir);
pxdsGT1 = pixelLabelDatastore(SortLabelsGT,classes,labelIDs);
testLabels = pxdsGT1.Files(testIdx);
pxdsGT2 = pixelLabelDatastore(testLabels, classes, labelIDs);
SortLabelsPr = ModelHelperFunctions.sorting(PredDir);
pxdsPr = pixelLabelDatastore(SortLabelsPr,classes,labelIDs);
pxdsPo = pxdsPr;
KK=[0 114 189;217 83 25;237 177 32;126 47 142;0 255 0;119 172 48;77 190 238;162 20 47;255 0 0;255 19 166;255 255 17;166 166 166]/255;
reset(pxdsPr)
while hasdata(pxdsPr)
[D,info] = read(pxdsPr);
[~, filename, ext] = fileparts(info.Filename);
C = read(pxdsGT2);  
I = read(imds);   
B2 = labeloverlay(I,C{1, 1},'Colormap',KK,'Transparency',0);
f1=figure;
imshow(B2)
title('Ground Truth Labels')
movegui(f1,'northwest')
B3 = labeloverlay(I,D{1, 1},'Colormap',KK,'Transparency',0);
f2=figure;
imshow(B3)
title('Network Predicted Labels')
movegui(f2,'north')
BX=ModelHelperFunctions.PostProcess(D,classes);
BXX = labeloverlay(I, BX,'Colormap',KK,'Transparency',0); 
f3=figure;
imshow(BXX)
title('Postprocessed Labels')
movegui(f3,'northeast')
YY=uint8(C{1, 1});
BXA=uint8(D{1, 1});
BXB=uint8(BX);
f4=figure;
subplot(2,1,1)
AAA=imshowpair(YY,BXA,'Scaling','Joint','ColorChannels',[2 1 1]); 
title('w/o Postprocessing. Red (false positives) Cyan (false negatives)')
subplot(2,1,2)
AAB=imshowpair(YY,BXB,'Scaling','Joint','ColorChannels',[2 1 1]); 
title('with Postprocessing. Red (false positives) Cyan (false negatives)')
movegui(f4,'south')

[Choice] = ModelHelperFunctions.PostProcOpt;
if (strcmp(Choice,'Yes'))
    imwrite(BXB, fullfile(pdest, [filename '_Postprocessed' ext]))
    close all
elseif  (strcmp(Choice,'No'))
    imwrite(BXA, fullfile(pdest, [filename '_Postprocessed' ext]))
    close all 
end

end

