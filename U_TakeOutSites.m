function [Vs,Ps,Es]=U_TakeOutSites(Vs,Ps,Es,varargin)
% A Utility function to take out sites in a network
% [Vs,Ps,Es]=U_TakeOutSites(Vs,Ps,Es)
% Es.TakeOutPrm=[cutnum rule keepcon minpart] controls the way these sites are taken out
% num controls site number to take out, in integer (num>=1) or proportion (num<1)
% rule=0 (def) is at random, rule=1 takes out the most connected ones, rule=-1 the least
% keepcon (def=0) is the number of iterations to use to try and keep the network connected
% minpart (def=0.01) is the smallest precentage of links to cut in iterative loop

% Update online if necessary
[Vs,Ps,Es]=UpdateParameters(Vs,Ps,Es,varargin{:});

% pad with zero
Es.TakeOutPrm = [Es.TakeOutPrm(:);0;0;0];

cutnum=Es.TakeOutPrm(1);
rule=Es.TakeOutPrm(2);
keepcon= Es.TakeOutPrm(3);
if(Es.TakeOutPrm(4)>0)
    minpart=Es.TakeOutPrm(4);
else
    minpart=0.01;
end;

if(cutnum<1) % make sure num has an integer number of sites to take out
    cutnum=ceil(cutnum*Ps.Nx);
end;

% Track history of edge number
if(~isfield(Es,'EdgeHistory') || isempty(Es.EdgeHistory))
    Es.EdgeHistory = sum(Ps.Net);
end;


if(~keepcon) % normal simple run
    [Ps,linkchange]=takeoutsites(Ps,cutnum,rule);
else         % iterative run to try and keep net connected
    [Pstry,lnkchtry]=takeoutsites(Ps,cutnum,rule);
    if(netconnected(Pstry.Net))
        Ps=Pstry;
        linkchange=lnkchtry;
    else
       linkchange=0;
       keepind=1; curcut=0; part=0.5;
       % keep going iteratively
       while(keepind<keepcon && curcut<cutnum)
           % how much do we need to remove this time?
           cutpart = min(ceil(part*cutnum),cutnum-curcut);
           % try to remove it
           [Pstry,lnkchtry]=takeoutsites(Ps,cutpart,rule);
           if(netconnected(Pstry.Net)) % is the network still connected?
               curcut=curcut+cutpart;
               Ps=Pstry;
               linkchange=linkchange+lnkchtry;
           else % it is not, so we need to try again, with a smaller part
               if(part>minpart)
                    part=part/2;
               end;
           end;
           keepind=keepind+1;
       end; 
       % remove anything left (of the total necessary)
       [Ps,lnkchtry]=takeoutsites(Ps,cutnum-curcut,rule);
       linkchange=linkchange+lnkchtry;
    end;
end;

% keep new number of edges
Es.EdgeHistory = [Es.EdgeHistory(:)' Es.EdgeHistory(end)-linkchange];


end


%%% AUX Func %%%
function [Ps,linkchange]=takeoutsites(Ps,cutnum,rule)

edgenums=sum(Ps.Net>0,2);
linkchange=0;
sitelist=zeros(cutnum,1);
for ii=1:cutnum
    if(rule==0) % neutral
        [~,chs]=max(edgenums*0+rand(Ps.Nx,1));
    elseif(rule==1) % take out most connected sites
        [~,chs]=max(edgenums+rand(Ps.Nx,1));
    elseif(rule==-1) % take out least connected sites
        [~,chs]=min(edgenums+rand(Ps.Nx,1));
    else
        error('rule should be -1, 0, or 1 (middle-ground is not implemented).');
    end;
    sitelist(ii)=chs;
    linkchange=linkchange+edgenums(chs);
    edgenums(chs)=NaN;
end;

% Take out the sites
Ps.Net(:,sitelist)=[];
Ps.Net(sitelist,:)=[];
% Take out the position of the sites, if appropiate
if(isfield(Ps,'Locs') && ~isempty(Ps.Locs))
    Ps.Locs(sitelist,:)=[];
end;
Ps.Nx=Ps.Nx-cutnum; % number of sites has changed

end
