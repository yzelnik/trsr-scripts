function [avgsp,ind] = avgshortpath(mat,maxdist)
% average distance (shortest path) in a network?
if(nargin<2) maxdist = 200; end;

len = length(mat);

% prepare 2 matrices we will work with
mat=real(mat);
tmpmat=eye(len); 

% setup the connectivity histogram
conhist=zeros(1,maxdist);
conhist(1)=len;

% initilize for loop
curcon=len;
ind=1;
% while we (have not connected everytying) and (have not reached max
% iteration) and (keep connecting more sites)
while(curcon<len^2) && (ind<=maxdist) && (conhist(ind)>0)
    tmpmat=(mat*tmpmat)>0;  % add more paths
    curcon=nnz(tmpmat);     % how many paths do we have?

    conhist(ind+1) = curcon-sum(conhist(1:ind)); % the change from last time
    ind=ind+1;
end;

% if we haven't reached everything, just give it the maximum distance
if(curcon<len^2);
    conhist(ind+1) = len^2-conhist(ind);
    ind=ind+1;
end;

if(conhist(ind-1)>0) 
    avgsp=sum(conhist.*(1:length(conhist)))/(len*(len-1));
else
    avgsp=inf; % if the last step nothing was added, it means the network is disconnected
end


end