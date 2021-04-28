clear all
close all

addpath(genpath(pwd))
imgDir = fullfile(pwd,'Raw Scans');
PPDir=fullfile(pwd,'Preprocessed');
pdest=fullfile(pwd,'Resized Scans');
SortLabelsImds = ModelHelperFunctions.sorting(imgDir);
imds = imageDatastore(SortLabelsImds);

reset(imds)
while hasdata(imds)
[I,info] = read(imds);
if(size(I,3) == 3)
   Ia=rgb2gray(I);
else
   Ia=I;
end
Ia=imresize(Ia,[360 480]);
[~, filename, ext] = fileparts(info.Filename);
imwrite(Ia, fullfile(pdest, [filename '_Resized' ext]))
figure, imshow(Ia)
[Choice] = PreprocessingHelperFunctions.VMT;
close
if (strcmp(Choice,'No'))
    [A] = PreprocessingHelperFunctions.denoise1(I);
    [B]  = PreprocessingHelperFunctions.morph(A);
    [s1, s2, s3] = PreprocessingHelperFunctions.ST(B);
    [C,C2] = PreprocessingHelperFunctions.Layer(B,s3,Ia);
    [D] = PreprocessingHelperFunctions.Enhance(C);
    II=imresize(D, [360 480]);
    II = cat(3, II, II, II);
    figure
    montage({Ia, II})
    title('Original Scan (left), Preprocessed Scan (right)')
    [Choice] = PreprocessingHelperFunctions.Properly;
    if (strcmp(Choice,'Yes'))
        imwrite(II, fullfile(imgDir, [filename '_Preprocessed' ext]))
        movefile(fullfile(imgDir, [filename '_Preprocessed' ext]),PPDir)
        close all
    else
        PreprocessingHelperFunctions.Manually;     
        close all
    end

elseif  (strcmp(Choice,'Yes'))
    [A] = PreprocessingHelperFunctions.denoise1(I);
    [B]  = PreprocessingHelperFunctions.morph(A);
    [s1, s2, s3] = PreprocessingHelperFunctions.ST(B);
    [C,C2] = PreprocessingHelperFunctions.Layer(B,s3,Ia);
    [D] = PreprocessingHelperFunctions.Enhance(C);
    [E] = PreprocessingHelperFunctions.denoise2(Ia,C2,D);
    II=imresize(E, [360 480]);
    II = cat(3, II, II, II);
    figure
    montage({Ia, II})
    title('Original Scan (left), Preprocessed Scan (right)')
    [Choice] = PreprocessingHelperFunctions.Properly;
    if (strcmp(Choice,'Yes'))
        imwrite(II, fullfile(imgDir, [filename '_Preprocessed' ext]))
        movefile(fullfile(imgDir, [filename '_Preprocessed' ext]),PPDir)
        close all
    else
        PreprocessingHelperFunctions.Manually;     
        close all
    end
   
else
    PreprocessingHelperFunctions.Error;
    break
end
end

