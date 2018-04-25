function [Vs,Ps,Es]=U_SetupFramesSIH(Vs,Ps,Es,varargin)
% A Utility function to setup frames and dynmical variable for SIH (Spatial Insurance Hypothesis)
% [Vs,Ps,Es]=U_SetupFramesSIH(Vs,Ps,Es)

% Update online if necessary
[Vs,Ps,Es]=UpdateParameters(Vs,Ps,Es,varargin{:});
% give default values
Es=InsertDefaultValues(Es,'SihPrm',[]);

% make sure Es.SihPrm is not empty
if(length(Es.SihPrm)<3)
    error('Es.SihPrm=[period repnum basejump repssaved perres] needs to be defined for setup (the last 2 are optional).');
end; 

period  = Es.SihPrm(1);
repnum  = Es.SihPrm(2);
basejump= Es.SihPrm(3);

if(length(Es.SihPrm)>3)
    repsaved = Es.SihPrm(4);
else
    repsaved = repnum;
end;
if(length(Es.SihPrm)>4)
    perres = Es.SihPrm(5);
else
    perres = round(period/basejump);
end;


if(abs(mod((period/perres)/basejump,1))>1e-3)
    error('perres does not divide the period well, redefine Es.SihPrm.');
end; 

if(~isfield(Ps,'ResNum') || isempty(Ps.ResNum) || Ps.ResNum<1)
	Ps.ResNum=1;
end;

spnum = Ps.VarNum-Ps.ResNum;
len = Ps.Nx;

tmp = repmat(shiftdim((basejump/2:basejump:period)/period,-1),len,spnum);
ejrange = repmat((1:len)'/len,[1,spnum,size(tmp,3)]);
Ejt = 0.5*(sin(2*pi*(ejrange+tmp))+1);
Hi = repmat((1:spnum)/spnum,[len 1 size(tmp,3)]);
basecc = (1.5-abs(Hi-Ejt))/10;
    
Es.DynVal = {};
for ind=1:size(tmp,3)
    Es.DynVal{ind}=basecc(:,:,ind);
end;

Es.Frames=basejump:basejump:basejump*length(Es.DynVal)*repnum;

Es.FramesChoice = length(Es.DynVal)*(repnum-repsaved)+(1:perres*repsaved)*round((period/perres)/basejump);

Es.RepDynVal = 1; % assuming period>1

end
