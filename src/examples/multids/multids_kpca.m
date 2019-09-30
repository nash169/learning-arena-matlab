clear; close all; clc;

%% Load demos
load 2as_3t.mat;
demo = DataStruct.demo;
demo_struct = DataStruct.demo_struct;

%% Process data
preprocess_options = struct('center_data', false,...
                            'calc_vel', true, ...
                            'tol_cutting', 0.01, ...
                            'smooth_window', 25 ...
                            );
[X, ~, ~, targets, ~] = ProcessDemos(demo, demo_struct, 2, preprocess_options);
data = X(1:2,:)';
labels = X(end,:)';
colors = hsv(length(unique(labels)));
colors = colors(labels,:);

%% Clustering dynamics (Laplacian Eigenmaps)
lem = laplacian_eigenmaps('normalization', 'random-walk');
% Set data
lem.set_data(data);
% Set colors
lem.set_colors(colors);
% Set graph options
lem.graph_options('type', 'k-nearest', 'k', 10);
% Solve the eigensystem for the transport
[D_lem,V_lem,W_lem] = lem.eigensolve;
% Plot sampled points and sphere
lem.plot_data;
% Plot graph in the original space
lem.plot_graph;
% Plot spectrum
lem.plot_spectrum;
% Algebraic multiplicity of zero eigenvalue (this can be determined automatically)
ma_zero = 1;

%% Reconstruct dynamics (Kernel PCA - ECA)
% Create test set
[x,y] = meshgrid(linspace(0,100,100),linspace(0,100,100));
test = [x(:), y(:)];
n = size(test,1);

% Set the kernel
length = 5.;
myrbf = rbf('sigma', length);

% Set Kernel PCA
kp = kernel_pca('kernel', myrbf, 'centering', false);

% Set colors
colors = {'r', 'c'};

for i = 1 : ma_zero
    % Extract the subdynamcis
    data_sub =  data(V_lem(:,i)~=0,:);
    m = size(data_sub,1);
    
    % Set data and colors for KPCA
    kp.set_data(data_sub);
    kp.set_colors(colors{i});
    
    % Extract the firts eigenfunction
    V = kp.embedding(1);
    
    % Plot data and eigenfuction
    kp.plot_data;
    kp.plot_eigenfun(1);
    
    % Define minimum distance vector between point in the first KPCA
    % eigenvector
    V_dist = reshape(repmat(V,m,1)-repelem(V,m,1), m, m) + eye(m)*1e8;
    V_dist(V_dist < 0) = 1e8;
    [~, ind_min] = min(V_dist);
    
    % Create the gram matrix of training-test points
    myrbf.set_data(data_sub, test);
    gram_test = myrbf.gramian;
    
    % Define maximum distance vector in the gram matrix in order to deifne
    % the closest training to a given test point
    [~, ind_max] = max(gram_test);

    % Rebuild vector field
    f = (data_sub(ind_min(ind_max),:) - data_sub(ind_max,:)) ./ ...
       vecnorm(data_sub(ind_max,:)-data_sub(ind_min(ind_max),:),2,2);
   
%     % Rebuild vector field (non-vectorized version)
%     v_field = zeros(n,2);
%     for j = 1 : n
%        [~, c_p] = max(myrbf.gramian(test(j,:), data_sub));
%        v_dist = V - V(c_p);
%        v_dist(v_dist <= 0) = 1e8;
%        [~, c_e] = min(v_dist);
%        v_field(j,:) = (data_sub(c_e,:) - data_sub(c_p,:))/norm(data_sub(c_e,:) - data_sub(c_p,:));
%     end
    
    % Plot vector field
    figure
    streamslice(x,y, reshape(f(:,1),100,100), reshape(f(:,2),100,100))
    axis([0 100 0 100])
    hold on
    scatter(data_sub(:,1), data_sub(:,2), 40, colors{i}, 'filled','MarkerEdgeColor',[0 0 0])
%     figure
%     streamslice(x,y, reshape(v_field(:,1),100,100), reshape(v_field(:,2),100,100))
%     axis([0 100 0 100])
%     hold on
%     scatter(data_sub(:,1), data_sub(:,2), 40, colors{i}, 'filled','MarkerEdgeColor',[0 0 0])

    kp.plot_eigenvec;
end