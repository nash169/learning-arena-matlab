%% Training Dataset
clear; close all; clc;

%% Load demos
load 2attracts_simple.mat;
demo = DataStruct.demo;
demo_struct = DataStruct.demo_struct;

%% Process & Draw demonstration's data
process_options.center_data = false;
process_options.tol_cutting = 1.;
process_options.dt = 0.1;
[X, targets] = ProcessDemos(demo, 2, demo_struct, process_options);

draw_options.plot_pos = true;
draw_options.plot_vel = true;
[fig_pos, fig_vel] = DrawData(X, targets, draw_options);

%% Kernel PCA

% Dimensionality reduction options
options = [];
options.method_name  = 'KPCA';
options.nbDimensions = 8;
options.kernel       = 'gauss';
options.kpar         = 5;
options.norm_K = true;

% Solving KPCA
[mappedX_pca, mapping_pca] = ml_projection(X(1:2,:)', options);

% Storing data
kernel_data                         = [];
kernel_data.kernel                  = mapping_pca.kernel;
kernel_data.kpar                    = [mapping_pca.param1, mapping_pca.param2];
kernel_data.xtrain                  = X(1:2,:)';
kernel_data.alphas                  = mapping_pca.V;
kernel_data.eigen_values            = mapping_pca.L;

%% Plot eigenfunctions

% Plot options
iso_plot_options                        = [];
iso_plot_options.xtrain_dim             = [1 2];    % Dimensions of the orignal data to consider when computing the gram matrix (since we are doing 2D plots, original data might be of higher dimension)
iso_plot_options.eigen_idx              = 1:4;      % Eigenvectors to use.
iso_plot_options.b_plot_data            = true;     % Plot the training data on top of the isolines 
iso_plot_options.b_plot_eigenvalues     = true;     % Plot eigenvalues
iso_plot_options.labels                 = X(end,:);   % Plotted data will be colored according to class label
iso_plot_options.b_plot_colorbar        = true;     % Plot the colorbar.
iso_plot_options.b_plot_surf            = true;    % Plot the isolines as (3d) surface

% Plot Kernel PCA eigenfunction
[iso_pca, eig_pca] = ml_plot_isolines(iso_plot_options, kernel_data);