%% Data generation
clear; close all; clc;

% Create cluster 1
cluster1 = 25*rand(100,3);
cluster1 = cluster1 - mean(cluster1);

% Create cluster 2
cluster2 = 25*rand(100,3);
cluster2 = cluster2 - mean(cluster2);

% Create cluster 3
cluster3 = 25*rand(100,3);
cluster3 = cluster3 - mean(cluster3);

% Create cluster 4
cluster4 = 25*rand(100,3);
cluster4 = cluster4 - mean(cluster4);

% Create dataset
data = [cluster1 + [25,25,25]; cluster2 + [25,25,75]; cluster3 + [50,50,50]; cluster4 + [75,50,25]];

% Place clusters
% scatter(data(:,1), data(:,2), 'filled');
% axis([0 100 0 100]); grid on;

% Test set
test = rand(1000,3);

%% K-Means
km = k_means('cluster', 4, 'step', 10, 'norm', 2, 'soft', true);
km.set_data(data);
[labels, centroids] = km.cluster;

%% Kernel PCA
% Create object
kp = kernel_pca;
% Set the dataset
kp.set_data(data);
% Get the similarity matrix
S_kp = kp.similarity;
% Solve the eigendecomposition
[D_kp,V_kp,W_kp] = kp.eigensolve;
% Get the degree matrix
deg_kp = kp.degree;
% Get the eigenfunctions for the points in 'test'
funs_kp = kp.eigenfun(test);
% Get the embedding defined by the eingenvectors in 'space'
U_kp = kp.embedding([1,2]);
% Plot the eigenfunctions
kp.plot_eigenfun;
% Plot the embedding
kp.plot_embedding([1,2]);
% Plot the similarity matrix
kp.plot_similarity;

%% Diffusion Maps
% Create object
dm = diffusion_maps;
% Set the dataset
dm.set_data(data);
% Set graph options
dm.graph_options('type', 'k-nearest', 'k', 10);
% Get the similarity matrix
S_dm = dm.similarity;
% Get the degree matrix (of the similarity)
Deg_dm = dm.degree;
% Get the transport matrix
M_dm = dm.transport;
% Get the infinitesimal matrix
L_dm = dm.infinitesimal;
% Solve the eigensystem for the transport
[D_m,V_m,W_m] = dm.eigensolve;
% Get the degree matrix
deg_dm = dm.degree;
% Get the eigenfunctions for the points in 'test'
funs_dm = dm.eigenfun(test);
% Get the embedding defined by the eingenvectors in 'space'
U_dm = dm.embedding([1,2]);
% Plot the eigenfunctions
dm.plot_eigenfun;
% Plot the embedding
dm.plot_embedding([1,2]);
% Plot the similarity matrix
dm.plot_similarity;
% Solve the eigensystem for the infinitesimal
dm.set_params('operator', 'infinitesimal');
[D_l,V_l,W_l] = dm.eigensolve;

%% Laplacian Eigenmaps
le = laplacian_eigenmaps;
% Set data
le.set_data(data);
% Get the similarity matrix
S_le = le.similarity;
% Get the degree matrix (of the similarity)
D_le = le.degree;
% Get the infinitesimal matrix
L_le = le.laplacian;
% Solve the eigensystem for the transport
[D_lem,V_lem,W_lem] = le.eigensolve;
% Get the eigenfunctions for the points in 'test'
funs_le = le.eigenfun(test);
% Plot the spctrum
le.plot_spectrum(1:9);
% Plot the graph
le.plot_graph; 
% PLot the embedding
le.plot_embedding([1,2]);
% Plot the first eigenfunction
le.plot_eigenfun(1, 'plot_stream', true);
% Plot the similarity matrix
le.plot_similarity;
% Set graph
% le.set_graph(G);
