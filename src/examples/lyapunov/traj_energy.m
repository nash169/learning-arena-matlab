clear; close all; clc;

%% Load demos
load 'drawn_demo.mat'


%% Process joints data
dim = 2;
preprocess_options = struct('center_data', false,...
                            'calc_vel', true, ...
                            'tol_cutting', 1e-4, ... % 0.01
                            'smooth_window', 25, ...
                            'reduce_factor', 1 ...
                        );
                        
[data, ~, ~, targets, ~] = ProcessDemos(demo, demo_struct, dim, preprocess_options);

% Extract data
x = data(1:dim, :)';
v = data(dim+1:2*dim, :)';
dt = data(end-1,:)';
labels = data(end,:)';
M = size(x,1);

% Normalize
X = (x - mean(x))./std(x);
V = (v - mean(v))./std(v);

% Sigma estimation based on sample frequency
v_norm = V./vecnorm(V,2,2);
v_norm(isnan(v_norm)) = 0;
[m,~] = size(X);

max_d = max(vecnorm(V,2,2).*dt);
scale = 1;
sigma = scale*max_d;

%% Draw data
draw_options = struct('plot_pos', true, ...
                      'plot_vel', false ...
                      );
                  
DrawData(data, targets, draw_options);

%% Create kernels
% RBF kernel
myrbf = rbf('sigma', sigma);

% Velocity-augmented kernel
myvel = velocity_directed('sigma', sigma, 'v_field', {V,V}, 'weight', 0.5);

% Lyapunov kernel
mylyap = lyapunov('kernel', rbf('sigma', sigma), 'v_field', V, 'sym_weight', 0, 'isnan', 1, 'normalize', true);

% Cosine kernel
mycosine = cosine('isnan', 1);

%% Build graph
% The first graph can be rebuild using epsilon neighborhoods
G1 = graph_build(X, 'type', 'eps-neighborhoods', 'r', sigma);

% For the second graph it is necessary to use epsilon neighborhoods with
% non-euclidean distance (lyapunov kernel - with symmetric part set to zero)
G2 = graph_build(X, 'type', 'eps-neighborhoods', 'r', -0.8, 'fun', @(x,y) -mylyap.kernel(x,y));

% The third graph is just epsilon neighborhoods using cosine kernel as
% distance between points
G3 = graph_build(V, 'type', 'eps-neighborhoods', 'r', -0.9, 'fun', @(x,y) -mycosine.kernel(x,y));

% Total graph
G = G1.*G3;

%% Manifold Learning
% Create object
dm = diffusion_maps('kernel', myrbf);

% Set the dataset
dm.set_data(X);

% Set the graph
dm.set_graph(G2);

%% Plot spectral analysis
% % Plot spectrum
% ke.plot_spectrum;
% 
% % Plot the embedding
% ke.plot_embedding([1,2]);
% 
% % Plot the eigenvectors
% ke.plot_eigenvec([1,2]);