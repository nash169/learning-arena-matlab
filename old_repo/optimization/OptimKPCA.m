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

% Define training data
kpca_data.xtrain = X(1:2,:)';

% Define kernel
kpca_data.ktype = 'gauss';
kpca_data.kpar.sigma = 5;
k_rbf = Kernels('gauss', kpca_data.kpar);

% Calculate Gram matrix
K = GramMatrix(kpca_data.xtrain, kpca_data.xtrain, k_rbf, true);

% Initial conditions
alpha0 = rand(size(kpca_data.xtrain,1),1);

% Paramters for the optimization problem
f = OptimObjectives('kpca', K);

% Eigenvectors constraint for kPCA Optimization problem 1
c1 = OptimConstraints('K-norm1', K);

% Eigenvectors constraint for kPCA Optimization problem 2 (Classical kPCA)
c2 = OptimConstraints('norm1');

% Optimization options
options_optim = optimoptions('fmincon','SpecifyObjectiveGradient',true,'MaxFunctionEvaluations',1e6);

%% Solve the optimization problem

% First component
[optim1.alpha,optim1.fval,~,~,optim1.lambda] = fmincon(@(x) CreateFunHanlde(x, f),alpha0,[],[],[],[],[],[],...
                                                       @(x) CreateFunHanlde(x, c2), options_optim);

% Eigenvectors orthogonality constraint for successive components
% extraction
c3 = OptimConstraints('ortho', optim1.alpha);

% Second component
[optim2.alpha,optim2.fval,~,~,optim2.lambda] = fmincon(@(x) CreateFunHanlde(x, f),alpha0,[],[],[],[],[],[],...
                                                       @(x) CreateFunHanlde(x, c2, c3), options_optim);

% Storing results
kpca_data.alphas                  = [optim1.alpha optim2.alpha];
kpca_data.eigens                  = [optim1.lambda.ineqnonlin; optim2.lambda.ineqnonlin];
kpca_data.gram                    = K;

%% Plot Results

% Options for the plot
plot_options.xlims = [0 100];
plot_options.ylims = [0 100];
plot_options.resoultion = 'medium';
plot_options.type = '3D';
plot_options.num_eigen = 2;
plot_options.plot_data = true;
plot_options.labels = X(end,:);
plot_options.plot_stream = false;

PlotEigenfun(kpca_data, plot_options);
