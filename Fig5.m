%% setup basics

accrate=0.5; % link close sites with probability: p = 0.5
addnum = 40; % link c=40 closest neighbors

% define variables used for running simulations
Es = struct('TsSize',0.1,'TsNum',2,'TimeDst',100,'TsMode','auto/2','OdeInit',0,'SsThresh',1e-8,'NonNeg',1,'StSmall',1e-3,'VarInd',1,'TestFunc',@T_AvgVal,'Frames',200,'StAxis',[0 1.1],'InitFunc',@M_InitUnfSt);
Ps = struct('LocFunc',@L_SR,'SpaFunc',@S_RD,'IntegFunc',@I_FDE,'r',1,'K',1,'gamma',3,'Ds',2,'VarNum',1,'Lx',1,'Ly',1,'Nx',2000,'Ny',1);

Es.TestFunc = {@T_AvgVal,[1,1],@T_MinMax,[1,1],@T_LargestRegions,[1,1]}; 
Es.FuncList = {@M_CutVar,@run2ss,@C_Estimate3Share};

rho    = 0.7; % disturbance intensity
distsz = 0.5; % disturbance extent (sigma) 
Es.ModPrm=[-rho*distsz 1 distsz -1];
Ps.SpaFunc=@S_NetDL;

%% run a single simulation as an example

[mat,pnts]=distrndnet(Ps.Nx,[-2,addnum,accrate]);
Ps.Net=mat;   
Ps.Locs=pnts;

% run simulation (just for visualization)
[~,tmp]=runflow(1,Ps,Es,'Es.OlDraw',1,'Es.PlotFunc',@plotnt);

%% run multiple simulations of fragmentation and dynamics

% number of random repetitions of network construction and simulating dynamics
randlens=[4 2];

% run a simulation without dispersal as a baseline
st=M_CutVar(ones(Ps.Nx,1),Ps,Es);
[~,bf0]=run2ss(st,Ps,Es,'Ps.Ds',0);

% percentages of sites to remove
removeportion = [0,0.2,0.5,0.7,0.8,0.85,0.9];

% main loop - building differnet networks
for rind1=1:randlens(1)
    % create a network with randomization seed of rind1
    rng(rind1);
    [mat,pnts]=distrndnet(Ps.Nx,[-2,addnum,accrate]);
    Ps.Net=mat;   
    Ps.Locs=pnts;
    disp(rind1)
    
    % secondary loop - percentages of sites to remove
    for removeind=1:length(removeportion)
        
        tic;
        rng(rind1);
        % Remove sites randomly (and iteratively)
        [~,Ps1,~]=U_TakeOutSites(1,Ps,Es,'Es.TakeOutPrm',[removeportion(removeind) 0 500 0.002]);
        % saves stats of mean degree and mean shortest path
        sitenum(removeind,rind1)= full(mean(sum(Ps1.Net)));
        siteasp(removeind,rind1)= avgshortpath(Ps1.Net);
        rng(rind1);
        % Remove sites from periphery (and iteratively)
        [~,Ps2,~]=U_TakeOutOutsideSites(1,Ps,Es,'Es.TakeOutPrm',[removeportion(removeind) 0]);
        % saves stats of mean degree and mean shortest path
        outsnum(removeind,rind1)= full(mean(sum(Ps2.Net)));
        outsasp(removeind,rind1)= avgshortpath(Ps2.Net);
        
        % run several simulations on both networks 
        [~,shares1]=runpar(1,Ps1,Es,'Es.BfPrm','Es.RandSeed','Es.BfRange',[1 randlens(2) randlens(2)],'Es.Verbose',0,'Es.PostMixingAddition',1,'Es.NoDispersalSim',bf0);
        [~,shares2]=runpar(1,Ps2,Es,'Es.BfPrm','Es.RandSeed','Es.BfRange',[1 randlens(2) randlens(2)],'Es.Verbose',0,'Es.PostMixingAddition',1,'Es.NoDispersalSim',bf0);
        
        % save results from simulations
        mat1(removeind,(rind1-1)*randlens(2)+(1:randlens(2)),:) = shares1(:,2:4);
        mat2(removeind,(rind1-1)*randlens(2)+(1:randlens(2)),:) = shares2(:,2:4);
        toc;
        
    end;
    
end; 

%% plot results

% regime components along trajectory of fragmentation
traj1 = squeeze(mean(mat1,2));
traj2 = squeeze(mean(mat2,2));

clf
% plot the 2 trajectories in the space of mean degree (x) and mean shortest path (y)
subplot(3,1,1);
plot(mean(sitenum,2),mean(siteasp,2),'k-',mean(outsnum,2),mean(outsasp,2),'k--')

% for random removal - plot regime components as a function of sites removed
subplot(3,1,2);
plot(removeportion,traj1(:,1),'r',removeportion,1-sum(traj1(:,[1,3]),2),'g',removeportion,traj1(:,3),'b');
% for periphery removal - plot regime components as a function of sites removed
subplot(3,1,3);
plot(removeportion,traj2(:,1),'r--',removeportion,1-sum(traj2(:,[1,3]),2),'g--',removeportion,traj2(:,3),'b--');

