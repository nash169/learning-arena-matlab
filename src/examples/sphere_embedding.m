clear; close all; clc;

% Data for scikit learn comparison
% data = load('sphere_data.csv');
% colors = load('colors.csv');

data = load('sphere_matlab.csv');

%% Generate dataset
r = 5.;
c = [1,2,3];
res = 50;
n_samples = 1000;
colors = linspace(1,10,n_samples);

% Create sphere
[theta, phi] = meshgrid(linspace(0, pi, res),linspace(0, 2*pi, res));
x = c(1) + r*sin(theta).*cos(phi);
y = c(2) + r*sin(theta).*sin(phi);
z = c(3) + r*cos(theta);

% % Sampling uniformly from a sphere
% data = randn(n_samples,3);
% data = data./vecnorm(data, 2, 2);
% data = c + r*data;

% %% Laplacian Eigenmaps
% lem = laplacian_eigenmaps('normalization', 'random-walk');
% % Set data
% lem.set_data(data);
% % Set colors
% lem.set_colors(colors);
% % Set graph options
% lem.graph_options('type', 'k-nearest', 'k', 10);
% % Solve the eigensystem for the transport
% [D_lem,V_lem,W_lem] = lem.eigensolve;
% % Plot sampled points and sphere
% h = figure;
% surf(x,y,z,'FaceAlpha',0.5);
% hold on;
% lem.plot_data(data, colors, h);
% % Plot embedding
% lem.plot_embedding([2,3,4]);
% % Plot graph in the original space
% lem.plot_graph;
% % Plot spectrum
% lem.plot_spectrum;

%% Diffusion Maps
% Set kernel
epsilon = 0.5;
myrbf = rbf('sigma', sqrt(epsilon/2));
% Create manifold learning method
dm = diffusion_maps('alpha', 1, 'kernel', myrbf, 'operator', 'infinitesimal', 'epsilon', epsilon/4);
% Set data
dm.set_data(data);
% Set colors
dm.set_colors(colors);
% Set graph options
dm.graph_options('type', 'k-nearest', 'k', 10);
% Solve the eigensystem for the transport
[D_dm,V_dm,W_dm] = dm.eigensolve;
% Plot sampled points and sphere
h = figure;
surf(x,y,z,'FaceAlpha',0.5);
dm.plot_data(data, colors, h);
% Plot embedding
dm.plot_embedding([2,3,4]);
% Plot graph in the original space
dm.plot_graph;
% Plot spectrum
dm.plot_spectrum;
