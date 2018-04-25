%% setup basics

% Define resolution of parameter space (of disturbances)
prmjump= 0.1;

% Define grid of paramter space
prmgrid=prmjump/2:prmjump:1;

% Define variables used for running simulations
Es = struct('TsSize',0.01,'TsNum',2,'TimeDst',100,'TsMode','none','OdeInit',0,'SsThresh',1e-8,'NonNeg',1,'StSmall',1e-3,'VarInd',1,'TestFunc',@T_AvgVal,'Frames',200,'StAxis',[0 1.1],'InitFunc',@M_InitMixSt,'InitPrm',[0.5 0.25]);
Ps = struct('LocFunc',@L_SR,'SpaFunc',@S_RD,'IntegFunc',@I_FDE,'r',1,'K',1,'gamma',3,'Ds',1,'VarNum',1,'Lx',80,'Ly',1,'Nx',400,'Ny',1);
Es.ModPrm=[-0.1*1,1,0.1,-1,0,1];

len = length(prmgrid); % number of points in grid
Es.BfPrm = {'Es.ModPrm(3)','Es.ModPrm(1)','Es.ReachVal'}; % parameters to change between simulations
Es.BfRange=[reshape(repmat(prmgrid,1,len),len^2,1),-reshape(repmat(prmgrid,len,1),len^2,1)]; % basic grid of parameter space
Es.BfRange(:,3)=1+prod(Es.BfRange,2)*0.1; % extra parameter values to set threshold for return time correctly
Es.FuncList={@M_CutVar,@run2ss,@C_ReachVal}; % 3 funcitons to run each simulation: cut biomass, run until steady state, calculate time to threshold


%% run simulations on a grid and plot parameter space

Ps.Ds=1; % Set dispersal coefficient

% Run a set of simulatons to calculate return time for differnet parameter values
tic;
[~,prmspace] = runpar(1,Ps,Es);
toc;

% Plot result
plotps(prmspace,Es,'Es.BfFields',[1 2 4],'Es.BfLogColor',1);
colorbar;
