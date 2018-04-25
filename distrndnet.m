function [mat,pnts]=distrndnet(netsize,netprms)
% Create a basic network structure (mat) - randomly choose inside radius
% node number is netsize, netprms=[ndim,baselinknum,acceptlvl]
% where ndim is the number of dimensions for distance (-2 is a circle)
% and baselinknum gives the number of points in each list to choose links

ndim = netprms(1);
baselinknum = netprms(2);
acceptlvl = netprms(3);

if(ndim>0)
    pnts = rand(netsize,ndim);
elseif(ndim==-2)
    tmprand = rand(netsize,2);
    pnts = [(tmprand(:,1).^0.5).*sin(2*pi*tmprand(:,2)) (tmprand(:,1).^0.5).*cos(2*pi*tmprand(:,2))]*sqrt(1/pi);
else
    error('ndim should be -2, or a positive integer');
end;

if(exist('pdist','builtin')) % does function exist?
    dmat = squareform(pdist(pnts,'euclidean'));
else
    dmat = zeros(netsize);
    for ii=1:netsize
        dmat(:,ii) = sqrt(sum((pnts-repmat(pnts(ii,:),netsize,1)).^2,2));
    end;
end;
dmat(logical(eye(netsize)))=inf;

mat=sparse(netsize,netsize);
for ii=1:netsize
    [~,sortinds]=sort(dmat(:,ii));
    tmplist = sortinds(1:baselinknum);
    actlist = tmplist(rand(size(tmplist))<acceptlvl);
    mat(actlist,ii)=1;
    mat(ii,actlist)=1;
end;

%tmpmat = triu(dmat<threshdist & rand(netsize)<acceptlvl);
%mat=tmpmat+tmpmat';
end
