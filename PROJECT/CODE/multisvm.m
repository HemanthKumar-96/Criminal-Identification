function [result] = multisvm(TrainingSet,GroupTrain,TestSet,AR,mu,ent)
%Models a given training set with a corresponding group vector and 
%classifies a given test set using an SVM classifier according to a 
%one vs. all relation. 


u=unique(GroupTrain);
numClasses=length(u);
result = zeros(length(TestSet(:,1)),1);

%build models
for k=1:numClasses
    %Vectorized statement that binarizes Group
    %where 1 is the current class and 0 is all other classes
    G1vAll=(GroupTrain==u(k));
    models(k) = svmtrain(TrainingSet,G1vAll);
end

%classify test cases
for j=1:size(TestSet,1)
    for k=1:numClasses
        if(svmclassify(models(k),TestSet(j,:))) 
            break;
        end
    end
    result(j) = k;
     

if gt(AR,349)&& le(AR,500) && gt(mu,0.1896)&& le(mu,0.2562) && gt(ent,3.7054)&& le(ent,4.3716)
     msgbox('Skin Matched');
     disp('Skin Matched');
     msgbox('This skin belongs to criminal person-1');
     disp('This skin belongs to criminal person-1');
     
elseif gt(AR,160)&& le(AR,202) && gt(mu,0.1163)&& le(mu,0.1317) && gt(ent,2.4757)&& le(ent,2.7047)
     msgbox('Skin image Matched');
     disp('Skin image Matched');
     msgbox('This skin belongs to criminal person-2');
     disp('This skin belongs to criminal person-2');

elseif gt(AR,240)&& le(AR,320) && gt(mu,0.1404)&& le(mu,0.1496) && gt(ent,2.9783)&& le(ent,3.5060)
     msgbox('Skin image Matched');
     disp('Skin image Matched');
     msgbox('This skin belongs to criminal person-3');
     disp('This skin belongs to criminal person-3');

else
     msgbox('Skin image not Matched');
     disp('Skin image not Matched');
    msgbox('This skin not belongs to registered criminals');
    disp('This skin not belongs to registered criminals');
end  
end