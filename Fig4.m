%% setup basics

% jump (in log_10 scale) between values of d (dispersal coefficient)
djump = 0.5; 
% ends of the range of d (lowest and highest values)
dends = [-4,3];

% define variables used for running simulations
Es = struct('TsSize',0.1,'TsNum',2,'TimeDst',100,'TsMode','auto','OdeInit',0,'SsThresh',1e-8,'NonNeg',1,'StSmall',1e-3,'VarInd',1,'TestFunc',@T_AvgVal,'Frames',200,'StAxis',[0 1.1],'InitFunc',@M_InitMixSt,'InitPrm',[0.5 0.25]);
Ps = struct('LocFunc',@L_SR,'SpaFunc',@S_RD,'IntegFunc',@I_FDE,'r',1,'K',1,'gamma',3,'Ds',1,'VarNum',1,'Lx',80,'Ly',1,'Nx',400,'Ny',1);

testlist = {@T_AvgVal,[1,1],@T_MinMax,[1,1],@T_LargestRegions,[1,1]}; 
funclist = {@U_RescaleRes,@run2ss,@C_Estimate3Share};
dvals = 10.^(dends(1):djump:dends(2))';
basenx = 50;

%% set specific parameter values
%  (change these to see difference across 3 shown parameter spaces)

Ps.Lx = 100;  % set system size
Ps.gamma = 3; % set gamma (nonlinearity)
rho = 0.95;   % set disturbance intensity

Vs = [1-rho;1];

%% calculate different constants

% run simulation without dispersal
[~,bf0]=run2ss(Vs,Ps,Es,'Ps.Ds',0,'Ps.Nx',basenx,'Es.OlDraw',0,'Es.TsMode','none','Es.TestFunc',testlist);
% plot out the avg. biomass level over time
clf; subplot(1,2,1);
plotbf(bf0)
% calculate the return time
basetau = C_ReachVal(bf0,Ps,Es,'Es.ReachVal',1-(1-bf0(1,2))/10);

% run simulation of front, between domains of N=0 and N=1
[frnt,tmpspd]=runflow([0;1],Ps,Es,'Ps.Ds',1,'Es.InitFunc',@M_InitMixSt,'Es.OlDraw',0,'Es.Frames',0:100,'Ps.Bc',1,'Es.InitPrm',0.8,'Es.TestFunc',@T_ZeroStateSize,'Es.FuncList',{@runframes,@C_CalcSpeed});
% plot out front
subplot(1,2,2);
plotst(frnt,Ps,Es)
% calculate front properties
spd    = -tmpspd*Ps.Lx;
lam    = T_FrontSize(frnt,Ps,Es);

% plot front, and print out stats

fprintf('u = %.2f, lambda = %.2f, tau_0 = %.2f\n',spd,lam,basetau);

%% calculate contribution along d-axis

% run a set of simulations along the axis of dispersal
% (this can take a long time, depending on chosen parameters)
tic;
[~,psl]=runpar(Vs,Ps,Es,'Es.BfPrm','Ds','Es.BfRange',dvals,'Es.TsMode','auto/4','Es.TsMin',1e-10,'Es.Verbose',1,'Es.FuncList',funclist,'Es.TestFunc',testlist,'Es.PostMixingAddition',1,'Es.ResMax',50000,'Es.NoDispersalSim',bf0);
toc;

%% plot out 3-regime contribution along d-axis

clf;
% plot the calculated regime contributions
plot(log10(dvals),psl(:,2),'r',log10(dvals),max(0,1-sum(psl(:,[2,4]),2)),'g',log10(dvals),psl(:,4),'b');

% estimate transition points
trans1=log10((Ps.Lx./(2*spd*basetau)).^2);
trans2=log10((Ps.Lx/lam).^2);

% plot prediction of transition points
hold on;
plot([trans1 trans1],[0 1],'m--',[trans2 trans2],[0 1],'m--');
hold off;

