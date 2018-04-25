function [Vs,Ps,Es]=U_RescaleRes(Vs,Ps,Es)
% change spatial resolution

Es=InsertDefaultValues(Es,'BaseRes',1,'ResMax',1e4,'ResMin',50);

rescalepow = 1/3; % should be 1/2
newres = round(Ps.Lx/Es.BaseRes/(Ps.Ds(1)^rescalepow)/2)*2;

if(newres>Es.ResMax)
    newres=Es.ResMax;
elseif(newres<Es.ResMin)
    newres=Es.ResMin;
end;

if(size(Vs,1)<Ps.Nx*Ps.Ny)
	Es.InitActive=0; % make sure we actually (re)initilize the state
    Ps.Nx=newres;
	[Vs,Ps,Es]=InitilizeState(Vs,Ps,Es);
    
else
    % get new Vs
    for ii=1:size(Vs,2) % interpolate with buffers
        tmpvs(:,ii)=interp1([-Ps.Nx 0.5:Ps.Nx Ps.Nx*2],[Vs(1,ii,1);Vs(:,ii,1);Vs(end,ii,1)],(0.5:newres)*Ps.Nx/newres);
    end;
    Vs=tmpvs;
    Ps.Nx=newres;
end;

end
