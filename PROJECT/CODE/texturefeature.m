 
function [mu,ent]=texturefeature(yyy)

%%
%%%%%%%%% TEXTURE ANALYSIS %%%%%%%%%

%%%1.MEAN%%%%%
mu=mean2(yyy);

%%%2.ENTROPY %%%%%
ent=entropy(yyy);

end