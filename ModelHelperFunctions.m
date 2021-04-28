classdef ModelHelperFunctions < handle
    
properties
end
    
methods(Static)
    
function out = Maps

prompt = {'Choose Base Maps (8,16,32,64,128)'};
dlgtitle = 'Maps';
dims = [1 70];
answer = inputdlg(prompt,dlgtitle,dims);
AA=answer{1, 1};
if (strcmp(AA,'8')) || (strcmp(AA,'16')) || (strcmp(AA,'32')) || (strcmp(AA,'64')) || (strcmp(AA,'128'))
    out=AA;
else
    ModelHelperFunctions.Error;
    out=0;
end  
end


function Error
    d = dialog('Position',[300 300 250 150],'Name','Error!');

    txt = uicontrol('Parent',d,...
               'Style','text',...
               'Position',[20 80 210 40],...
               'String','Please Choose the Valid Number');

    btn = uicontrol('Parent',d,...
               'Position',[85 20 70 25],...
               'String','Close',...
               'Callback','delete(gcf)');
end



function answer = ASPPMod

prompt = {'Dilation Rate for 1st Branch (E.g. 1)','Dilation Rate for 2nd Branch (E.g. 6)','Dilation Rate for 3rd Branch (E.g. 12)','Dilation Rate for 4th Branch (E.g. 18)'};
dlgtitle = 'Dilation Rates for ASPP Modules';
definput = {'1','6','12','18'};
dims = [1 70];
answer = inputdlg(prompt,dlgtitle,dims,definput); 
end

function F = sorting(folder)      
S = [dir(fullfile(folder,'*.jpg'));dir(fullfile(folder,'*.jpeg'));dir(fullfile(folder,'*.TIF'));dir(fullfile(folder,'*.TIFF'));dir(fullfile(folder,'*.png'))];
N = natsortfiles({S.name});
F = cellfun(@(n)fullfile(folder,n),N,'uni',0);
F=F';
end


function [imdsTrain, imdsVal, imdsTest, pxdsTrain, pxdsVal, pxdsTest] = Partition(imds,pxds, labelIDs)
rng(0); 
numFiles = numel(imds.Files);
shuffledIndices = randperm(numFiles);
N = round(0.60 * numFiles);
trainingIdx = shuffledIndices(1:N);
numVal = round(0.20 * numFiles);
valIdx = shuffledIndices(N+1:N+numVal);
testIdx = shuffledIndices(N+numVal+1:end);
trainingImages = imds.Files(trainingIdx);
valImages = imds.Files(valIdx);
testImages = imds.Files(testIdx);
save('Idx','trainingIdx','valIdx','testIdx')
imdsTrain = imageDatastore(trainingImages);
imdsVal = imageDatastore(valImages);
imdsTest = imageDatastore(testImages);
classes = pxds.ClassNames;
trainingLabels = pxds.Files(trainingIdx);
valLabels = pxds.Files(valIdx);
testLabels = pxds.Files(testIdx);
pxdsTrain = pixelLabelDatastore(trainingLabels, classes, labelIDs);
pxdsVal = pixelLabelDatastore(valLabels, classes, labelIDs);
pxdsTest = pixelLabelDatastore(testLabels, classes, labelIDs);
end




function choice = Training

    d = dialog('Position',[300 300 250 150],'Name','Select Training Option');
    txt = uicontrol('Parent',d,...
           'Style','text',...
           'Position',[20 80 210 40],...
           'String','Do You Want to Train the Model');
       
    popup = uicontrol('Parent',d,...
           'Style','popup',...
           'Position',[75 70 100 25],...
           'String',{'Select One';'Yes, Train Model';'No, Load Trained Model'},...
           'Callback',@popup_callback);
       
    btn = uicontrol('Parent',d,...
           'Position',[89 20 70 25],...
           'String','Close',...
           'Callback','delete(gcf)');
       
    choice = 'Select One';
       
    uiwait(d);
   
       function popup_callback(popup,event)
          idx = popup.Value;
          popup_items = popup.String;
          choice = char(popup_items(idx,:));
       end
