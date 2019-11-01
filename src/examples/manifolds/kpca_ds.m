clear; close all; clc;

%% Load demos
load 2as_3t.mat;

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
kp = kernel_pca('centering', false);
% Set the dataset
kp.set_data(data);
% Set colors
kp.set_colors(colors);
% Solve the eigendecomposition
[D_kp,V_kp,W_kp] = kp.eigensolve;
% Plot the eigenfunctions
kp.plot_eigenfun([1,2]);
% Plot the embedding
kp.plot_embedding([1,2,3]);
% Plot data
kp.plot_data;