function varargout=plotnt(Vs,Ps,Es,varargin)
% plot the state over a network
% plotst(Vs,Ps,Es)

if(nargin<2)
	Ps=struct('Lx',size(Vs,1),'Nx',size(Vs,1),'Ny',1);
end;
if(nargin<3)
	Es=struct();
else
    % Default first extra input is for the state-indicator
    if(~mod(nargin,2)) varargin = ['Es.StInd' varargin]; end;
end;


% Update online if necessary
[Vs,Ps,Es]=UpdateParameters(Vs,Ps,Es,varargin{:});
% Make sure Ps parameters are properly setup
[Vs,Ps,Es]=FillMissingPs(Vs,Ps,Es);
% Put in some default values of Es
Es=InsertDefaultValues(Es,'VarInd',1,'StInd',1,'StAxis',[],'PlotBare',0,'St1Color',[jet(2) ;hsv(7)],'St2Colorbar',1,'St2Interp',0);


gplot(Ps.Net,Ps.Locs,'k'); 
hold on; 
handle=scatter(Ps.Locs(:,1),Ps.Locs(:,2),50,Vs(:,Es.VarInd,Es.StInd),'filled'); 
hold off; 
if(~isempty(Es.StAxis))
    caxis(Es.StAxis); 
end;

if(Es.St2Colorbar)
    colorbar;
end;

if(nargout>0)  % Only return a handle if one's requested.
    varargout{1}=handle;
end;

end