end        


function TrainingError
    d = dialog('Position',[300 300 250 150],'Name','Error!');

    txt = uicontrol('Parent',d,...
               'Style','text',...
               'Position',[20 80 210 40],...
               'String','Please Choose the Training Option');

    btn = uicontrol('Parent',d,...
               'Position',[85 20 70 25],...
               'String','Close',...
               'Callback','delete(gcf)');
end



function NetworkError
    d = dialog('Position',[300 300 250 150],'Name','Error!');

    txt = uicontrol('Parent',d,...
               'Style','text',...
               'Position',[20 80 210 40],...
               'String','Trained Network or Test IDs Not Found. Please Train the Model First');

    btn = uicontrol('Parent',d,...
               'Position',[85 20 70 25],...
               'String','Close',...
               'Callback','delete(gcf)');
end



function options = TrainOpt(pximdsVal)

prompt = {'Select Optimizer (sgdm, rmsprop, adam)','Total Epochs (E.g. 80)',...
    'Mini-batch Size (E.g. 32)','Validation Frequency (E.g. 100)',...
    'Initial learning rate (E.g. 0.2)','Drop Rate After (E.g. 30)', ...
    'Drop Rate Factor (E.g. 0.1)','L2 Regularization (E.g. 0.001)'};
dlgtitle = 'Training Hyper-parameters';
definput = {'sgdm','80','32','100','0.2','30','0.1','0.001'};
dims = [1 70];
answer = inputdlg(prompt,dlgtitle,dims,definput); 
options = trainingOptions(lower(answer{1, 1}), ... 
    'MaxEpochs', str2double(answer{2, 1}),...       
    'MiniBatchSize', str2double(answer{3, 1}), ... 
    'ValidationData',pximdsVal,...
    'ValidationFrequency',str2double(answer{4, 1}), ...   
    'InitialLearnRate', str2double(answer{5, 1}), ...    
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropPeriod',str2double(answer{6, 1}),...
    'LearnRateDropFactor',str2double(answer{7, 1}),...
    'L2Regularization', str2double(answer{8, 1}), ...   
    'Shuffle', 'every-epoch', ...  
    'Verbose', false,...        
    'Plots','training-progress');  

end        
        
function CopySegLab(folder,pdest)
ldir=[dir(fullfile(folder,'*.jpg'));dir(fullfile(folder,'*.jpeg'));dir(fullfile(folder,'*.TIF'));dir(fullfile(folder,'*.TIFF'));dir(fullfile(folder,'*.png'))];
ldir([ldir.isdir]) = [];
for k = 1:numel(ldir)
    sourceFile = fullfile(folder, ldir(k).name);
    destFile   = fullfile(pdest, ldir(k).name); 
    copyfile(sourceFile, destFile);
end

end


