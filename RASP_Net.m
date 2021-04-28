function lgraph = RASP_Net(inputSize,numClasses,classes,classWeights)

[out]=ModelHelperFunctions.Maps;
[ASPPDR]=ModelHelperFunctions.ASPPMod;
DRate=[str2double(ASPPDR{1, 1}) str2double(ASPPDR{2, 1}) str2double(ASPPDR{3, 1}) str2double(ASPPDR{4, 1})];      

f1 = [1 1];
f3 = [3 3];
maps = str2double(out);
s1=[1 1];
s2=[2 2];
pw=[2 2];
ASPP1=8*maps/4;
ASPP2=ASPP1*2/4;
ASPP3=ASPP2*2/4;
ASPP4=ASPP3*2/4;


ExpResMod1 = [
  %%%%%%% Input Layer %%%%%%%%%%%
  imageInputLayer(inputSize, 'Normalization', 'none', 'Name', 'Input Layer')
  
  convolution2dLayer(f3, maps*4, 'Stride',s1,'Padding', 'same', 'Name', 'C1')
  batchNormalizationLayer('Name', 'BN1')
  reluLayer('Name', 'R1')
  
  %%%%%%% ExpRes Module 1 %%%%%%%%%%%  
  maxPooling2dLayer(pw, 'Stride', s2, 'Name', 'MP1')
  convolution2dLayer(f1, maps*2, 'Stride',s1,'Padding', 'same', 'Name', 'C2')
  batchNormalizationLayer('Name', 'BN2')
  reluLayer('Name', 'R2')
  convolution2dLayer(f3, maps*2, 'Stride',s1,'Padding', 'same', 'Name', 'C3')
  batchNormalizationLayer('Name', 'BN3')
  reluLayer('Name', 'R3')
  convolution2dLayer(f1, maps*8, 'Stride',s1,'Padding', 'same', 'Name', 'C4')
  batchNormalizationLayer('Name', 'BN4')
  additionLayer(2,'Name','addlayer1')

  reluLayer('Name', 'R4')
  
  convolution2dLayer(f1, maps*2, 'Stride',s1,'Padding', 'same', 'Name', 'C6')
  batchNormalizationLayer('Name', 'BN6')
  reluLayer('Name', 'R5')
  
  convolution2dLayer(f3, maps*2, 'Stride',s1,'Padding', 'same', 'Name', 'C7')
  batchNormalizationLayer('Name', 'BN7')
  reluLayer('Name', 'R6')
 
  convolution2dLayer(f1, maps*8, 'Stride',s1,'Padding', 'same', 'Name', 'C8')
  batchNormalizationLayer('Name', 'BN8')
  additionLayer(2,'Name','addlayer2')
  
  reluLayer('Name', 'R7')
  ];

lgraph = layerGraph(ExpResMod1);  

%%%%%%%%%% Skip Connections in ExpRes Module 1 %%%%%%%%%%%%%
sconv1 =[
      convolution2dLayer(f1, maps*8, 'Stride',s1,'Padding', 'same', 'Name', 'C5')
  batchNormalizationLayer('Name', 'BN5')
    ];

lgraph = addLayers(lgraph,sconv1);
lgraph = connectLayers(lgraph,'MP1','C5');
lgraph = connectLayers(lgraph,'BN5','addlayer1/in2');
lgraph = connectLayers(lgraph,'R4','addlayer2/in2'); 


%%%%%%% Add ASPP Mod 1 here %%%%%%%%%%%
lgraph  = addASPPToNetwork(lgraph, ASPP1,DRate);

function lgraph  = addASPPToNetwork(lgraph, ASPP1,DRate)
asppDilationFactors = DRate;
asppFilterSizes = [3,3,3,3];
lastLayerName = 'R7';

for i = 1: numel(asppDilationFactors)
    asppConvName = "asppM1C_" + string(i);
    asppBNName = "asppM1BN_" + string(i);
    asppRName = "asppM1R_" + string(i);

    branchFilterSize = asppFilterSizes(i);
    branchDilationFactor = asppDilationFactors(i);
    asspLayer  = [convolution2dLayer(branchFilterSize, ASPP1,'DilationFactor', branchDilationFactor,...
        'Padding','same','Name',asppConvName,'WeightsInitializer','narrow-normal','BiasInitializer','zeros')
    batchNormalizationLayer('Name', asppBNName)
    reluLayer('Name', asppRName)];
    lgraph = addLayers(lgraph,asspLayer);
    lgraph = connectLayers(lgraph,lastLayerName,asppConvName);
