clear; close all; clc;

%% Load demos
load 2as_3t.mat

%% Process data
dim = 2;
preprocess_options = struct('center_data', false,...
                            'calc_vel', true, ...
                            'tol_cutting', 0.01, ...
                            'smooth_window', 25 ...
                            );
[X, ~, ~, targets, ~] = ProcessDemos(demo, demo_struct, dim, preprocess_options);

position = X(1:dim, :)';
velocity = X(dim+1:2*dim, :)';
delta = X(end-1,:)';

%% Build Graph
max_d = max(vecnorm(velocity,2,2).*delta);
scale = 1.5;
sigma = scale*(max_d/3);

% The first graph can be rebuild using epsilon neighborhoods
G1 = graph_build(position, 'type', 'eps-neighborhoods', 'r', 3*sigma);

% For the second graph it is necessary to use epsilon neighborhoods with
% non-euclidean distance (lyapunov kernel - with symmetric part set to zero)
mylyap = lyapunov('kernel', rbf('sigma', 5.), 'v_field', velocity, 'sym_weight', 0, 'isnan', 1, 'normalize', true);
G2 = graph_build(position, 'type', 'eps-neighborhoods', 'r', -0.8, 'fun', @(x,y) -mylyap.kernel(x,y));

% The third graph is just epsilon neighborhoods using cosine kernel as
% distance between points
mycosine = cosine('isnan', 1);
G3 = graph_build(velocity, 'type', 'eps-neighborhoods', 'r', -0.9, 'fun', @(x,y) -mycosine.kernel(x,y));