function Out = PostProcess (D,classes)
D=D{1, 1};
b0=D=='BG';
b0=uint8(b0);
b0(b0==1)=15;
%%%% Healthy Class %%%%
K=D=='H';
b1=uint8(K);
%%%% IRF Class %%%%
K=D=='IRF';
se = strel('line',3,90);
erodedBW = imerode(K,se);
BW2 = bwareaopen(erodedBW, 40);
windowSize = 9;
kernel = ones(windowSize) / windowSize ^ 2;
blurryImage = conv2(single(BW2), kernel, 'same');
b2 = blurryImage > 0.8;
b2=uint8(b2);
b2(b2==1)=2;
%%%% SRF Class %%%%
K=D=='SRF';
BW2 = bwareaopen(K, 30);
windowSize = 5;
kernel = ones(windowSize) / windowSize ^ 2;
blurryImage = conv2(single(BW2), kernel, 'same');
b3 = blurryImage > 0.8;
b3=uint8(b3);
b3(b3==1)=3;
%%%% PED Class %%%%
K=D=='PED';
BW2 = bwareaopen(K, 55);
se = strel('disk',2,6);
erodedBW = imerode(BW2,se);
windowSize = 5;
kernel = ones(windowSize) / windowSize ^ 2;
blurryImage = conv2(single(erodedBW), kernel, 'same');
b9 = blurryImage > 0.6;
b9=uint8(b9);
b9(b9==1)=4;
%%%% RPD Class %%%%
K=D=='RPD';
BW2 = bwareaopen(K, 30);
se = strel('line',10,45);
erodedBW = imerode(BW2,se);
se = strel('disk',2,6);
BW2 = imdilate(erodedBW,se);
windowSize = 5;
kernel = ones(windowSize) / windowSize ^ 2;
blurryImage = conv2(single(BW2), kernel, 'same');
b4 = blurryImage > 0.7;
b4=uint8(b4);
b4(b4==1)=5;
%%%% HF Class %%%%
K=D=='HF';
BW2 = bwareaopen(K, 30);
se = strel('disk',2,6);
BW2 = imdilate(BW2,se);
se = strel('line',5,45);
BW2 = imerode(BW2,se);
windowSize = 3;
kernel = ones(windowSize) / windowSize ^ 2;
blurryImage = conv2(single(BW2), kernel, 'same');
b5 = blurryImage > 0.95;
b5=uint8(b5);
b5(b5==1)=6;
%%%% GA Class %%%%
K=D=='GA';
BW2 = bwareaopen(K, 85);
se = strel('disk',4,6);
erodedBW = imerode(BW2,se);
windowSize = 11;
kernel = ones(windowSize) / windowSize ^ 2;
blurryImage = conv2(single(erodedBW), kernel, 'same');
b6 = blurryImage > 0.5;
b6=uint8(b6);
b6(b6==1)=7;
%%%% FCE Class %%%%
K=D=='FCE';
BW2 = bwareaopen(K, 80);
se = strel('disk',8,6);
BW2 = imerode(BW2,se);
windowSize = 9;
kernel = ones(windowSize) / windowSize ^ 2;
blurryImage = conv2(single(BW2), kernel, 'same');
b8 = blurryImage > 0.8;
b8=uint8(b8);
b8(b8==1)=8;
%%%% VMT Class %%%%
K=D=='VMT';
BW2 = bwareaopen(K, 30);
windowSize = 3;
kernel = ones(windowSize) / windowSize ^ 2;
blurryImage = conv2(single(BW2), kernel, 'same');
b10 = blurryImage > 0.75;
b10=uint8(b10);
b10(b10==1)=9;
%%%% ERM Class %%%%
K=D=='ERM';
BW2 = bwareaopen(K, 15);
windowSize = 3;
kernel = ones(windowSize) / windowSize ^ 2;
blurryImage = conv2(single(BW2), kernel, 'same');
b7 = blurryImage > 0.8;
b7=uint8(b7);
b7(b7==1)=10;
%%%% CNVM Class %%%%
K=D=='CNVM';
BW2 = bwareaopen(K, 40);
se = strel('disk',4,6);
erodedBW = imerode(BW2,se);
windowSize = 13;
kernel = ones(windowSize) / windowSize ^ 2;
blurryImage = conv2(single(erodedBW), kernel, 'same');
b11 = blurryImage > 0.8;
b11=uint8(b11);
b11(b11==1)=11;
BB=b0+b1+b2+b3+b4+b5+b6+b7+b8+b9+b10+b11;
nanLinearIndexes = find(BB==0);
nonNanLinearIndexes = setdiff(1:numel(BB), nanLinearIndexes);
[xGood, yGood, zGood] = ind2sub(size(BB), nonNanLinearIndexes);
for index = 1 : length(nanLinearIndexes)
  thisLinearIndex = nanLinearIndexes(index);
  [x,y,z] = ind2sub(size(BB), thisLinearIndex);
  distances = sqrt((x-xGood).^2 + (y - yGood) .^ 2 + (z - zGood) .^ 2);
  [sortedDistances, sortedIndexes] = sort(distances, 'ascend');
  indexOfClosest = sortedIndexes(1);
  goodValue = BB(xGood(indexOfClosest), yGood(indexOfClosest), zGood(indexOfClosest));
  BB(x,y,z) = goodValue;