end

concat = depthConcatenationLayer(4,'Name','DepthConcatASPPM1');
lgraph = addLayers(lgraph,concat);
lgraph = connectLayers(lgraph,'asppM1R_1','DepthConcatASPPM1/in1');
lgraph = connectLayers(lgraph,'asppM1R_2','DepthConcatASPPM1/in2');
lgraph = connectLayers(lgraph,'asppM1R_3','DepthConcatASPPM1/in3');
lgraph = connectLayers(lgraph,'asppM1R_4','DepthConcatASPPM1/in4');  
  
end
  
  %%%%%%% ExpRes Module 2 %%%%%%%%%%%  
ExpResMod2 = [  
  maxPooling2dLayer(pw, 'Stride', s2, 'Name', 'MP2')
  
  convolution2dLayer(f1, maps*4, 'Stride',s1,'Padding', 'same', 'Name', 'C9')
  batchNormalizationLayer('Name', 'BN9')
  reluLayer('Name', 'R8')

  convolution2dLayer(f3, maps*4, 'Stride',s1,'Padding', 'same', 'Name', 'C10')
  batchNormalizationLayer('Name', 'BN10')
  reluLayer('Name', 'R9')

  convolution2dLayer(f1, maps*16, 'Stride',s1,'Padding', 'same', 'Name', 'C11')
  batchNormalizationLayer('Name', 'BN11')
  
  additionLayer(2,'Name','addlayer3')

  reluLayer('Name', 'R10')

  convolution2dLayer(f1, maps*4, 'Stride',s1,'Padding', 'same', 'Name', 'C13')
  batchNormalizationLayer('Name', 'BN13')
  reluLayer('Name', 'R11')

  convolution2dLayer(f3, maps*4, 'Stride',s1,'Padding', 'same', 'Name', 'C14')
  batchNormalizationLayer('Name', 'BN14')
  reluLayer('Name', 'R12')

  convolution2dLayer(f1, maps*16, 'Stride',s1,'Padding', 'same', 'Name', 'C15')
  batchNormalizationLayer('Name', 'BN15')  
  additionLayer(2,'Name','addlayer4')

  reluLayer('Name', 'R13')

  convolution2dLayer(f1, maps*4, 'Stride',s1,'Padding', 'same', 'Name', 'C16')
  batchNormalizationLayer('Name', 'BN16')
  reluLayer('Name', 'R14')

  convolution2dLayer(f3, maps*4, 'Stride',s1,'Padding', 'same', 'Name', 'C17')
  batchNormalizationLayer('Name', 'BN17')
  reluLayer('Name', 'R15')

  convolution2dLayer(f1, maps*16, 'Stride',s1,'Padding', 'same', 'Name', 'C18')
  batchNormalizationLayer('Name', 'BN18')  
  additionLayer(2,'Name','addlayer5')

  reluLayer('Name', 'R16')
  
  ];

lgraph = addLayers(lgraph,ExpResMod2);

%%%%%%%%%% Skip Connections in ExpRes Module 2 %%%%%%%%%%%%%

sconv2=[ convolution2dLayer(f1, maps*16, 'Stride',s1,'Padding', 'same', 'Name', 'C12')
  batchNormalizationLayer('Name', 'BN12')
  ];

lgraph = addLayers(lgraph,sconv2);

lgraph = connectLayers(lgraph,'MP2','C12');
lgraph = connectLayers(lgraph,'BN12','addlayer3/in2');
lgraph = connectLayers(lgraph,'R10','addlayer4/in2'); 
lgraph = connectLayers(lgraph,'R13','addlayer5/in2'); 
lgraph = connectLayers(lgraph,'DepthConcatASPPM1','MP2'); 


%%%%%%% Add ASPP Mod 2 here %%%%%%%%%%%
lgraph  = addASPPToNetwork2(lgraph, ASPP2,DRate);

