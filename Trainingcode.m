clc
clear all
close all
addpath(genpath(pwd))

imgDir = fullfile(pwd,'Preprocessed');
labelDir = fullfile(pwd,'Ground Truth Labels');
PredDir = fullfile(pwd,'Predicted Labels');
classes = ["BG" "H" "IRF" "SRF" "PED" "RPD" "HF" "GA" "FCE" "VMT" "ERM" "CNVM"];
labelIDs =[1 2 3 4 5 6 7 8 9 10 11 12]; 
[Choice] = ModelHelperFunctions.Training;
if (strcmp(Choice,'Yes, Train Model'))
numClasses = numel(classes);
SortLabelsImds = ModelHelperFunctions.sorting(imgDir);
imds = imageDatastore(SortLabelsImds);
inputSize = size(read(imds));
SortLabels = ModelHelperFunctions.sorting(labelDir);
pxds = pixelLabelDatastore(SortLabels,classes,labelIDs);
[imdsTrain, imdsVal, imdsTest, pxdsTrain, pxdsVal, pxdsTest] = ModelHelperFunctions.Partition(imds,pxds, labelIDs);
tbl = countEachLabel(pxds);
frequency = tbl.PixelCount/sum(tbl.PixelCount);
imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
classWeights = median(imageFreq) ./ imageFreq;
lgraph = RASP_Net(inputSize,numClasses,classes,classWeights);
pximdsVal = pixelLabelImageDatastore(imdsVal,pxdsVal,'OutputSize',inputSize);
pximds = pixelLabelImageDatastore(imdsTrain,pxdsTrain,'OutputSize',inputSize);
[options]=ModelHelperFunctions.TrainOpt(pximdsVal);
tic
[net, info] = trainNetwork(pximds,lgraph,options);
toc
save('TrainedNet.mat','net','info','options');
disp('NN trained');
pxdsPred = semanticseg(imdsTest,net,'WriteLocation',PredDir,'NamePrefix','PredLabel');
elseif  (strcmp(Choice,'No, Load Trained Model'))
    if isfile('TrainedNet.mat') && isfile('Idx.mat')   
        load('Idx.mat')
        SortLabels = ModelHelperFunctions.sorting(imgDir);
        imds1 = imageDatastore(SortLabels);
        testLabels = imds1.Files(testIdx);
        imdsTest = imageDatastore(testLabels);
        NN=load('TrainedNet.mat');
        TNet=NN.net; 
        pxdsPred = semanticseg(imdsTest,TNet,'WriteLocation',PredDir,'NamePrefix','PredLabel');
    else
        ModelHelperFunctions.NetworkError;
    end
else
    ModelHelperFunctions.TrainingError;
    return
end







