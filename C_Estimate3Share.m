function [shares,mixtime] = C_Estimate3Share(Input,Ps,Es,varargin)
% Estimate the relative share of each of 3 mechanisms:
% endogenous recovery, exogenous revcovery and mixing 
% Assuming 3 columns are of: avg-value, min-max-value, largest region
% the relative share is given as: share = [end,exo,mix]

% Update online if necessary
if(nargin>3) [~,Ps,Es]=UpdateParameters([],Ps,Es,varargin{:}); end;

Es=InsertDefaultValues(Es,'TestFields',2:4,'NoDispersalSim',[],'PostMixingAddition',[]);

thresh = 0.01;

% If we get state data, run the test on each state to form a bif table
if(size(Input,3)>1) 
    % Get 3 columns of avg-value, min-max-value, largest-region (see above definition)
    testlist = {@T_AvgVal,[1,1],@T_MinMax,[1,1],@T_LargestRegions,[1,1]}; 
    bfdata(1:size(Input,3),1) = 1:size(Input,3);
    for ii=1:size(Input,3)
        temp = T_MultiTest(Input(:,:,ii),Ps,Es,'Es.TestList',testlist);
        bfdata(ii,2:1+length(temp))=temp;
    end;
else          % Or, assume we got a bif data
    bfdata = Input;
end;

if(~isempty(Es.PostMixingAddition))
    extra = [bfdata(end,1)+diff(bfdata(1:2,1)) Es.PostMixingAddition(1) bfdata(end,3:4)];
    bfdata= [bfdata;extra];
end;

badnum = isnan(bfdata(:,4)) | isinf(bfdata(:,4));
if(sum(badnum)==length(badnum))
    shares(1:3)=NaN; % No data to work with, so no shares are defined
else
    if(badnum(end)) % Get last region size
        lastval = bfdata(max(1,find(badnum,1,'first')-1),4);
    else
        lastval = bfdata(end,1);
    end;
    if(lastval>bfdata(1,4)) % Get proper region size over time
        regsize = 1-bfdata(:,4);
    else
        regsize = bfdata(:,4);
    end;
    
    % Find how much the region's size has changed
    szchange = regsize(1)-min(regsize);

    maxdiff = max(bfdata(:,3));
    % Find when things have homogenized in space
    mixtime=find(bfdata(:,3)<thresh*maxdiff,1,'first'); 
    if(isempty(mixtime))
        mixtime=size(bfdata,1);
    end;


    % Divide the shares
    shares(3) = diff(bfdata([mixtime end],Es.TestFields(1)))./diff(bfdata([1 end],Es.TestFields(1))); % share of mixing
    shares(2) = min(szchange/regsize(1),1-shares(3));

    % Calculate the share of the Isolated Regime directly?
    if(isempty(Es.NoDispersalSim))
        shares(1) = 1-sum(shares);
    else
        % Use data from a simulation without dispersal to find the mixing time
        [~,mixind]=min(abs(Es.NoDispersalSim(:,1)-bfdata(mixtime,1)));
        % Use the ratio between recovery with and without dispersal (until mixing time)
        shares(1) = min(1,diff(Es.NoDispersalSim([1 mixind],2))/diff(bfdata([1 end],2)));
    end;
end;


end

