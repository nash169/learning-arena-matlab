clear; close all; clc;

%% Load demos
load 2as_3t.mat;

%% Process data
dim = 2;
preprocess_options = struct('center_data', false,...
                            'calc_vel', true, ...
                            'tol_cutting', 0.001, ...
                            'smooth_window', 25 ...
                            );
[X, ~, ~, targets, ~] = ProcessDemos(demo, demo_struct, dim, preprocess_options);

% Position
position = X(1:dim, :)';

% Velocity
velocity = X(dim+1:2*dim, :)';

% Time
time = X(end-dim,:)';

% Time interval
delta = X(end-1,:)';

% Labela & colors
labels = X(end,:)';
colors = hsv(length(unique(labels)));
colors = colors(labels,:);

% Sigma estimation based on sample frequency
max_d = max(vecnorm(velocity,2,2).*delta);
scale = 1.5;
sigma = scale*(max_d/3);

%% Build Graph
% The first graph can be rebuild using epsilon neighborhoods
G1 = graph_build(position, 'type', 'eps-neighborhoods', 'r', 3*sigma);

% For the second graph it is necessary to use epsilon neighborhoods with
% non-euclidean distance (lyapunov kernel)
mylyap = lyapunov('kernel', rbf('sigma', sigma), 'v_field', velocity, 'sym_weight', 1, 'isnan', 1, 'normalize', true);
% G2 = graph_build(position, 'type', 'eps-neighborhoods', 'r', -0.8, 'fun', @(x,y) -mylyap.kernel(x,y));
G2 = graph_build(position, 'type', 'k-nearest', 'k', 10, 'fun', @(x,y) -mylyap.kernel(x,y));

% The third graph is just epsilon neighborhoods using cosine kernel as
% distance between points
mycosine = cosine('isnan', 1);
G3 = graph_build(velocity, 'type', 'eps-neighborhoods', 'r', -0.9, 'fun', @(x,y) -mycosine.kernel(x,y));

%% Manifold Learning
% Create kernel
keca_kernel = rbf('sigma', sigma);
% Create object
ke = kernel_eca('kernel', keca_kernel);
% Set the dataset
ke.set_data(position);
% Set colors
ke.set_colors(colors);
% Set graph options
ke.set_graph(G1.*G2.*G3); % ke.graph_options('type', 'eps-neighborhoods', 'r', 3*sigma); (G2+G2')
% Solve the eigendecomposition
[D_ke,V_ke,W_ke] = ke.eigensolve;
% Plot the eigenfunctions
ke.plot_eigenfun([1,2], 'plot_stream', true, 'grid', [-2*pi, 4*pi, -2, 2], 'plot_data', true, 'colors', colors);
% Plot eigenvec
ke.plot_eigenvec;
% Plot entropy
ke.plot_entropy;
% Plot spectrum
ke.plot_spectrum;
% Plot graph
ke.plot_graph;
% Plot data
ke.plot_data;