function [varargout] = PlotLyap(X,lyapFun,options)
%PLOTLYAP Summary of this function goes here
%   Detailed explanation goes here

%% Check options
if nargin == 3 && isfield(options,'xlims') 
    xlims = options.xlims;             
else
    xlims = [min(X(:,1)), max(X(:,1))];
end

if nargin == 3 && isfield(options,'ylims')
    ylims = options.ylims;             
else
    ylims = [min(X(:,2)), max(X(:,2))];         
end

if nargin == 3 && isfield(options,'resolution')     
    res = options.resolution;
else
    res = 'medium';
end

if nargin == 3 && isfield(options,'type')  
    type = options.type;
else
    type = '2D';
end

if nargin == 3 && isfield(options, 'plot_data')
    plot_data = options.plot_data;
    if isfield(options, 'labels')
        labels = options.labels;
    else
        labels = ones(size(X,1),1);
    end
    colors = hsv(length(unique(labels)));
else
    plot_data = false;
end

if nargin == 3 && isfield(options,'lyap_dev')  
    lyapFun_d = options.lyap_dev;
    calc_dev = true;
    if isfield(options,'plot_stream')
        plot_stream = options.plot_stream;
    else
        plot_stream = false;
    end
else
    calc_dev = false;
end

%% Generate Test Dataset
switch res
    case 'low'
        np = 200;
    case 'medium'
        np = 400;
    case 'high'
        np = 600;
    otherwise
        error('Error: incorrect resolution value');
end

xs = linspace(xlims(1), xlims(2), np);
ys = linspace(ylims(1), ylims(2), np);
xdim = length(xs);
ydim = length(ys);

[Xs,Ys] = meshgrid(xs,ys);
xtest = [Xs(:),Ys(:)];
n_data = size(xtest,1);

lyap = zeros(n_data,1);
if calc_dev
    lyap_d = zeros(n_data,2);
end

for i = 1:size(xtest,1)
    lyap(i) = lyapFun(xtest(i,:)');
    if calc_dev
        lyap_d(i,:) = lyapFun_d(xtest(i,:)');
    end
end

Lyap = reshape(lyap,ydim,xdim);
varargout{1} = Lyap;

if calc_dev
    Lyap_d = zeros(ydim, xdim,2);
    Lyap_d(:,:,1) = reshape(lyap_d(:,1),ydim,xdim);
    Lyap_d(:,:,2) = reshape(lyap_d(:,2),ydim,xdim);
    varargout{2} = Lyap_d;
end

figure

switch type
    case '2D'
        contourf(Xs, Ys, Lyap, 20);
    case '3D'
        surfc(Xs, Ys, Lyap);
    otherwise
        error('Che cazzo stai facendo?');
end

hold on;

if plot_data
    scatter(X(1,:),X(2,:),20,colors(labels,:),'filled','MarkerEdgeColor',[0 0 0]);
end
    
if plot_stream
    streamslice(Xs, Ys, Lyap_d(:, :, 1), Lyap_d(:, :, 2)); % check also streamline
end

colormap hot
% axis square
colorbar

end