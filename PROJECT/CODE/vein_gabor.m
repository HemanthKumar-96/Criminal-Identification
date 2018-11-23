%% vein extraction%%%
function [J z sss]=vein_gabor(phi,theta,sigma,filterSize,en)
G = zeros(filterSize);
for i=(0:filterSize-1)/filterSize
    for j=(0:filterSize-filterSize)
        xprime= j*cos(phi);
        yprime= i*sin(phi);
        K = exp(2*pi*theta*sqrt(-1)*(xprime+ yprime));
        G(round((i+1)*filterSize),round((j+1)*filterSize)) = exp(-(i^2+j^2)/(sigma^2))*K;
    end
end

%%%% Convolve %%%%

J = conv2(double(en),double(G));
% figure,imshow(im2double(J),[]);

se1=strel('square',5);
z=imtophat(real(J),se1);
% figure,imshow(z);

m=size(z,1);
n=size(z,2);
r=zeros(m,n);
for x=1:m
    for y=1:n
        if z(x,y)>0
            r(x,y)=255;
        else
            r(x,y)=0;
        end
    end
end
% figure,imshow(r,[]);
sss=bwareaopen(r,55);