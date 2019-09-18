clear; close all; clc

%% Create dataset
n_points = 9;
x = [50, 50;
     25, 50;
     50, 75;
     75, 50;
     0, 50; %
     50, 100;
     100,50
     50, 25
     50, 0];

%% Create graph
G = 0.5*eye(n_points);
G(1,2) = 1; 
G(1,3) = 1;
G(1,4) = 1;
G(2,5) = 1;
G(3,6) = 1;
G(4,7) = 1;
G(1,8) = 1;
G(8,9) = 1;

% Symmetrize connections
G = G+G';

%% Create diffusion kernel
length = 15.;
myrbf = rbf;
myrbf.set_params('sigma', length);
K = myrbf.gramian(x,x);

Plot gramian
myrbf.plot_gramian;

%% Laplacian Eigenmaps
le = laplacian_eigenmaps('kernel', myrbf);
% Set data
le.set_data(x);
% Set graph
le.set_graph(G);
% Solve the eigensystem for the transport
[D,V,W] = le.eigensolve;
% Plot the spctrum
le.plot_spectrum(1:9);
% Plot the graph
le.plot_graph; 
% PLot the embedding
le.plot_embedding([2,3,4]);
% Plot the first eigenfunction
le.plot_eigenfun(1, 'plot_stream', true);
% Plot the second eigenfunction
le.plot_eigenfun(2, 'plot_stream', true);
% Plot the fourth eigenfunction
le.plot_eigenfun(3, 'plot_stream', true);
% Plot the fifth eigenfunction
le.plot_eigenfun(4, 'plot_stream', true);