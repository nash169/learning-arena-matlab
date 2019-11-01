clear; close all; clc;

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

% Uniformly sampled point
data = load('sphere_matlab.csv');

%% Manifold Learning
lem = laplacian_eigenmaps('normalization', 'symmetric');
% Set data
lem.set_data(data);
% Set colors
lem.set_colors(colors);
% Set graph options
lem.graph_options('type', 'k-nearest', 'k', 10);
% Solve the eigensystem for the transport
[D_lem,V_lem,W_lem] = lem.eigensolve;
% Plot sampled points and sphere
h = figure;
surf(x,y,z,'FaceAlpha',0.5);
hold on;
lem.plot_data(data, colors, h);
% Plot embedding
lem.plot_embedding([2,3,4]);
% Plot graph in the original space
lem.plot_graph;
% Plot spectrum
lem.plot_spectrum;

%% Metric Learner
ml = metric_learner('manifold', lem, 'space', [2,3,4], 'dim', 2);
[h_inv, d] = ml.metric;