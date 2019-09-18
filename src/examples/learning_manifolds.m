%% Data generation
clear; close all; clc;

% Create cluster 1
cluster1 = 35*rand(100,2);
cluster1 = cluster1 - mean(cluster1);

% Create cluster 2
cluster2 = 35*rand(100,2);
cluster2 = cluster2 - mean(cluster2);

% Place clusters
data = [cluster1 + [25,50]; cluster2 + [75,50]];
scatter(data(:,1), data(:,2), 'filled');
axis([0 100 0 100]); grid on;

% Test set
test = rand(1000,2);

%% Kernel PCA

% Create object
kp = kernel_pca;
% Set the dataset
kp.set_data(data);
% Get the similarity matrix
S_kp = kp.similarity;
% Solve the eigendecomposition
[V_kp,W_kp,D_kp] = kp.eigensolve;
% Get the degree matrix
deg_kp = kp.deegre;
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
dm = kernel_pca;
% Set the dataset
dm.set_data(data);
% Get the similarity matrix
S_dm = dm.similarity;
% Solve the eigendecomposition
[V_dm,W_dm,D_dm] = dm.eigensolve;
% Get the degree matrix
deg_dm = dm.deegre;
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

%% Laplacian Eigenmaps

% Create object
le = kernel_pca;
% Set the dataset
le.set_data(data);
% Get the similarity matrix
S_le = le.similarity;
% Solve the eigendecomposition
[V_le,W_le,D_le] = le.eigensolve;
% Get the degree matrix
deg_le = le.deegre;
% Get the eigenfunctions for the points in 'test'
funs_le = le.eigenfun(test);
% Get the embedding defined by the eingenvectors in 'space'
U_le = le.embedding([1,2]);
% Plot the eigenfunctions
le.plot_eigenfun;
% Plot the embedding
le.plot_embedding([1,2]);
% Plot the similarity matrix
le.plot_similarity;
