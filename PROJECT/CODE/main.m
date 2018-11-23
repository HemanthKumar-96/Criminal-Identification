warning ('off')
clc;
clear all;
close all;

%%% READING INPUT IMAGE%%%
[filename,pathname]=uigetfile( {'*.png'; '*.bmp';'*.tif';'*.jpg'});
RGB=imread([pathname filename]);
figure,imshow(RGB,[]);
title('original image');
impixelinfo;

%% CHANNEL SEPARATION %%%
red=RGB(:,:,1);
green=RGB(:,:,2);
blue=RGB(:,:,3);

figure,imshow(red,[]);
title('red channel image');
impixelinfo;

figure,imshow(green,[]);
title('green channel image');
impixelinfo;

figure,imshow(blue,[]);
title('blue channel image');
impixelinfo;

%% rgb to ycbcr conversion %%%
YCbCr=rgb2ycbcr(RGB);
figure,imshow(YCbCr,[]);
title('ycbcr color space');

%%% Apply Gray world Compensation to the Input
GYCbCr=grayworld(YCbCr);
GRGB=(ycbcr2rgb(GYCbCr));
figure,imshow(GRGB,[]);
title('Gray World Algorithm Applied output')

Y=GYCbCr(:,:,1);
Cb=GYCbCr(:,:,2);
Cr=GYCbCr(:,:,3);

figure,imshow(Y,[]);
title('luminance color image');

figure,imshow(Cb,[]);
title('Chrominance-Cb color image');

figure,imshow(Cr,[]);
title('Chrominance-Cr color image');

%% NORMALIZED RGB COLOR SPACE %%%

Gred=RGB(:,:,1);
Ggreen=RGB(:,:,2);
Gblue=RGB(:,:,3);

normRGB = uint8(zeros(size(RGB,1), size(RGB,2), size(RGB,3)));

redd=im2double(Gred);
greend=im2double(Ggreen);
blued=im2double(Gblue);

rm = mean(mean(redd));
gm = mean(mean(greend));
bm = mean(mean(blued));

normR = redd./(sqrt((redd).^2 + (greend).^2 + (blued).^2));
figure,imshow(normR,[]);
title('Normalized Red channel image');

normG = greend./(sqrt((redd).^2 + (greend).^2 + (blued).^2));
figure,imshow(normR,[]);
title('Normalized green channel image');

normB = blued./(sqrt((redd).^2 + (greend).^2 + (blued).^2));
figure,imshow(normB,[]);
title('Normalized blue channel image');

normRU=im2uint8(normR);
normGU=im2uint8(normG);
normBU=im2uint8(normB);

normRGB(:,:,1)=normRU;
normRGB(:,:,2)=normGU;
normRGB(:,:,3)=normBU;

figure,imshow(normRGB);
title('Normalized RGB channel image');
%% MEAN FILTER %%%
%%% mean filter-red channel%%

filtCr= imfilter(Cr, fspecial('average', [3 3]));
figure,imshow(filtCr,[])
title('MEAN FILTERED Cr image')


filtnR= imfilter(normRU, fspecial('average', [3 3]));
figure,imshow(filtnR,[])
title('MEAN FILTERED normalized Red image')

filtnG= imfilter(normGU, fspecial('average', [3 3]));
figure,imshow(filtnG,[])
title('MEAN FILTERED normalized green image')

filtnB= imfilter(normBU, fspecial('average', [3 3]));
figure,imshow(filtnB,[])
title('MEAN FILTERED normalized blue image')


%% FUZZY C-MEANS SEGMENTATION %%%
[FCMse1,FCMseg1]=fuzzycmeans(filtCr);
figure,imshow(FCMse1,[])
title('FCM segmented image-1')
impixelinfo;

figure,imshow(FCMseg1,[])
title('FCM segmented Cr image-1')
impixelinfo;

[FCMse2,FCMseg2]=fuzzycmeans(filtnR);
figure,imshow(FCMse2,[])
title('FCM segmented image-2')
impixelinfo;

figure,imshow(FCMseg2,[])
title('FCM segmented Red channel image-2')
impixelinfo;

