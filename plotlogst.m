function varargout=plotlogst(Vs,Ps,Es,varargin)
% plot the (log_10 of the) state of some model
% plotlogst(Vs,Ps,Es)

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
Es=InsertDefaultValues(Es,'VarInd',1,'StInd',1,'StAxis',[],'PlotBare',0,'St1Color',[jet(2) ;hsv(7); parula(11)],'St2Colorbar',1,'St2Interp',0,'StLineWidth',1);

minst2colorlen = 10;
defst2colorlen = 64;

if(~isfield(Es,'St2Color'))
	base = 1:-0.0138:0.13;
	Es.St2Color = [base; base/2+0.5; base]';
end;
if(size(Es.St2Color,1)<minst2colorlen)
	Es.St2Color=interp1(0:(size(Es.St2Color,1)-1),Es.St2Color,(0:(defst2colorlen-1))/(defst2colorlen-1)*(size(Es.St2Color,1)-1),'cubic');
end;
if(size(Es.St1Color,1)<Ps.VarNum)
    Es.St1Color=repmat(Es.St1Color,ceil(Ps.VarNum/size(Es.St1Color,1)),1);
end;

% first check if this is a 1D plot
if((Ps.Nx==1) || (Ps.Ny==1))
	if(Ps.Nx==1)
		reallen=Ps.Ly;
	else	
		reallen=Ps.Lx;
	end;
	
	Ps.Nx=Ps.Nx*Ps.Ny;
	
    if (~isfield(Es,'VarInd'))
        Es.VarInd = 1:size(Vs,2);
    end;
    data=reshape(Vs(:,Es.VarInd,Es.StInd),size(Vs,1),length(Es.VarInd)*length(Es.StInd));
    %set(gcf,'Colormap',Es.St2Color);
    set(gcf,'DefaultAxesColorOrder',[Es.St1Color(Es.VarInd,:) ; Es.St1Color]);
    handle=plot((1:Ps.Nx)*(reallen/Ps.Nx),log10(data),'lineWidth',Es.StLineWidth);
    %if (isfield(Es,'VarInd'))
%	set(0,'DefaultAxesColorOrder',[Es.St1Color(Es.VarInd,:) ; Es.St1Color]);
%        plot((1:Ps.Nx*Ps.Ny)*(reallen/Ps.Nx*Ps.Ny),Vs(:,Es.VarInd,Es.StInd));
%    else%
	%set(0,'DefaultAxesColorOrder',Es.St1Color);
        %plot((1:Ps.Nx*Ps.Ny)*(reallen/Ps.Nx*Ps.Ny),Vs(:,:,Es.StInd));
   % end
	xlim([0 Ps.Lx*Ps.Ny]);
    if(~isempty(Es.StAxis))
        ylim(Es.StAxis);
    end;
    %set(groot,'defaultAxesColorOrder','remove')
else  % Assuming this is a 2D plot
	set(gcf,'Colormap',Es.St2Color);
	img = log10(reshape(Vs(:,Es.VarInd(1),Es.StInd),Ps.Nx,Ps.Ny)');
	if(isfield(Es,'St2Angle'))  % Rotate image if relevant
        img=imrotate(img,Es.St2Angle);
    end;
    if(~(Es.St2Interp))
        if(isempty(Es.StAxis))	% Autoscale image?
            handle=imagesc(img);
        else
            handle=imagesc(img,Es.StAxis);
        end;
        axis xy;
    else
        handle=pcolor(flip(img,1));
        shading interp;
        if(~isempty(Es.StAxis))	% No autoscale image?
            caxis(Es.StAxis); 
        end;
    end;
	set(gca,'XTickLabel',get(gca,'Xtick')*Ps.Lx/Ps.Nx); 
	set(gca,'YTickLabel',get(gca,'Ytick')*Ps.Ly/Ps.Ny);
	if(Es.St2Colorbar)      
		colorbar;
	end;
    
end
if(Es.PlotBare)
	set(gca,'XTick',[],'YTick',[]);
end;
if(nargout>0)  % Only return a handle if one's requested.
    varargout{1}=handle;
end;


end