end
nanLocations = isnan(BB);
numberOfNans = sum(nanLocations(:));
BB(BB==15)=0;
valueset = [0:11];
BX = categorical(BB,valueset,classes,'Ordinal',true);
Out=BX; 

end


function choice = PostProcOpt

    d = dialog('Position',[300 300 250 150],'Name','Select Training Option');
    txt = uicontrol('Parent',d,...
           'Style','text',...
           'Position',[20 80 210 40],...
           'String','Is Postprocessed Scan Better than the Network Predicted Scan?');
       
    popup = uicontrol('Parent',d,...
           'Style','popup',...
           'Position',[75 70 100 25],...
           'String',{'Yes';'No'},...
           'Callback',@popup_callback);
       
    btn = uicontrol('Parent',d,...
           'Position',[89 20 70 25],...
           'String','Close',...
           'Callback','delete(gcf)');
       
    choice = 'Yes';
       
    uiwait(d);
   
       function popup_callback(popup,event)
          idx = popup.Value;
          popup_items = popup.String;
          choice = char(popup_items(idx,:));
       end
end        


function LabelsError
    d = dialog('Position',[300 300 250 150],'Name','Error!');

    txt = uicontrol('Parent',d,...
               'Style','text',...
               'Position',[20 80 210 40],...
               'String','Ground Truth or Postprocessed Labels are Missing');

    btn = uicontrol('Parent',d,...
               'Position',[85 20 70 25],...
               'String','Close',...
               'Callback','delete(gcf)');
end


function [AreasPred, TotalAreaPred] = ThreeDRecons(CC,KKE,KKF,PredLabels,classes,QuantDir)
Mask = CC == 'H';
Mask2=im2double(Mask);
Mask2n=zeros(size(Mask2(:,:,1)));
area=0;
for i=1:1:length(PredLabels)
Mask2n=Mask2n+Mask2(:,:,i);
area=area+bwarea(Mask(:,:,i));
end
Mask2n = flip(Mask2n,1);
ind=find(Mask2n~=0);
[x,y]=ind2sub(size(Mask2n),ind);
z=Mask2n(ind);
x1=x(1:0.01:length(x));
y1=y(1:0.01:length(x));
z1=z(1:0.01:length(x));
shp=alphaShape(y1,x1,z1);
shp1=shp;


Mask = CC == 'IRF';
Mask2=im2double(Mask);
Mask2n=zeros(size(Mask2(:,:,1)));
area2=0;
for i=1:1:length(PredLabels)
Mask2n=Mask2n+Mask2(:,:,i);
area2=area2+bwarea(Mask(:,:,i));
end
Mask2n = flip(Mask2n,1);
ind=find(Mask2n~=0);
[x,y]=ind2sub(size(Mask2n),ind);
z=Mask2n(ind);
x1=x(1:0.01:length(x));
y1=y(1:0.01:length(x));
z1=z(1:0.01:length(x));
shp=alphaShape(y1,x1,z1);
shp2=shp;


Mask = CC == 'SRF';
Mask2=im2double(Mask);
Mask2n=zeros(size(Mask2(:,:,1)));
area3=0;
for i=1:1:length(PredLabels)
Mask2n=Mask2n+Mask2(:,:,i);
area3=area3+bwarea(Mask(:,:,i));
end
Mask2n = flip(Mask2n,1);
ind=find(Mask2n~=0);
[x,y]=ind2sub(size(Mask2n),ind);
z=Mask2n(ind);
x1=x(1:0.01:length(x));
y1=y(1:0.01:length(x));
z1=z(1:0.01:length(x));
shp=alphaShape(y1,x1,z1);
shp3=shp;