function lgraph  = addASPPToNetwork2(lgraph, ASPP2,DRate)
asppDilationFactors = DRate;
asppFilterSizes = [3,3,3,3];
lastLayerName = 'R16';

for i = 1: numel(asppDilationFactors)
    asppConvName = "asppM2C_" + string(i);
    asppBNName = "asppM2BN_" + string(i);
    asppRName = "asppM2R_" + string(i);

    branchFilterSize = asppFilterSizes(i);
    branchDilationFactor = asppDilationFactors(i);
    asspLayer  = [convolution2dLayer(branchFilterSize, ASPP2,'DilationFactor', branchDilationFactor,...
        'Padding','same','Name',asppConvName,'WeightsInitializer','narrow-normal','BiasInitializer','zeros')
    batchNormalizationLayer('Name', asppBNName)
    reluLayer('Name', asppRName)];
    lgraph = addLayers(lgraph,asspLayer);
    lgraph = connectLayers(lgraph,lastLayerName,asppConvName);
end

concat = depthConcatenationLayer(4,'Name','DepthConcatASPPM2');
lgraph = addLayers(lgraph,concat);
lgraph = connectLayers(lgraph,'asppM2R_1','DepthConcatASPPM2/in1');
lgraph = connectLayers(lgraph,'asppM2R_2','DepthConcatASPPM2/in2');
lgraph = connectLayers(lgraph,'asppM2R_3','DepthConcatASPPM2/in3');
lgraph = connectLayers(lgraph,'asppM2R_4','DepthConcatASPPM2/in4');  
  
end

  %%%%%%% ExpRes Module 3 %%%%%%%%%%%  
ExpResMod3 = [  
  maxPooling2dLayer(pw, 'Stride', s2, 'Name', 'MP3')
  
  convolution2dLayer(f1, maps*8, 'Stride',s1,'Padding', 'same', 'Name', 'C19')
  batchNormalizationLayer('Name', 'BN19')
  reluLayer('Name', 'R17')

  convolution2dLayer(f3, maps*8, 'Stride',s1,'Padding', 'same', 'Name', 'C20')
  batchNormalizationLayer('Name', 'BN20')
  reluLayer('Name', 'R18')

  convolution2dLayer(f1, maps*32, 'Stride',s1,'Padding', 'same', 'Name', 'C21')
  batchNormalizationLayer('Name', 'BN21')

  additionLayer(2,'Name','addlayer6')
  
  reluLayer('Name', 'R19')

  convolution2dLayer(f1, maps*8, 'Stride',s1,'Padding', 'same', 'Name', 'C23')
  batchNormalizationLayer('Name', 'BN23')
  reluLayer('Name', 'R20')

  convolution2dLayer(f3, maps*8, 'Stride',s1,'Padding', 'same', 'Name', 'C24')
  batchNormalizationLayer('Name', 'BN24')
  reluLayer('Name', 'R21')

  convolution2dLayer(f1, maps*32, 'Stride',s1,'Padding', 'same', 'Name', 'C25')
  batchNormalizationLayer('Name', 'BN25')  
  additionLayer(2,'Name','addlayer7')
  
  reluLayer('Name', 'R22')

  convolution2dLayer(f1, maps*8, 'Stride',s1,'Padding', 'same', 'Name', 'C26')
  batchNormalizationLayer('Name', 'BN26')
  reluLayer('Name', 'R23')

  convolution2dLayer(f3, maps*8, 'Stride',s1,'Padding', 'same', 'Name', 'C27')
  batchNormalizationLayer('Name', 'BN27')
  reluLayer('Name', 'R24')

  convolution2dLayer(f1, maps*32, 'Stride',s1,'Padding', 'same', 'Name', 'C28')
  batchNormalizationLayer('Name', 'BN28')  
  additionLayer(2,'Name','addlayer8')

  reluLayer('Name', 'R25')

  convolution2dLayer(f1, maps*8, 'Stride',s1,'Padding', 'same', 'Name', 'C29')
  batchNormalizationLayer('Name', 'BN29')
  reluLayer('Name', 'R26')

  convolution2dLayer(f3, maps*8, 'Stride',s1,'Padding', 'same', 'Name', 'C30')
  batchNormalizationLayer('Name', 'BN30')
  reluLayer('Name', 'R27')

  convolution2dLayer(f1, maps*32, 'Stride',s1,'Padding', 'same', 'Name', 'C31')
  batchNormalizationLayer('Name', 'BN31')  
  additionLayer(2,'Name','addlayer9')
  
  
  reluLayer('Name', 'R28')
  
  ];

