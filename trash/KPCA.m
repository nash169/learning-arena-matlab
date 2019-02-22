%% Training Dataset
clear; close all; clc;

%% Load demos
load CurrentTest.mat;
demo = DataStruct.demo;
demo_struct = DataStruct.demo_struct;

%% Process & Draw demonstration's data
process_options.center_data = false;
process_options.tol_cutting = 1.;
process_options.dt = 0.1;
% [X, targets] = ProcessDemos(demo, 2, demo_struct);
[X, targets] = ProcessDemos(demo, 2, demo_struct, process_options);

draw_options.plot_pos = true;
draw_options.plot_vel = false; %true;
[fig_pos] = DrawData(X, targets, draw_options);
% [fig_pos, fig_vel] = DrawData(X, targets, draw_options);

%% Kernel PCA

% Set problem options
kpca_options.method_name  = 'KPCA';
kpca_options.nbDimensions = 6;
kpca_options.kernel       = 'gauss';
kpca_options.kpar         = 5;
kpca_options.norm_K = true;

% Solving KPCA
[mappedX_pca, mapping_pca] = ml_projection(X(1:2,:)', kpca_options);

% Storing results
kpca_data.xtrain                  = mapping_pca.X;
kpca_data.ktype                   = mapping_pca.kernel;
kpca_data.kpar.sigma              = mapping_pca.param1;
kpca_data.alphas                  = mapping_pca.V;
kpca_data.eigens                  = mapping_pca.L;
kpca_data.gram                    = mapping_pca.K;

% Plot Stremalines
plot_options.xlims = [0 100];
plot_options.ylims = [0 100];
plot_options.resoultion = 'medium';
plot_options.type = '3D';
plot_options.num_eigen = 6;
plot_options.plot_data = true;
plot_options.labels = X(end,:);
plot_options.plot_stream = false;

PlotEigenfun(kpca_data, plot_options);