Mask = CC == 'PED';
Mask2=im2double(Mask);
Mask2n=zeros(size(Mask2(:,:,1)));
area4=0;
for i=1:1:length(PredLabels)
Mask2n=Mask2n+Mask2(:,:,i);
area4=area4+bwarea(Mask(:,:,i));
end
Mask2n = flip(Mask2n,1);
ind=find(Mask2n~=0);
[x,y]=ind2sub(size(Mask2n),ind);
z=Mask2n(ind);
x1=x(1:0.01:length(x));
y1=y(1:0.01:length(x));
z1=z(1:0.01:length(x));
shp=alphaShape(y1,x1,z1);
shp4=shp;


Mask = CC == 'RPD';
Mask2=im2double(Mask);
Mask2n=zeros(size(Mask2(:,:,1)));
area5=0;
for i=1:1:length(PredLabels)
Mask2n=Mask2n+Mask2(:,:,i);
area5=area5+bwarea(Mask(:,:,i));
end
Mask2n = flip(Mask2n,1);
ind=find(Mask2n~=0);
[x,y]=ind2sub(size(Mask2n),ind);
z=Mask2n(ind);
x1=x(1:0.01:length(x));
y1=y(1:0.01:length(x));
z1=z(1:0.01:length(x));
shp=alphaShape(y1,x1,z1);
shp5=shp;


Mask = CC == 'HF';
Mask2=im2double(Mask);
Mask2n=zeros(size(Mask2(:,:,1)));
area6=0;
for i=1:1:length(PredLabels)
Mask2n=Mask2n+Mask2(:,:,i);
area6=area6+bwarea(Mask(:,:,i));
end
Mask2n = flip(Mask2n,1);
ind=find(Mask2n~=0);
[x,y]=ind2sub(size(Mask2n),ind);
z=Mask2n(ind);
x1=x(1:0.01:length(x));
y1=y(1:0.01:length(x));
z1=z(1:0.01:length(x));
shp=alphaShape(y1,x1,z1);
shp6=shp;


Mask = CC == 'GA';
Mask2=im2double(Mask);
Mask2n=zeros(size(Mask2(:,:,1)));
area7=0;
for i=1:1:length(PredLabels)
Mask2n=Mask2n+Mask2(:,:,i);
area7=area7+bwarea(Mask(:,:,i));
end
Mask2n = flip(Mask2n,1);
ind=find(Mask2n~=0);
[x,y]=ind2sub(size(Mask2n),ind);
z=Mask2n(ind);
x1=x(1:0.01:length(x));
y1=y(1:0.01:length(x));
z1=z(1:0.01:length(x));
shp=alphaShape(y1,x1,z1);
shp7=shp;


Mask = CC == 'FCE';
Mask2=im2double(Mask);
Mask2n=zeros(size(Mask2(:,:,1)));
area8=0;
for i=1:1:length(PredLabels)
Mask2n=Mask2n+Mask2(:,:,i);
area8=area8+bwarea(Mask(:,:,i));
end
Mask2n = flip(Mask2n,1);
ind=find(Mask2n~=0);
[x,y]=ind2sub(size(Mask2n),ind);
z=Mask2n(ind);
x1=x(1:0.01:length(x));
y1=y(1:0.01:length(x));
z1=z(1:0.01:length(x));
shp=alphaShape(y1,x1,z1);
shp8=shp;


Mask = CC == 'VMT';
Mask2=im2double(Mask);
Mask2n=zeros(size(Mask2(:,:,1)));
area9=0;
for i=1:1:length(PredLabels)
Mask2n=Mask2n+Mask2(:,:,i);
area9=area9+bwarea(Mask(:,:,i));
end
Mask2n = flip(Mask2n,1);
ind=find(Mask2n~=0);
[x,y]=ind2sub(size(Mask2n),ind);
z=Mask2n(ind);
x1=x(1:0.01:length(x));
y1=y(1:0.01:length(x));
z1=z(1:0.01:length(x));
shp=alphaShape(y1,x1,z1);
shp9=shp;