lgraph = addLayers(lgraph,ExpResMod3);

%%%%%%%%%% Skip Connections in ExpRes Module 3 %%%%%%%%%%%%%

sconv3=[  
  convolution2dLayer(f1, maps*32, 'Stride',s1,'Padding', 'same', 'Name', 'C22')
  batchNormalizationLayer('Name', 'BN22')
  ];

lgraph = addLayers(lgraph,sconv3);

lgraph = connectLayers(lgraph,'MP3','C22'); 
lgraph = connectLayers(lgraph,'BN22','addlayer6/in2'); 
lgraph = connectLayers(lgraph,'R19','addlayer7/in2'); 
lgraph = connectLayers(lgraph,'R22','addlayer8/in2'); 
lgraph = connectLayers(lgraph,'R25','addlayer9/in2'); 
lgraph = connectLayers(lgraph,'DepthConcatASPPM2','MP3'); 



%%%%%%% Add ASPP Mod 3 here %%%%%%%%%%%
lgraph  = addASPPToNetwork3(lgraph, ASPP3,DRate);

function lgraph  = addASPPToNetwork3(lgraph, ASPP3,DRate)
asppDilationFactors = DRate;
asppFilterSizes = [3,3,3,3];
lastLayerName = 'R28';

for i = 1: numel(asppDilationFactors)
    asppConvName = "asppM3C_" + string(i);
    asppBNName = "asppM3BN_" + string(i);
    asppRName = "asppM3R_" + string(i);

    branchFilterSize = asppFilterSizes(i);
    branchDilationFactor = asppDilationFactors(i);
    asspLayer  = [convolution2dLayer(branchFilterSize, ASPP3,'DilationFactor', branchDilationFactor,...
        'Padding','same','Name',asppConvName,'WeightsInitializer','narrow-normal','BiasInitializer','zeros')
    batchNormalizationLayer('Name', asppBNName)
    reluLayer('Name', asppRName)];
    lgraph = addLayers(lgraph,asspLayer);
    lgraph = connectLayers(lgraph,lastLayerName,asppConvName);
end

concat = depthConcatenationLayer(4,'Name','DepthConcatASPPM3');
lgraph = addLayers(lgraph,concat);
lgraph = connectLayers(lgraph,'asppM3R_1','DepthConcatASPPM3/in1');
lgraph = connectLayers(lgraph,'asppM3R_2','DepthConcatASPPM3/in2');
lgraph = connectLayers(lgraph,'asppM3R_3','DepthConcatASPPM3/in3');
lgraph = connectLayers(lgraph,'asppM3R_4','DepthConcatASPPM3/in4');  
  
end


  %%%%%%% ExpRes Module 4 %%%%%%%%%%%  
