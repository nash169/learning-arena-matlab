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
colors = hsv(length(unique(X(end,:))));
colors = colors(X(end,:),:);

%% Manifold Learning
% Create object
ke = kernel_eca;

% Set the dataset
ke.set_data(data);

% Set colors
ke.set_colors(colors);

% Set graph options
% ke.graph_options('type', 'k-nearest', 'k', 10);

% Solve the eigendecomposition
[D_ke,V_ke,W_ke] = ke.eigensolve;

% Plot the eigenfunctions
ke.plot_eigenfun([1,2], 'plot_stream', true);

% Plot the eigenvectors
ke.plot_eigenvec([1,2]);

% Plot the entropy contribution
ke.plot_entropy;

% Plot the spectrum
ke.plot_spectrum;

% Plot graph
% ke.plot_graph

% Plot data
ke.plot_data;

% Plot gramian
ke.plot_similarity;