Mask = CC == 'ERM';
Mask2=im2double(Mask);
Mask2n=zeros(size(Mask2(:,:,1)));
area10=0;
for i=1:1:length(PredLabels)
Mask2n=Mask2n+Mask2(:,:,i);
area10=area10+bwarea(Mask(:,:,i));
end
Mask2n = flip(Mask2n,1);
ind=find(Mask2n~=0);
[x,y]=ind2sub(size(Mask2n),ind);
z=Mask2n(ind);
x1=x(1:0.01:length(x));
y1=y(1:0.01:length(x));
z1=z(1:0.01:length(x));
shp=alphaShape(y1,x1,z1);
shp10=shp;


Mask = CC == 'CNVM';
Mask2=im2double(Mask);
Mask2n=zeros(size(Mask2(:,:,1)));
area11=0;
for i=1:1:length(PredLabels)
Mask2n=Mask2n+Mask2(:,:,i);
area11=area11+bwarea(Mask(:,:,i));
end
Mask2n = flip(Mask2n,1);
ind=find(Mask2n~=0);
[x,y]=ind2sub(size(Mask2n),ind);
z=Mask2n(ind);
x1=x(1:0.01:length(x));
y1=y(1:0.01:length(x));
z1=z(1:0.01:length(x));
shp=alphaShape(y1,x1,z1);
shp11=shp;

AreasPred=[area area2 area3 area4 area5 area6 area7 area8 area9 area10 area11];
Shapes={shp1 shp2 shp3 shp4 shp5 shp6 shp7 shp8 shp9 shp10 shp11};
FaceAlphas=[0.2 0.5 0.4 0.4 0.4 0.3 0.8 1 0.8 0.7 0.7];
EdgeAlphas=[0.1 0.7 0.7 0.7 0.7 0.4 0.5 0.5 0.5 0.5 0.5];
TotalAreaPred=sum(AreasPred);
[EffArea,EffInd]=sort(AreasPred,'descend');
QuantPred=EffArea/TotalAreaPred*100;
nonzero=find(EffArea~=0);
FigH = figure('Position', get(0, 'Screensize'));
for i=1:1:numel(nonzero)
    plot(Shapes{1, (EffInd(i))},'FaceColor',KKF((EffInd(i)+1),:,:),'EdgeColor',KKE((EffInd(i)+1),:,:),'FaceAlpha',FaceAlphas((EffInd(i))),'EdgeAlpha',EdgeAlphas((EffInd(i))),'DisplayName',strcat(num2str(QuantPred(i)),'%',classes(EffInd(i)+1)));
    hold on
end
hold off
legend ('Location','northwest') 
xlabel('x-axis')
ylabel('y-axis')
zlabel('B-scans')
xlim([0 480])
ylim([0 360])
zlim([0 length(PredLabels)])
xticks('auto')
xticklabels('auto')
set(gca,'FontSize',12,'FontWeight','bold','xminorgrid','on','yminorgrid','on','zminorgrid','on')
F    = getframe(FigH);
imwrite(F.cdata, fullfile(QuantDir, '3D Macular Profile.png'));

end


function [QGt,QPr,QD] = QuantificationFunc(CC,GTLabels,AreasPred, TotalAreaPred)
Mask = CC == 'H';
area=0;
for i=1:1:length(GTLabels)
area=area+bwarea(Mask(:,:,i));
end

Mask = CC == 'IRF';
area2=0;
for i=1:1:length(GTLabels)
area2=area2+bwarea(Mask(:,:,i));
end

Mask = CC == 'SRF';
area3=0;
for i=1:1:length(GTLabels)
area3=area3+bwarea(Mask(:,:,i));
end

Mask = CC == 'PED';
area4=0;
for i=1:1:length(GTLabels)
area4=area4+bwarea(Mask(:,:,i));
end

