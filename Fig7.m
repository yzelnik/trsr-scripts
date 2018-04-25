%% setup basics

spnum  = 9; % number of species
period = 1000; % period of environmental change
dsres  = 0.4; % jumps (in log10 scale) between values of s
dsends = [-2.4 1.2]; % lowest and highest dispersal (in log10 scale)

Es=struct('TsSize',0.01,'TsNum',10,'TimeDst',200,'SsThresh',1e-7,'NonNeg',1,'StSmall',0.01,'VarInd',1,'JacMode',0,'PopThresh',0.1,'TsMode','auto');
Ps=struct('LocFunc',@L_ConRes,'SpaFunc',@S_RD,'IntegFunc',@I_FDE,'e',0.2,'c',0.1,'m',0.2,'I',150,'l',10,'Ds',1,'VarNum',spnum+1,'Lx',100,'Ly',1,'Nx',100,'Ny',1);

% define other parameters of environmental change
repnum = 15;
bjump  = 2;
lastper= 5;
lastres= 10;

Es.SihPrm=[period repnum bjump lastper lastres];
Es.FuncList={@U_SetupFramesSIH,@runframes,@T_AnalyzeBioProd,@T_AvgVal};
Es.FuncSpec=[0 0; 1 0; 3 1; 3 1]; % to make sure we save all frames of runframes, and not just the last one

Es.RecurFunc=@M_PopThresh;
Es.RecurFrames=1;
Es.DynPrm='c';
Es.VarInd=1:spnum;

Es.BfPrm='Ps.Ds';
Es.BfRange=10.^(dsends(1):dsres:dsends(2))';

%% a single simulation for visualization of dynamics

[~,tmp]=runflow(1,Ps,Es,'Es.OlDraw',1,'Es.FuncList',{@U_SetupFramesSIH,@runframes},'Es.BfPrm',[]);

%% calculate front properties 
tmpsz = 500; 
% run simulation of front
[finst,bfout]=runflow([50 zeros(1,8) 10;0 zeros(1,8) 10],Ps,Es,'Ps.rho',1,'Es.OlDraw',1,'Es.TsSize',1e-1,'Es.FuncList',{@runframes,@C_CalcSpeed},'Es.TestFunc',@T_LowReg,'Es.SegThresh',1e-3,'Ps.Bc',1,'Es.Frames',0:5:400,'Es.InitFunc',@M_InitMixSt,'Es.InitPrm',0.2,'Es.BfPrm',[],'Es.FuncSpec',[],'Es.DynPrm',[],'Ps.Nx',tmpsz*2,'Ps.Lx',tmpsz);
% calculate constants
frontspd=(-bfout*tmpsz);
frontsize=T_FrontSize(finst,Ps,Es,'Es.VarInd',1,'Ps.Nx',tmpsz*2,'Ps.Lx',tmpsz);

% print out front speed and size
disp([frontspd frontsize])

%% run multiple simulations
tic;
% run simulations along a d-axis
[~,simres]=runpar(1,Ps,Es,'Es.Verbose',1,'Es.OlDraw',0);
toc;
%% plot results
trans1 = log10((Ps.Lx./(frontspd*2*period)).^2);
trans2 = log10((Ps.Lx/frontsize).^2);
clf; ymax=18;
plot(dsends(1):dsres:dsends(2),simres(:,2),'r',dsends(1):dsres:dsends(2),simres(:,3),'g',dsends(1):dsres:dsends(2),simres(:,4),'b',[trans1 trans1],[0 ymax],'m--',[trans2 trans2],[0 ymax],'m--');
ylim([0 ymax]);
