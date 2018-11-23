function [VEI,VV]=vein_match(g,f,sss)
for ii=1:3
name = sprintf('%d.tif',ii); 
II{ii} =imread(name); 
figure,imshow(II{ii});
KI=II{ii};

ptsOriginalv  = detectSURFFeatures(sss);
ptsDistortedv = detectSURFFeatures(KI);      
[featuresInv,validPtsInv]  = extractFeatures(sss,  ptsOriginalv);
[featuresOutv,validPtsOutv]  = extractFeatures(KI, ptsDistortedv);  
index_pairsv = matchFeatures(featuresInv, featuresOutv);
matchedOriginalv{ii}  = validPtsInv(index_pairsv(:,1));
matchedDistortedv = validPtsOutv(index_pairsv(:,2));
cvexShowMatches(sss,KI,matchedOriginalv{ii},matchedDistortedv);
title('VEIN MATCHING');

VOO=0;
for i=1:g
    for j=1:f
        if sss(i,j)==KI(i,j)
            VO=1;
        else
            VO=0;
        end
        VOO=VOO+VO;
    end
end
V(ii)=VOO/(g*f);
end

texx=0;

for ii=1:3
[MO{ii} N] = size(matchedOriginalv{ii});
    if MO{ii}>5
texx=1;
    VV=ii;
    VEI=max(V);
   end
end


if texx~=1
    VEI=0;
    VV=0;
end