Mask = CC == 'RPD';
area5=0;
for i=1:1:length(GTLabels)
area5=area5+bwarea(Mask(:,:,i));
end

Mask = CC == 'HF';
area6=0;
for i=1:1:length(GTLabels)
area6=area6+bwarea(Mask(:,:,i));
end

Mask = CC == 'GA';
area7=0;
for i=1:1:length(GTLabels)
area7=area7+bwarea(Mask(:,:,i));
end

Mask = CC == 'FCE';
area8=0;
for i=1:1:length(GTLabels)
area8=area8+bwarea(Mask(:,:,i));
end

Mask = CC == 'VMT';
area9=0;
for i=1:1:length(GTLabels)
area9=area9+bwarea(Mask(:,:,i));
end

Mask = CC == 'ERM';
area10=0;
for i=1:1:length(GTLabels)
area10=area10+bwarea(Mask(:,:,i));
end

Mask = CC == 'CNVM';
area11=0;
for i=1:1:length(GTLabels)
area11=area11+bwarea(Mask(:,:,i));
end

AreasGT=[area area2 area3 area4 area5 area6 area7 area8 area9 area10 area11];
TotalAreaGT=sum(AreasGT);

HArea=AreasPred(1)/TotalAreaPred*100;
IRFArea=AreasPred(2)/TotalAreaPred*100;
SRFArea=AreasPred(3)/TotalAreaPred*100;
PEDArea=AreasPred(4)/TotalAreaPred*100;
RPDArea=AreasPred(5)/TotalAreaPred*100;
HFArea=AreasPred(6)/TotalAreaPred*100;
GAArea=AreasPred(7)/TotalAreaPred*100;
FCEArea=AreasPred(8)/TotalAreaPred*100;
VMTArea=AreasPred(9)/TotalAreaPred*100;
ERMArea=AreasPred(10)/TotalAreaPred*100;
CNVMArea=AreasPred(11)/TotalAreaPred*100;
QPr=[HArea IRFArea SRFArea PEDArea RPDArea HFArea GAArea FCEArea VMTArea ERMArea CNVMArea];

HAreaGT=AreasGT(1)/TotalAreaGT*100;
IRFAreaGT=AreasGT(2)/TotalAreaGT*100;
SRFAreaGT=AreasGT(3)/TotalAreaGT*100;
PEDAreaGT=AreasGT(4)/TotalAreaGT*100;
RPDAreaGT=AreasGT(5)/TotalAreaGT*100;
HFAreaGT=AreasGT(6)/TotalAreaGT*100;
GAAreaGT=AreasGT(7)/TotalAreaGT*100;
FCEAreaGT=AreasGT(8)/TotalAreaGT*100;
VMTAreaGT=AreasGT(9)/TotalAreaGT*100;
ERMAreaGT=AreasGT(10)/TotalAreaGT*100;
CNVMAreaGT=AreasGT(11)/TotalAreaGT*100;
QGt=[HAreaGT IRFAreaGT SRFAreaGT PEDAreaGT RPDAreaGT HFAreaGT GAAreaGT FCEAreaGT VMTAreaGT ERMAreaGT CNVMAreaGT];

DiffH=abs(HAreaGT-HArea);
DiffIRF=abs(IRFAreaGT-IRFArea);
DiffSRF=abs(SRFAreaGT-SRFArea);
DiffPED=abs(PEDAreaGT-PEDArea);
DiffRPD=abs(RPDAreaGT-RPDArea);
DiffHF=abs(HFAreaGT-HFArea);
DiffGA=abs(GAAreaGT-GAArea);
DiffFCE=abs(FCEAreaGT-FCEArea);
DiffVMT=abs(VMTAreaGT-VMTArea);
DiffERM=abs(ERMAreaGT-ERMArea);
DiffCNVM=abs(CNVMAreaGT-CNVMArea);
QD=[DiffH DiffIRF DiffSRF DiffPED DiffRPD DiffHF DiffGA DiffFCE DiffVMT DiffERM DiffCNVM];


end


end
end