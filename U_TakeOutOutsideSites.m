function [Vs,Ps,Es]=U_TakeOutOutsideSites(Vs,Ps,Es,varargin)
% A Utility function to take out nodes in a network from the perimeter region
% [Vs,Ps,Es]=U_TakeOutOutsideSites(Vs,Ps,Es)
% Es.TakeOutPrm=[num rule] controls the way these nodes are taken out
% num controls node number to take out, in integer (num>=1) or proportion (num<1)
% rule=0 (def) is at random, rule=1 takes out the most connected ones, rule=-1 the least

% Update online if necessary
[Vs,Ps,Es]=UpdateParameters(Vs,Ps,Es,varargin{:});

if(length(Es.TakeOutPrm)<2) % pad with zero so rule=0 by default
    Es.TakeOutPrm = [Es.TakeOutPrm(:);0];
end;

num=Es.TakeOutPrm(1);
rule=Es.TakeOutPrm(2);

if(num<1) % make sure num has an integer number of nodes to take out
    num=ceil(num*Ps.Nx);
end;

% Track history of edge number
if(~isfield(Es,'EdgeHistory') || isempty(Es.EdgeHistory))
    Es.EdgeHistory = sum(Ps.Net);
end;


edgenums=sum(Ps.Net>0,2);
edgechange=0;

axlims = max(Ps.Locs,[],1)-min(Ps.Locs,[],1);
center = mean(Ps.Locs,1);
for ii=1:num
    % choose sites away from center
    [~,chs]=max(sum((Ps.Locs./repmat(axlims,Ps.Nx,1)-repmat(center./axlims,Ps.Nx,1)).^2,2));
    
    edgechange=edgechange+edgenums(chs);
    % remove choice
    Ps.Net(:,chs)=[];
    Ps.Net(chs,:)=[];
    Ps.Locs(chs,:)=[];
    Ps.Nx = Ps.Nx-1;
end;
% keep new number of edges
Es.EdgeHistory = [Es.EdgeHistory(:)' Es.EdgeHistory(end)-edgechange];

end
