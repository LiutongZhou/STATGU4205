function [accumsum,varargout]=hist3d(X,Y,W,varargin)
%% [accumsum,counts,Xedges,Yedges]=weighted_hist3d(X,Y,W,nbins,issparse,plot)
% A geospatial plot: input n by 3 data (X,Y,W)
% deviding the X cross Y region using gridlines at Xedges and Yedges into
% nbins blocks. Return the accumsum of W in each block. counts is the
% number of observations of data falling into each block; issparse indicate
% wether or not to use sparse matrix for out put; if plot is 1, show a plot
% Authour: Liutong Zhou
% Created on 12/09/2016
if isrow(X);     X=X'; end
if isrow(Y);    Y=Y'; end
if isrow(W);     W=W';end
if nargin>=4 && ~isempty(varargin{1})
    nbins=varargin{1};
    [counts,Xedges,Yedges,binX,binY] = histcounts2(X,Y,nbins);
else
    [counts,Xedges,Yedges,binX,binY] = histcounts2(X,Y);
end
subs=[binX,binY];
if nargin>=5 && ~isempty(varargin{2}) && varargin{2}==1
    accumsum = accumarray(subs,W,[],[],[],1);
else
    accumsum = accumarray(subs,W);
end
varargout{1}=counts;
X=Xedges(1:end-1)';% transpose to column
Y=Yedges(1:end-1);
c=length(Y);
r=length(X);
X=repmat(X,1,c)+diff(Xedges')/2;
Y=repmat(Y,r,1)+diff(Yedges,[],2)/2;
varargout{2}=X;
varargout{3}=Y;
%% Visualization
if nargin==6 && varargin{3}==1
    %% Contour Plot
    data=fillmissing(accumsum./counts,'constant',0);
    contour(X,Y,data);
    xlabel('x','FontSize',13);ylabel('y','FontSize',13);title('Contour Plot','FontSize',14);
    [maxdata,ind]=max(data(:));% find peak point
    peakx=X(ind);    peaky=Y(ind);
    minx=Xedges(1);   maxx=Xedges(end);   miny=Yedges(1);  maxy=Yedges(end);
    ax.XLim=[minx maxx];  ax.YLim=[miny,maxy];
    line([minx,peakx],[peaky,peaky],...
        'LineStyle','--','Color','r','LineWidth',1)% horizontal reference line
    line([peakx,peakx],[miny,peaky],...
        'LineStyle','--','Color','r','LineWidth',1)% vertical reference line
    labelpoints ([peakx;minx;peakx], [peaky;peaky;miny], [maxdata;peaky;peakx],'NE');
    grid on;
    %% 3d density
    figure
    subplot(2,2,1)
    fig=surf(X,Y,data);
    set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
    colormap jet;    shading interp;
    xlabel('x','FontSize',13);ylabel('y','FontSize',13);zlabel('What is your label','FontSize',13);
    title('Your Title','FontSize',14);
    %% 2d  heat
     ax=subplot(2,2,4)
     f=copyobj(fig,ax);
     xlabel('x','FontSize',13);ylabel('y','FontSize',13);title('Heat Map','FontSize',14);
        ax.XLim=[minx maxx];  ax.YLim=[miny,maxy];
        line([minx,peakx],[peaky,peaky],...
            'LineStyle','--','Color','r','LineWidth',1)% horizontal reference line
        line([peakx,peakx],[miny,peaky],...
            'LineStyle','--','Color','r','LineWidth',1)% vertical reference line
    %% 2d along x
    ax= subplot(2,2,2);
    f=copyobj(fig,ax);
         xlabel('x','FontSize',13);ylabel('y','FontSize',13);zlabel('What is your Z','FontSize',13);
         title('Z along X','FontSize',14);
       view([0,-1,0]);grid on; ax.XLim=[minx maxx];  ax.YLim=[miny,maxy];
    %% 2d along y
      ax= subplot(2,2,3);
    f=copyobj(fig,ax);
         xlabel('x','FontSize',13);ylabel('y','FontSize',13);zlabel('What is your Z','FontSize',13);
         title('Z along Y','FontSize',14);
       view([1,0,0]);grid on; ax.XLim=[minx maxx];  ax.YLim=[miny,maxy];
    %%   add color bar
    hp4 = get(subplot(2,2,4),'Position');
    hp2=  get(subplot(2,2,2),'Position');
    colorbar('Position', [hp4(1)+hp4(3)+0.001  hp4(2)  0.025  hp2(2)+hp2(4)-hp4(2)]);
end
end