ExpResMod4 = [  
  maxPooling2dLayer(pw, 'Stride', s2, 'Name', 'MP4')
  
  convolution2dLayer(f1, maps*16, 'Stride',s1,'Padding', 'same', 'Name', 'C32')
  batchNormalizationLayer('Name', 'BN32')
  reluLayer('Name', 'R29')

  convolution2dLayer(f3, maps*16, 'Stride',s1,'Padding', 'same', 'Name', 'C33')
  batchNormalizationLayer('Name', 'BN33')
  reluLayer('Name', 'R30')

  convolution2dLayer(f1, maps*64, 'Stride',s1,'Padding', 'same', 'Name', 'C34')
  batchNormalizationLayer('Name', 'BN34')

  additionLayer(2,'Name','addlayer10')

  reluLayer('Name', 'R31')

  convolution2dLayer(f1, maps*16, 'Stride',s1,'Padding', 'same', 'Name', 'C36')
  batchNormalizationLayer('Name', 'BN36')
  reluLayer('Name', 'R32')

  convolution2dLayer(f3, maps*16, 'Stride',s1,'Padding', 'same', 'Name', 'C37')
  batchNormalizationLayer('Name', 'BN37')
  reluLayer('Name', 'R33')

  convolution2dLayer(f1, maps*64, 'Stride',s1,'Padding', 'same', 'Name', 'C38')
  batchNormalizationLayer('Name', 'BN38')  
  additionLayer(2,'Name','addlayer11')

  reluLayer('Name', 'R34')

  convolution2dLayer(f1, maps*16, 'Stride',s1,'Padding', 'same', 'Name', 'C39')
  batchNormalizationLayer('Name', 'BN39')
  reluLayer('Name', 'R35')

  convolution2dLayer(f3, maps*16, 'Stride',s1,'Padding', 'same', 'Name', 'C40')
  batchNormalizationLayer('Name', 'BN40')
  reluLayer('Name', 'R36')

  convolution2dLayer(f1, maps*64, 'Stride',s1,'Padding', 'same', 'Name', 'C41')
  batchNormalizationLayer('Name', 'BN41')  
  additionLayer(2,'Name','addlayer12')
  

  reluLayer('Name', 'R37')

  convolution2dLayer(f1, maps*16, 'Stride',s1,'Padding', 'same', 'Name', 'C42')
  batchNormalizationLayer('Name', 'BN42')
  reluLayer('Name', 'R38')

  convolution2dLayer(f3, maps*16, 'Stride',s1,'Padding', 'same', 'Name', 'C43')
  batchNormalizationLayer('Name', 'BN43')
  reluLayer('Name', 'R39')

  convolution2dLayer(f1, maps*64, 'Stride',s1,'Padding', 'same', 'Name', 'C44')
  batchNormalizationLayer('Name', 'BN44')  
  additionLayer(2,'Name','addlayer13')
    
  reluLayer('Name', 'R40')

  convolution2dLayer(f1, maps*16, 'Stride',s1,'Padding', 'same', 'Name', 'C45')
  batchNormalizationLayer('Name', 'BN45')
  reluLayer('Name', 'R41')

  convolution2dLayer(f3, maps*16, 'Stride',s1,'Padding', 'same', 'Name', 'C46')
  batchNormalizationLayer('Name', 'BN46')
  reluLayer('Name', 'R42')

  convolution2dLayer(f1, maps*64, 'Stride',s1,'Padding', 'same', 'Name', 'C47')
  batchNormalizationLayer('Name', 'BN47')  
  additionLayer(2,'Name','addlayer14')
  
  reluLayer('Name', 'R43')

  
  ];

lgraph = addLayers(lgraph,ExpResMod4);

%%%%%%%%%% Skip Connections in ExpRes Module 4 %%%%%%%%%%%%%

sconv4=[  convolution2dLayer(f1, maps*64, 'Stride',s1,'Padding', 'same', 'Name', 'C35')
  batchNormalizationLayer('Name', 'BN35')
  ];
 lgraph = addLayers(lgraph,sconv4);

lgraph = connectLayers(lgraph,'MP4','C35'); 
lgraph = connectLayers(lgraph,'BN35','addlayer10/in2'); 
lgraph = connectLayers(lgraph,'R31','addlayer11/in2'); 
lgraph = connectLayers(lgraph,'R34','addlayer12/in2'); 
lgraph = connectLayers(lgraph,'R37','addlayer13/in2'); 
lgraph = connectLayers(lgraph,'R40','addlayer14/in2'); 
lgraph = connectLayers(lgraph,'DepthConcatASPPM3','MP4'); 




%%%%%%% Add ASPP Mod 4 here %%%%%%%%%%%
lgraph  = addASPPToNetwork4(lgraph, ASPP4,DRate);

function lgraph  = addASPPToNetwork4(lgraph, ASPP4,DRate)
asppDilationFactors = DRate;
asppFilterSizes = [3,3,3,3];
lastLayerName = 'R43';

for i = 1: numel(asppDilationFactors)
    asppConvName = "asppM4C_" + string(i);
    asppBNName = "asppM4BN_" + string(i);
    asppRName = "asppM4R_" + string(i);

    branchFilterSize = asppFilterSizes(i);
    branchDilationFactor = asppDilationFactors(i);
    asspLayer  = [convolution2dLayer(branchFilterSize, ASPP4,'DilationFactor', branchDilationFactor,...
        'Padding','same','Name',asppConvName,'WeightsInitializer','narrow-normal','BiasInitializer','zeros')
    batchNormalizationLayer('Name', asppBNName)
    reluLayer('Name', asppRName)];
    lgraph = addLayers(lgraph,asspLayer);
    lgraph = connectLayers(lgraph,lastLayerName,asppConvName);
