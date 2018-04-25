function prodsource = T_AnalyzeBioProd(Vs,Ps,Es,varargin)
% analyze biomass production due to base growth, species sorting, mass effect
% prodsource = T_AnalyzeBioProd(Vs,varargin)

% Update online if necessary
if(nargin>3) [Vs,Ps,Es]=UpdateParameters(Vs,Ps,Es,varargin{:}); end;

% Put in some default values of Es
Es=InsertDefaultValues(Es,'BfPrm',[],'DynPrm',[],'FramesChoice',[],'MixThresh',10);

if(~(length(Es.FramesChoice)==size(Vs,3)))
    error('Es.FramesChoice does not match Vs.');
end;

% Put dynamic parameters into cell array if it is not empty
if((~iscell(Es.DynPrm)) && ~isempty(Es.DynPrm))
	Es.DynPrm = {Es.DynPrm};
end;

if(~isfield(Ps,'ResNum') || isempty(Ps.ResNum) || Ps.ResNum<1)
	Ps.ResNum=1;
end;

spnum = Ps.VarNum-Ps.ResNum; % species number

% calculate the rhs per time point
rhsmat = zeros(size(Vs));
for ii=1:length(Es.FramesChoice)
    dynindex = mod(Es.FramesChoice(ii)-1,length(Es.DynVal))+1;
    tempvals = Es.DynVal(dynindex); 
    [~,Ps,Es]=SaveParmList(Vs,Ps,Es,tempvals,Es.DynPrm,0*length(Es.BfPrm));
    rhsmat(:,:,ii)=getrhs(Vs(:,:,ii),Ps,Es);
end;

baseprod  = rhsmat(:,1:spnum,:) + Vs(:,1:spnum,:).*Ps.m; % biomass produced (take out effect of mortality)
avgprod   = mean(baseprod,3); % average of biomass production over time

deadmat   = (sum(Vs(:,1:spnum,:)<(Es.PopThresh*Es.MixThresh),3)>0); % where are things considered dead
spreadmat = repmat(sum(deadmat,1)==0,Ps.Nx,1);  % what species are spread all through the system
allprod   = cat(3,avgprod.*(1-deadmat-spreadmat),avgprod.*deadmat,avgprod.*spreadmat); % three components

prodsource= reshape(sum(mean(allprod,1),2),1,3); % average over space and sum over species

end
