function [varargout] = PlotEigenfun(data, options)
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

%% Check options
if nargin == 2 && isfield(options,'xlims') 
    xlims = options.xlims;             
else
    xlims = [min(xtrain(:,1)), max(xtrain(:,1))];
end

if nargin == 2 && isfield(options,'ylims')
    ylims = options.ylims;             
else
    ylims = [min(xtrain(:,2)), max(xtrain(:,2))];         
end

if nargin == 2 && isfield(options,'resolution')     
    res = options.resolution;
else
    res = 'medium';
end

if nargin == 2 && isfield(options,'type')  
    type = options.type;
else
    type = '2D';
end

if nargin == 2 && isfield(options,'components')
    components = options.components;
    alpha_dim = length(components);
    
else
    alpha_dim = 4; % size(data.alphas, 2);
    components = 1:alpha_dim;
end

eigens = round(eigens(components)*100) / 100;
alphas = alphas(:,components);

if nargin == 2 && isfield(options, 'plot_data') && options.plot_data
    plot_data = options.plot_data;
else
    plot_data = false;
end

if nargin == 2 && isfield(options,'plot_stream') && options.plot_stream
    if isfield(data,'kernel_dev')
        kernel_dev = data.kernel_dev;
        plot_stream = options.plot_stream;
    else
        error('No kernel derivative!');
    end
else
    plot_stream = false;
end

if nargin == 2 && isfield(options,'plot_eigens')
    plot_eigens = options.plot_eigens;
else
    plot_eigens = false;
end

if nargin == 2 && isfield(options,'plot_mapped')
    if ~isfield(data,'mappedData')
        error('error');
    end
    mappedData = data.mappedData;
    mappedData = mappedData(components,:);
    plot_mapped = options.plot_mapped;
else
    plot_mapped = false;
end

if nargin == 2 && isfield(options,'plot_projData')
    if ~isfield(data,'mappedData') 
        error('error');
    end
    plot_projData = options.plot_projData;
else
    plot_projData = false;
end

if nargin == 2 && isfield(options,'plot_manifold')
    if ~isfield(data,'mappedData') 
        error('error');
    end
    plot_manifold = options.plot_manifold;
else
    plot_manifold = false;
end

%% Generate Test Dataset
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

xs = linspace(xlims(1), xlims(2), np);
ys = linspace(ylims(1), ylims(2), np);
xdim = length(xs);
ydim = length(ys);

[Xs,Ys] = meshgrid(xs,ys);
xtest = [Xs(:),Ys(:)];

%% Get Eigenfunctions
gram_options = struct('norm', false,...
                      'vv_rkhs', false);
K = GramMatrix(kernel, gram_options, xtrain, xtest);
psi = GetPrincipals(K, alphas);
Psi = reshape(psi,ydim,xdim,[]);

%% Get Eigenfunctions' gradient
if plot_stream
    K_d = GramMatrix(kernel_dev, gram_options, xtrain, xtest);
    psi_d = GetPrincipals(K_d, alphas);
    Psi_d{1} = reshape(psi_d(:,1,:), ydim, xdim, []);
    Psi_d{2} = reshape(psi_d(:,2,:), ydim, xdim, []);
end

%% Temporary save data
% eigfun = [xtest,psi(:,:,1)];
% eigfun_d = [xtest, psi_d(:,:,1)];
% save('eigfun.dat', 'eigfun', '-ascii');
% save('eigfun_d.dat', 'eigfun_d', '-ascii');

%% Plot
if mod(alpha_dim,2)
    lines_plot = (alpha_dim + 1)/2;
else
    lines_plot = alpha_dim/2;
end

if isfield(options, 'labels')
    labels = options.labels;
else
    labels = ones(size(xtrain,1),1);
end

colors = hsv(length(unique(labels)));

varargout{1} = figure;
for i=1:alpha_dim
    
    if alpha_dim ~= 1
        Subaxis(lines_plot, 2, i,'Spacing', 0.05, 'Padding', 0, 'Margin', 0.05);
%         subplot(lines_plot,2,index);
    end
    
    switch type
        case '2D'
            contourf(Xs, Ys, real(Psi(:, :, i)), 20);
        case '3D'
            surfc(Xs, Ys, real(Psi(:, :, i)));
        otherwise
            error('Che cazzo stai facendo?');
    end
    
    hold on;
    
    if plot_projData
        scatter3(xtrain(:,1),xtrain(:,2), mappedData(i,:),20,colors(labels,:),'filled','MarkerEdgeColor',[0 0 0]);
    end
    
    if plot_data
        scatter(xtrain(:,1),xtrain(:,2),20,colors(labels,:),'filled','MarkerEdgeColor',[0 0 0]);
    end
    
    if plot_stream
        h = streamslice(Xs, Ys, -real(Psi_d{1}(:, :, i)), -real(Psi_d{2}(:, :, i))); % check also streamline
        set(h,'Color','r');
    end

    title(['Eig-val ' num2str(components(i)) ': ' num2str(eigens(i)) ],'FontSize',8);
    xlabel('x_1','FontSize',8);
    ylabel('x_2','FontSize',8);
%     colormap hot
    axis square
    axis([xlims(1) xlims(2) ylims(1) ylims(2)])
    colorbar
end

if plot_eigens
    varargout{2} = figure;
    xs = 1:length(eigens);
    plot(xs, eigens, '-s');
    set(gca,'Xtick',xs);
    xlabel('eigenvectors');
    ylabel('eigenvalues');
    title('Extracted Eigenvalues');
end

if plot_mapped
   switch plot_mapped
       case '2D'
           if size(data.mappedData,2) < 2
               error('Not enough component');
           end
           varargout{3} = figure;
           scatter(data.mappedData(1,:),data.mappedData(2,:),20,colors(labels,:),'filled','MarkerEdgeColor',[0 0 0]);
           xlabel('Y_1');
           ylabel('Y_2');
           title('Projected Data over first 2 eigenvectors');
           grid on;
       case '3D'
           if size(data.mappedData,2) < 3
               error('Not enough component');
           end
           varargout{4} = figure;
           scatter3(data.mappedData(1,:), data.mappedData(2,:), data.mappedData(3,:),20,colors(labels,:),'filled','MarkerEdgeColor',[0 0 0]);
           xlabel('Y_1');
           ylabel('Y_2');
           zlabel('Y_3');
           title('Projected Data over first 3 eigenvectors');
           grid on;
       otherwise
           error('Error merda');
   end
end

if plot_manifold
    switch plot_manifold
        case '2D'
            varargout{5} = figure;
            grid on; hold on;
            X = real(Psi(:, :, 1));
            Y = real(Psi(:, :, 2));
            plot(X(:),Y(:));
            scatter(data.mappedData(1,:),data.mappedData(2,:),20,colors(labels,:),'filled','MarkerEdgeColor',[0 0 0]);
        case '3D'
            varargout{6} = figure;
            grid on; hold on;
            surfc(real(Psi(:, :, 1)), real(Psi(:, :, 2)), real(Psi(:, :, 3)));
            scatter3(data.mappedData(1,:), data.mappedData(2,:), data.mappedData(3,:),20,colors(labels,:),'filled','MarkerEdgeColor',[0 0 0]);
        otherwise
            error('Fottiti');
    end
end

end