end

concat = depthConcatenationLayer(4,'Name','DepthConcatASPPM4');
lgraph = addLayers(lgraph,concat);
lgraph = connectLayers(lgraph,'asppM4R_1','DepthConcatASPPM4/in1');
lgraph = connectLayers(lgraph,'asppM4R_2','DepthConcatASPPM4/in2');
lgraph = connectLayers(lgraph,'asppM4R_3','DepthConcatASPPM4/in3');
lgraph = connectLayers(lgraph,'asppM4R_4','DepthConcatASPPM4/in4');  
  
end

%%%%%%%%% Feature Decoder %%%%%%%%%%%

upsamp1 =[
      convolution2dLayer(f1, maps*32, 'Stride',s1,'Padding', 'same', 'Name', 'DC1')
  batchNormalizationLayer('Name', 'DBN1')
  reluLayer('Name', 'DR1') 
    ];
lgraph = addLayers(lgraph,upsamp1);
lgraph = connectLayers(lgraph,'DepthConcatASPPM4','DC1');

upsamp2 =transposedConv2dLayer([7 7],maps*32,'Stride',[2,2],'Cropping',[2 2 2 3],'Name','Trans_DC1');
lgraph = addLayers(lgraph,upsamp2);
lgraph = connectLayers(lgraph,'DR1','Trans_DC1');

crop1 = crop2dLayer('centercrop','Name','Dcrop1');
lgraph = addLayers(lgraph,crop1);
lgraph = connectLayers(lgraph,'Trans_DC1','Dcrop1/in');
lgraph = connectLayers(lgraph,'DepthConcatASPPM3','Dcrop1/ref');

upsamp3 =[
      convolution2dLayer(f1, maps*16, 'Stride',s1,'Padding', 'same', 'Name', 'DC2')
  batchNormalizationLayer('Name', 'DBN2')
  reluLayer('Name', 'DR2') 
    ];
lgraph = addLayers(lgraph,upsamp3);
lgraph = connectLayers(lgraph,'Dcrop1','DC2');

upsamp4 =[
      convolution2dLayer(f1, maps*16, 'Stride',s1,'Padding', 'same', 'Name', 'DC3')
  batchNormalizationLayer('Name', 'DBN3')
  reluLayer('Name', 'DR3') 
    ];
lgraph = addLayers(lgraph,upsamp4);
lgraph = connectLayers(lgraph,'DR2','DC3');


upsamp5 =transposedConv2dLayer([7 7],maps*16,'Stride',[2,2],'Cropping','same','Name','Trans_DC2');
lgraph = addLayers(lgraph,upsamp5);
lgraph = connectLayers(lgraph,'DR3','Trans_DC2');


crop2 = crop2dLayer('centercrop','Name','Dcrop2');
lgraph = addLayers(lgraph,crop2);
lgraph = connectLayers(lgraph,'Trans_DC2','Dcrop2/in');
lgraph = connectLayers(lgraph,'DepthConcatASPPM2','Dcrop2/ref');


upsamp6 =[
      convolution2dLayer(f1, maps*8, 'Stride',s1,'Padding', 'same', 'Name', 'DC4')
  batchNormalizationLayer('Name', 'DBN4')
  reluLayer('Name', 'DR4') 
    ];
lgraph = addLayers(lgraph,upsamp6);
lgraph = connectLayers(lgraph,'Dcrop2','DC4');

upsamp7 =[
      convolution2dLayer(f1, maps*8, 'Stride',s1,'Padding', 'same', 'Name', 'DC5')
  batchNormalizationLayer('Name', 'DBN5')
  reluLayer('Name', 'DR5') 
    ];
lgraph = addLayers(lgraph,upsamp7);
lgraph = connectLayers(lgraph,'DR4','DC5');

upsamp8 =[
      convolution2dLayer(f1, maps*8, 'Stride',s1,'Padding', 'same', 'Name', 'DC6')
  batchNormalizationLayer('Name', 'DBN6')
  reluLayer('Name', 'DR6') 
    ];
