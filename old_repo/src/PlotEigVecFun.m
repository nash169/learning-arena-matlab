function [varargout] = PlotEigVecFun(data, options)
%PLOTSTREAM Summary of this function goes here
%   Detailed explanation goes here

%% Data Check
if isfield(data,'xtrain')
    xtrain = data.xtrain;
else
    error('No train data!');
end

if isfield(data,'kernel')
    kernel = data.kernel;
else
    error('No kernel bastard!');
end

if isfield(data,'alphas')
    alphas = data.alphas;
else
    error('No eigenvectors bastard!');
end

if isfield(data,'eigens')
    eigens = data.eigens;
else
    eigens = ones(size(alphas,2),1);
end

%% Options Check

% RESOLUTION
if nargin == 2 && isfield(options,'resolution')     
    res = options.resolution;
else
    res = 'medium';
end

switch res
    case 'low'
        np = 10;
    case 'medium'
        np = 50;
    case 'high'
        np = 100;
    otherwise
        error('Error: incorrect resolution value');
end
%----------------------------------------------

% XRANGE
if nargin == 2 && isfield(options,'xlims') 
    limits = options.xlims;
else
    limits = [min(data.xtrain(:,1)), max(data.xtrain(:,1))];
end
xs = linspace(limits(1,1), limits(1,2), np);
%----------------------------------------------

% YRANGE
if nargin == 2 && isfield(options,'ylims')
    limits = [limits; options.ylims];             
else
    limits = [limits; min(data.xtrain(:,2)), max(data.xtrain(:,2))];         
end
ys = linspace(limits(2,1), limits(2,2), np);
%----------------------------------------------

% ZRANGE
if nargin == 2 && isfield(options,'zlims')
    limits = [limits; options.zlims];
    zs = linspace(limits(3,1), limits(3,2), np);
end
%----------------------------------------------

% COMPONENTS TO PLOT
if nargin == 2 && isfield(options,'components')
    components = options.components;
    alpha_dim = length(components);
    
else
    alpha_dim = 4; % size(data.alphas, 2);
    components = 1:alpha_dim;
end
eigens = round(eigens(components)*100) / 100;
alphas = alphas(:,components);
%----------------------------------------------

% PLOT TRAIN DATA
if nargin == 2 && isfield(options, 'plot_data') && options.plot_data
    plot_data = options.plot_data;
else
    plot_data = false;
end
%----------------------------------------------

% PLOT EIGENVALUES
if nargin == 2 && isfield(options,'plot_eigens')
    plot_eigens = options.plot_eigens;
else
    plot_eigens = false;
end
%----------------------------------------------

% LABELS COLOR
if isfield(options, 'labels')
    labels = options.labels;
else
    labels = ones(size(data.xtrain,1),1);
end
colors = hsv(length(unique(labels)));
%----------------------------------------------


%% Generate Test Dataset
dim = size(limits,1);
if dim == 2
    [Xs,Ys] = meshgrid(xs,ys);
    xtest = [Xs(:),Ys(:)];
else
    [Xs,Ys,Zs] = meshgrid(xs,ys,zs);
    xtest = [Xs(:),Ys(:),Zs(:)];
end

%% Get Eigenfunctions
gram_options = struct('norm', false,...
                      'vv_rkhs', true);
K = GramMatrix(kernel, gram_options, xtrain, xtest);
psi = permute(reshape(GetPrincipals(K, alphas),dim,[],alpha_dim),[2,1,3]);

Psi = cell(dim,1);
for i = 1:dim
    Psi{i} = reshape(psi(:,i,:), np, np, []);
end

%% Plot
if mod(alpha_dim,2)
    lines_plot = (alpha_dim + 1)/2;
else
    lines_plot = alpha_dim/2;
end

varargout{1} = figure;
for i=1:alpha_dim
    
    if alpha_dim ~= 1
        subaxis(lines_plot, 2, i,'Spacing', 0.05, 'Padding', 0, 'Margin', 0.05);
%         subplot(lines_plot,2,index);
    end
    
    if dim == 2
        streamslice(Xs, Ys,...
            real(Psi{1}(:, :, i)), real(Psi{2}(:, :, i)));
        axis([limits(1,1) limits(1,2) limits(2,1) limits(2,2)])
    else
        streamslice(Xs, Ys, Zs,...
            real(Psi{1}(:, :, i)), real(Psi{2}(:, :, i)), real(Psi{3}(:, :, i)));
        axis([limits(1,1) limits(1,2) limits(2,1) limits(2,2) limits(3,1) limits(3,2)])
    end
    
    hold on;
    
    if plot_data
        if dim == 2
            scatter(xtrain(:,1),xtrain(:,2),...
                20,colors(labels,:),'filled','MarkerEdgeColor',[0 0 0]);
        else
            scatter3(xtrain(:,1),xtrain(:,2), xtrain(:,3),...
                20,colors(labels,:),'filled','MarkerEdgeColor',[0 0 0]);
        end      
    end

    title(['Eig-val ' num2str(components(i))],'FontSize',8);
    xlabel('x_1','FontSize',8);
    ylabel('x_2','FontSize',8);
    if dim > 2; zlabel('x_3','FontSize',8); end
    colormap hot
    axis square
    colorbar
end

if plot_eigens
    varargout{2} = figure;
    hold on;
    eigens = permute(reshape(eigens,dim,[]),[2,1]);
    for i = 1:alpha_dim/dim
        quiver(0,0,eigens(i,1),eigens(i,2));
        if dim > 2; quiver(0,0,0,eigens(i,1),eigens(i,2),eigens(i,3)); end
    end
    xlabel('x_1','FontSize',8);
    ylabel('x_2','FontSize',8);
    if dim > 2; zlabel('x_3','FontSize',8); end
    title('Extracted Eigenvalues');
end

end