%%% SKIN MASKING IN BINARY FORM OF IMAGE %%%
[rr,rc]=size(FCMseg1);
FCMmask1= uint8(zeros(size(FCMseg1,1), size(FCMseg1,2), size(FCMseg1,3)));
for ri=1:rr
    for rj=1:rc
        if FCMseg1(ri,rj)==200
            FCMmask1(ri,rj)=1;
        elseif FCMseg1(ri,rj)==1
            FCMmask1(ri,rj)=0;
        end
    end
end

figure,imshow(FCMmask1,[]);
title('actual Skin segmented image');

FCMmask2=bwareaopen(FCMmask1,300);
figure,imshow(FCMmask2,[]);
title('unwanted objects removed image');

FCMmask=imfill(FCMmask2,'holes');
figure,imshow(FCMmask,[]);
title('Skin segmented mask image');


%% MASKING-skin segmentation and background removal %%%
%%% masking the segmented image with the input image to form skin %%% 
%%% segmented image %%%
ROIvr=RGB;
ROIvr(~FCMmask)=0;
figure,imshow(ROIvr);
title('skin segmented and background removed image');
impixelinfo;

RROIvr=ROIvr(:,:,1);
GROIvr=ROIvr(:,:,2);
BROIvr=ROIvr(:,:,3);


[mr,mc]=size(RROIvr);
% FCMmask= uint8(zeros(size(FCMseg1,1), size(FCMseg1,2), size(FCMseg1,3)));
for mi=1:mr
    for mj=1:mc
        if RROIvr(mi,mj)==0
            GROIvr(mi,mj)=0;
            BROIvr(mi,mj)=0;
        else
        end
    end
end

ROIout(:,:,1)=RROIvr;
ROIout(:,:,2)=GROIvr;
ROIout(:,:,3)=BROIvr;

figure,imshow(ROIout,[]);
title('Skin segmented image');


%%% RPPVSM DETECTION %%%
%%% 1.blue channel normalization %%%
bluesk=ROIout(:,:,3);
figure,imshow(bluesk,[]);
title('blue channel skin image');

bluenorm=im2double(bluesk);
figure,imshow(bluenorm,[]);
title('normalized blue channel image');
[rnb cnb]=size(bluenorm);

%%%2.homomorphic filtering %%%%
d=10;
order=2;
bluenormd=double(bluesk);
im_e=homofil(bluenormd,d,rnb,cnb,order);

%%% 3.multiscale LoG filtering %%% 
hsize=[5 5];
sigma=0.5;
h = fspecial('log', hsize, sigma);
LOGfiltout=imfilter(im_e,h);
figure,imshow(LOGfiltout);
title('LoG filtered image');

level=graythresh(LOGfiltout);
thr=im2bw(LOGfiltout,level);
figure,imshow(thr);
title('Thresholded image');

%% %% FEATURE EXTRACTION %%%%%
ROIoutd=im2double(ROIout);
g=regionprops(ROIout,'all');

g1=extractfield(g,'Area');
[g11,index11]=max(g1);
AR=round(g11);
 
%%% texture feature %%%
[mu,ent]=texturefeature(ROIoutd);

%% VEIN PATTERN EXTRACTION %%%
%%%% IMAGE ENHANCEMENT %%%%

for i=1:3
enh=adapthisteq(ROIout(:,:,i));
en(:,:,i)=imadjust(enh);
end
figure,imshow(en,[]);
title('enhanced color skin image');

ROIoutg=rgb2gray(ROIout);
figure,imshow(ROIoutg,[]);
title('enhanced skin image');
impixelinfo;

en1=adapthisteq(ROIoutg);
figure,imshow(en1);
title('ENHANCED SKIN IMAGE');

%%%% FEATURE EXTRACTION %%%%

phi = 7*pi/4;
theta = 15;
sigma = 8*theta;
filterSize = 11;
[J1,z1,sss]=vein_gabor(phi,theta,sigma,filterSize,en1);
figure,imshow(sss,[]);
title('VEIN EXTRACTED PATTERN IMAGE');

%%% VEIN MATCHING %%%%
[g f]=size(sss);
[VEI,VV]=vein_match(g,f,sss);

%% %%% CLASSIFICATION%%%%
Train_Feat=[359,0.1897,3.7055;198,0.1254,2.6373;303,0.1436,2.9784]; 
Train_Label=[1;2;3]; 
TestSet=[AR,mu,ent];
result=multisvm(Train_Feat,Train_Label,TestSet,AR,mu,ent);