lgraph = addLayers(lgraph,upsamp8);
lgraph = connectLayers(lgraph,'DR5','DC6');


upsamp9 =transposedConv2dLayer([7 7],maps*8,'Stride',[2,2],'Cropping','same','Name','Trans_DC3');
lgraph = addLayers(lgraph,upsamp9);
lgraph = connectLayers(lgraph,'DR6','Trans_DC3');


crop3 = crop2dLayer('centercrop','Name','Dcrop3');
lgraph = addLayers(lgraph,crop3);
lgraph = connectLayers(lgraph,'Trans_DC3','Dcrop3/in');
lgraph = connectLayers(lgraph,'DepthConcatASPPM1','Dcrop3/ref');




upsamp10 =[
      convolution2dLayer(f1, maps*4, 'Stride',s1,'Padding', 'same', 'Name', 'DC7')
  batchNormalizationLayer('Name', 'DBN7')
  reluLayer('Name', 'DR7') 
    ];
lgraph = addLayers(lgraph,upsamp10);
lgraph = connectLayers(lgraph,'Dcrop3','DC7');

upsamp11 =[
      convolution2dLayer(f1, maps*4, 'Stride',s1,'Padding', 'same', 'Name', 'DC8')
  batchNormalizationLayer('Name', 'DBN8')
  reluLayer('Name', 'DR8') 
    ];
lgraph = addLayers(lgraph,upsamp11);
lgraph = connectLayers(lgraph,'DR7','DC8');

upsamp12 =[
      convolution2dLayer(f1, maps*4, 'Stride',s1,'Padding', 'same', 'Name', 'DC9')
  batchNormalizationLayer('Name', 'DBN9')
  reluLayer('Name', 'DR9') 
    ];
lgraph = addLayers(lgraph,upsamp12);
lgraph = connectLayers(lgraph,'DR8','DC9');

upsamp13 =[
      convolution2dLayer(f1, maps*4, 'Stride',s1,'Padding', 'same', 'Name', 'DC10')
  batchNormalizationLayer('Name', 'DBN10')
  reluLayer('Name', 'DR10') 
    ];
lgraph = addLayers(lgraph,upsamp13);
lgraph = connectLayers(lgraph,'DR9','DC10');



upsamp14 =transposedConv2dLayer([7 7],maps*4,'Stride',[2,2],'Cropping','same','Name','Trans_DC4');
lgraph = addLayers(lgraph,upsamp14);
lgraph = connectLayers(lgraph,'DR10','Trans_DC4');


crop4 = crop2dLayer('centercrop','Name','Dcrop4');
lgraph = addLayers(lgraph,crop4);
lgraph = connectLayers(lgraph,'Trans_DC4','Dcrop4/in');
lgraph = connectLayers(lgraph,'R1','Dcrop4/ref');


upsamp15 =[
      convolution2dLayer(f1, maps*4, 'Stride',s1,'Padding', 'same', 'Name', 'DC11')
  batchNormalizationLayer('Name', 'DBN11')
  reluLayer('Name', 'DR11') 
    ];
lgraph = addLayers(lgraph,upsamp15);
lgraph = connectLayers(lgraph,'Dcrop4','DC11');

upsamp16 =[
      convolution2dLayer(f1, numClasses, 'Stride',s1,'Padding', 'same', 'Name', 'scorer')
    ];
lgraph = addLayers(lgraph,upsamp16);
lgraph = connectLayers(lgraph,'DR11','scorer');

crop5 = crop2dLayer('centercrop','Name','Dcrop5');
lgraph = addLayers(lgraph,crop5);
lgraph = connectLayers(lgraph,'scorer','Dcrop5/in');
lgraph = connectLayers(lgraph,'Input Layer','Dcrop5/ref');


sm = softmaxLayer('Name','softmax');
lgraph = addLayers(lgraph,sm);
lgraph = connectLayers(lgraph,'Dcrop5','softmax');

pxlayer = pixelClassificationLayer('Name','pixel_classification','Classes',classes,'ClassWeights',classWeights);
lgraph = addLayers(lgraph,pxlayer);
lgraph = connectLayers(lgraph,'softmax','pixel_classification');



end
