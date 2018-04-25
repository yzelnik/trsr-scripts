%% setup basics

% define variables used for running simulations
Es=struct('TsSize',0.1,'TsNum',2,'TimeDst',100,'TsMode','auto','OdeInit',0,'SsThresh',1e-5,'NonNeg',1,'StSmall',1e-3,'VarInd',1,'TestFunc',@T_AvgVal,'Frames',200,'StAxis',[0 1.1],'InitFunc',@M_InitMixSt,'InitPrm',[0.5 0.25]);
Ps=struct('LocFunc',@L_SR,'SpaFunc',@S_RD,'IntegFunc',@I_FDE,'r',1,'K',1,'gamma',3,'Ds',1,'VarNum',1,'Lx',80,'Ly',1,'Nx',400,'Ny',1);

%% run 3 sims for Fig 1
stval = 0.15; % stval = 1-rho

dss = [0.01 1 8];   % values of d
rss=[4 1 0.01];     % values of r
tss = [35 45 600];  % time to run each simulation

for ii=1:3 % go over 3 simulations
    sims1{ii}=runframes([stval;1],Ps,Es,'Ps.Ds',dss(ii)','Ps.r',rss(ii),'Es.Frames',(0:100)*tss(ii)/100);
end;


%% plot sims out (Fig. 1)
stps = [1+[0 30 55 80 92 95];1+[0 20 40 60 80 100];1+[0 1 4 10 40 100]]; % for case z

% go over 3 regimes
for ii=1:3
    % go over different time points
    for jj=1:length(stps)
        subplot(3,length(stps),(ii-1)*length(stps)+jj);
        % plot a profile
        plotst(sims1{ii},Ps,Es,stps(ii,jj))
        title(stps(ii,jj)*tss(ii)/200); 
        if(jj>1) set(gca,'yTickLabel',[]); end;
    end;
end;

%% run 2 sims for Fig 2

distsz=0.4;
tss2=[160 16]; % times to run simulation

% run localized disturbance
sims2{1}=runframes([0;1],Ps,Es,'Es.TimeDst',tss2(1),'Es.InitPrm',[0.5 distsz/2],'Ps.Lx',200,'Ps.Nx',2000);
% run global disturbance
sims2{2}=runframes(1-distsz,Ps,Es,'Es.TimeDst',tss2(2),'Ps.Lx',200,'Ps.Nx',2000);

%% plot sims out (Fig. 2)
stps2 = [2+(0:4)*35;2+(0:4)*24]; 

% go over global/localized disturbance
for ii=1:2
    % go over different time points
    for jj=1:length(stps2)
        subplot(2,length(stps2),(ii-1)*length(stps2)+jj);
        % plot a profile
        plotst(sims2{ii},Ps,Es,stps2(ii,jj),'Ps.Lx',200,'Ps.Nx',2000)
        title(stps2(ii,jj)*tss2(ii)/200); 
        if(jj>1) set(gca,'yTickLabel',[]); end;
    end;
end;
    
