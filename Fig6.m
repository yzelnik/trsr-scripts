%% setup basics

% define variables used for running simulations
Es = struct('TsSize',0.1,'TsNum',2,'TimeDst',100,'TsMode','none','OdeInit',0,'SsThresh',1e-8,'NonNeg',1,'StSmall',1e-3,'VarInd',2,'TestFunc',@T_AvgVal,'Frames',200,'InitFunc',@M_InitMixSt,'InitPrm',[0.5 0.25]);
Ps=struct('LocFunc',@L_HRM,'SpaFunc',@S_RD,'IntegFunc',@I_FDE,'rho',1.85,'K',35920,'omega',25.5,'phi',11364,'sigma',12.4,'gamma',2.07,'Ds',[1 1],'VarNum',2,'Lx',1000,'Ly',1,'Nx',2000,'Ny',1);

Es.FuncList = {@runframes,@C_ReachVal};
Es.TestFunc = {@T_AvgVal,[1 2]};
Es.RecurFunc= {@M_PopThresh,@M_CutVar};
Es.PopThresh= 1; 
Es.ModPrm   = [-1e8 2 0.2 -1];
Es.ReachVal = 0.5;

% define noise and initial conditions
initnoise   = 1e4;
Es.InitFunc = @M_InitRndSt;
Es.StNoise  = initnoise/2;
Vs=[1,1]*initnoise/2;

%% get properties of fronts

% run simulation with prey&predator only on one side of the system 
[finst,bfout]=runflow([1;0],Ps,Es,'Es.OlDraw',1,'Es.TsSize',1e-2,'Es.FuncList',{@runframes,@C_CalcSpeed},'Es.TestFunc',@T_LowReg,'Es.SegThresh',1e-3,'Ps.Bc',1,'Es.Frames',0:5:200,'Es.InitFunc',@M_InitMixSt,'Es.PlotFunc',@plotlogst,'Es.StAxis',[-2 5],'Es.InitPrm',0.2,'Es.RecurFunc',[],'Es.TsMode','auto');
frontspd=-bfout*Ps.Lx; % calcualted front speed - not needed

clf;
% plot out the front
plotst(finst,Ps,Es)
locend = find(finst(:,1)>0.1,1,'last')*Ps.Lx/Ps.Nx;
xlim(locend+[-100 20]);
lam = 40; % This is an approximation of the front size

%% define parameters for (more complex) simulations

runtime = 80; % run-time of each simulation
exreps  = 80; % how many extinctions during simulations?
randnum = 5;   % how many different simulations to do at each parameter value
Ps.Lx   = 50; % system size to simulate
dsres   = 0.5; % jumps (in log10 scale) between values of d
dsends  = [-1.5 2.0]; % lowest and highest dispersal (in log10 scale)

% baseline for good valuess of Nx and Ts according to Ds
goodvals = [-2 4 0.05; -1 2 0.05; 0 1 0.05 ; 1 0.8 0.025; 2 0.5 0.005; 3 0.4 0.001; 4 0.25 0.00025; 5 0.2 0.00005];
% interpolate
full = [(dsends(1):dsres:dsends(2))' interp1(goodvals(:,1),goodvals(:,2:3),dsends(1):dsres:dsends(2),'nearest')];
% values for dispersal, time-steo and spatial resolution
dss  = 10.^full(:,1);
tsz  = full(:,3);
res  = full(:,2);

if(length(full)<6) error('For technical reasons, the number of points along the d-axis should be at least 6. Please fix this and run again.'); end;

Es.BfPrm={'Es.RandSeed','Ps.Ds(1)','Ps.Ds(2)','Es.TsSize','Ps.Nx'};
Es.BfRange={[1; randnum; randnum; 0],[dss,dss,tsz,res*Ps.Lx]};

jumpnum = runtime/max(tsz);

% which times to inact a population threshold, and which to enact a local extinction
% first one only pop-threshold, second one has both
recurnoex   = [ones(jumpnum,1) zeros(jumpnum,1)];
recurwithex = [ones(jumpnum,1) repmat([zeros(jumpnum/exreps-1,1);1],exreps,1)];

Es.Frames=(1:jumpnum)*runtime/jumpnum;

%% run simulations

tic;
% run simulations without local extinctions
[~,resnoex]=runpar(Vs,Ps,Es,'Es.RecurFrames',recurnoex,'Es.Verbose',0);
toc;
%
tic;
% run simulations with local extinctions
[~,reswithex]=runpar(Vs,Ps,Es,'Es.RecurFrames',recurwithex,'Es.Verbose',0);
toc;

%% plot out results

% survival probability without and with local extinctions
surprob0 = (mean(reshape(resnoex(:,6)>runtime,randnum,length(full)),1));
surprob1 = (mean(reshape(reswithex(:,6)>runtime,randnum,length(full)),1));
% prediction of RR-MR transition point
predtrans= log10((Ps.Lx/lam).^2);

clf;
% plot these out
plot(dsends(1):dsres:dsends(2),surprob0,'k',dsends(1):dsres:dsends(2),surprob1,'b',[predtrans predtrans],[0 1],'m--');


