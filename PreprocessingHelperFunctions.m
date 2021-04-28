classdef PreprocessingHelperFunctions < handle
    
properties
end
    
methods(Static)
    
function choice = VMT

    d = dialog('Position',[300 300 250 150],'Name','Select One');
    txt = uicontrol('Parent',d,...
           'Style','text',...
           'Position',[20 80 210 40],...
           'String','Does this Scan Contain VMT CRBM?');
       
    popup = uicontrol('Parent',d,...
           'Style','popup',...
           'Position',[75 70 100 25],...
           'String',{'Select One';'Yes';'No'},...
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


function Error
    d = dialog('Position',[300 300 250 150],'Name','Error!');

    txt = uicontrol('Parent',d,...
               'Style','text',...
               'Position',[20 80 210 40],...
               'String','Please Mark the Presence of VMT CRBM in Each Scan');

    btn = uicontrol('Parent',d,...
               'Position',[85 20 70 25],...
               'String','Close',...
               'Callback','delete(gcf)');
end


function F = sorting(folder)      
S = [dir(fullfile(folder,'*.jpg'));dir(fullfile(folder,'*.jpeg'));dir(fullfile(folder,'*.TIF'));dir(fullfile(folder,'*.TIFF'));dir(fullfile(folder,'*.png'))];
N = natsortfiles({S.name});
F = cellfun(@(n)fullfile(folder,n),N,'uni',0);
F=F';
end


function Out = denoise1(In)
    A=In;      
    I=A;
    if(size(I,3) == 3)
        I=rgb2gray(I);
    end
    I(I>253)=1;
    I(1:10,:)=1;
    I(end-10:end,:)=1;
    sz=size(I);
    dima=round(sz(1)/20);
    dimb=round(sz(2)/20);
    I = wiener2(I,[20 20]);
    I=imadjust(I,stretchlim(I),[]);
    I=imfill(I,'holes');
    I=imcomplement(imfill(imcomplement(I),'holes'));
    I=imresize(I,[360 480]);
    I=ATMED(I,13);
    I=uint8(I);
    I(I<25)=1;      
    I = wiener2(I,[round(dima/2) 1]);
    I = wiener2(I,[1 round(dimb/2)]);
    U=mean(I);
    UU=mean(U);
    T=UU;
    T2=(UU+(UU/6));
    T3=(UU+(UU/4));
    T4=(UU+(UU/2));
    I(I<T)=1;
    I(I<T2)=I(I<T2).*0.05;
    I(I<T3)=I(I<T3).*0.2;
    I(I<T4)=I(I<T4).*0.85;
    Out=I;    
end

  
function [Out, Out2] = denoise2(In,Mask,PP)     
    A=In;
    I=A;
    if(size(I,3) == 3)
        I=rgb2gray(I);
    end
    I(I>253)=1;
    I=imcomplement(imfill(imcomplement(I),'holes'));
    I=imresize(I,[360 480]);
    OOO=I;
    I = wiener2(I,[10 10]);
    DS= imnlmfilt(In,'DegreeOfSmoothing',10, 'SearchWindowSize', 25, 'ComparisonWindowSize', 17);
    DS(DS>250)=1;
    DS=imresize(DS,[360 480]);
    DS(300:end,:)=OOO(300:end,:);
    DS=imadjust(DS,stretchlim(DS),[]);
    I=DS;
    [Rl, Cl] = find(Mask==1);
    yyy = find(all(Mask == 1,2));
    Ri = Rl';
    Ci = Cl';
    for i=1:length(Ri)
        I(Ri(1,i),Ci(1,i))=1;
    end
    MMM = mean(I,2);
    MMM2 = mean(MMM(1:numel(yyy)));
    I(I<MMM2+MMM2/2)=1;
    I = adapthisteq(I);
    [Rl, Cl] = find(Mask==0);
    Ri = Rl';
    Ci = Cl';
    for i=1:length(Ri)
        PP(Ri(1,i),Ci(1,i))=I(Ri(1,i),Ci(1,i));
    end      
    Out=PP;
    Out2=DS;
end


function [Out,Out2] = Layer(In,In1,In2)
    K=In;
    M=In;
    s3=In1;
    Khargosh=In2;
    s3 = double(s3>1.84*(mean(s3(:))));
    sTImg = edge(s3,'canny');
    first = zeros(1,length(sTImg(1,:))-20);
    second = zeros(1,length(sTImg(1,:))-20);
    M=zeros(size(M));
    lastPointX=0;
    lastPointY=0;
    f = 0;
    s = 0;
    for i=1:1:length(sTImg(1,:))
        p1=find(sTImg(:,i)~=0,1,'first');
        p2=find(sTImg(:,i)~=0,1,'last');   
        if(~isempty(p1) && ~isempty(p2))
            first(1,i) = p1 + 10;
            second(1,i) = p2 + 10;
            f = [f first(1,i)];
            s = [s second(1,i)];
            if(i - 1 == 1)
                lastPointX = first(1,i);
                lastPointY = second(1,i);
            end
            if(i - 1 > 1)
                dist1(i) = sqrt((i-i-1).^2 + (first(1,i)-lastPointX).^2);
                dist2(i) = sqrt((i-i-1).^2 + (second(1,i)-lastPointY).^2);           
            if(dist1(i) < 25)
                lastPointX = first(1,i);
            else
                first(1,i) = NaN;
            end
            if(dist2(i) < 25)
                lastPointY = second(1,i);
            else
                second(1,i) = NaN;
            end
            end
        end
    end
    if(first(1,1) == 0)
        first(1,1) = NaN;
    end
    if(first(1,length(first)) == 0)
        first(1,length(first)) = NaN;
    end
    x=(1:length(first));y=(first);
    xi=x(find(~isnan(y)));yi=y(find(~isnan(y)));
    first=interp1(xi,yi,x,'pchip');
    if(second(1,1) == 0)
        second(1,1) = NaN;
    end
    if(second(1,length(second)) == 0)
        second(1,length(second)) = NaN;
    end
    x=(1:length(second));y=(second);
    xi=x(find(~isnan(y)));yi=y(find(~isnan(y)));
    second=interp1(xi,yi,x,'linear');
    x1 = 0:1:length(first);
    x2 = 0:1:length(second);
    y1 = spline(1:length(first),first-2,x1);
    y2 = spline(1:length(second),second,x2);
    y1=smooth(y1);y1=smooth(y1);y1=smooth(y1);y1=smooth(y1);y1=smooth(y1);
    y1=smooth(y1);y1=smooth(y1);y1=smooth(y1);y1=smooth(y1);y1=smooth(y1);
    y2n=y2(1:4:end);
    y2n(end+1)=y2(end);
    x2n=x2(1:4:end);
    x2n(end+1)=x2(end);    
    p = polyfit(x2n,y2n,3);
    y2 = polyval(p,x2);
    y22=y2;
    y11=y1';
    sTImg = zeros(length(M(:,1)),length(M(1,:)));
    STIMGG=sTImg;
    for i = 1:1:length(y22)
        if(~isnan(y22(1,i)) && ~isnan(y11(1,i)) && y11(1,i) > 0 && y22(1,i) > 0)
            sTImg(y11(1,i)-5:y22(1,i)-10,i) = 1;
        end
    end
    Gosha=sTImg+K;
    [Rl, Cl] = find(Gosha==0);
    Ri = Rl';
    Ci = Cl';
    for i=1:length(Ri)
        Khargosh(Ri(1,i),Ci(1,i))=Gosha(Ri(1,i),Ci(1,i));       
    end
    yend=360*ones([1 length(y11)]);
    sTImg2 = zeros(length(M(:,1)),length(M(1,:)));
    for i = 1:1:length(yend)
        if(~isnan(yend(1,i)) && ~isnan(y11(1,i)) && y11(1,i) > 0 && yend(1,i) > 0)
            sTImg2(y11(1,i)-5:yend(1,i),i) = 1;
        end
    end
    sTImg2(end-10:end,:)=1;
    Out=Khargosh;
    Out2=sTImg2;             
end      
      
    
function Out = morph(In)
    img=In;
    h = fspecial('unsharp'); %smooting filter
    I2 = imfilter(img,h);
    I2 = wiener2(img,[3 3]);
    se1 = strel('line', 5, 90); 
    Io = imopen(img, se1);
    Ie = imerode(Io, se1);
    Iobr = imreconstruct(Ie, I2);
    Iobr = imadjust(Iobr,[0.2 0.4],[]);
    se = strel('sphere', 5);
    Iobrd = imdilate(Iobr, se);
    Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
    Iobrcbr = imcomplement(Iobrcbr);
    h = ones(8,8) / 50;
    img = imfilter(Iobrcbr,h);
    h = fspecial('unsharp');
    I2 = imfilter(Iobrcbr,h);
    A=adapthisteq(I2);
    se = strel('line',5, 180);
    A = imerode (A,se);
    img = double(A>1.04*(mean(A(:))));
    img=im2bw(img);
    img = bwareafilt(img,1);
    img1 = imdilate(img, se);
    Out=img1;
end      
        
    
function [s1, s2, s3] = ST(In)
    M=In;
    [s1, s2, s3] = structureTensor(M,2,2);
    s1 = mat2gray(s1);
    s2 = mat2gray(s2);
    s3 = mat2gray(s3);
    img=M;
    s3=3*(s3+s2+s1);
    diffX = length(s3(:,1))-length(img(:,1));
    diffY = length(s3(1,:))-length(img(1,:));
    s3 = imcrop(s3, [diffY./2 0 (length(s3(1,:))-diffX-1) (length(s3(:,1)))]);
    s3 = imcrop(s3,[10 0 length(s3(1,:))-20 length(s3(:,1))]);
    s3 = imresize(s3,size(M),'bilinear');
    [fx fy] = gradient(s3);
    s3 = 1* sqrt(fx.^2+fy.^2);
end      
        
        
function Out = Enhance(In)
    I=In;
    I= imnlmfilt(I,'DegreeOfSmoothing',15, 'SearchWindowSize', 5, 'ComparisonWindowSize', 5);
    E = adapthisteq(I);  
    Out=E;       
end



function choice = Properly

    d = dialog('Position',[300 300 250 150],'Name','Select One');
    txt = uicontrol('Parent',d,...
           'Style','text',...
           'Position',[20 80 210 40],...
           'String','Is This Scan Properly Preprocessed?');
       
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


function Manually
    d = dialog('Position',[300 300 250 150],'Name','Note!');

    txt = uicontrol('Parent',d,...
               'Style','text',...
               'Position',[20 80 210 40],...
               'String','Please Preprocess This Scan Later by Manually Altering the Parameter Values!');

    btn = uicontrol('Parent',d,...
               'Position',[85 20 70 25],...
               'String','Close',...
               'Callback','delete(gcf)');
end



end
end