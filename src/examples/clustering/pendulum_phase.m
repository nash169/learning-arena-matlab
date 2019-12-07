clear; close all; clc;

%% Load demos
load 'pendulum.mat'


%% Process joints data
dim = 2;
preprocess_options = struct('center_data', false,...
                            'calc_vel', true, ...
                            'tol_cutting', 1e-3, ... % 0.01
                            'smooth_window', 25, ...
                            'reduce_factor', 2 ...
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


%% Draw data
draw_options = struct('plot_pos', true, ...
                      'plot_vel', false ...
                      );
                  
DrawData(data, targets, draw_options);

%% Build graph
% Sigma estimation based on sample frequency
v_norm = V./vecnorm(V,2,2);
v_norm(isnan(v_norm)) = 0;
[m,~] = size(X);

max_d = max(vecnorm(V,2,2).*dt);
scale = 1;
sigma = scale*max_d;

% The first graph can be rebuild using epsilon neighborhoods
G1 = graph_build(X, 'type', 'eps-neighborhoods', 'r', sigma);

% The third graph is just epsilon neighborhoods using cosine kernel as
% distance between points
mycosine = cosine('isnan', 1);
G3 = graph_build(V, 'type', 'eps-neighborhoods', 'r', -0.9, 'fun', @(x,y) -mycosine.kernel(x,y));

% Total graph
G = G1.*G3;

%% Manifold Learning
% RBF kernel
myrbf = rbf('sigma', sigma);

%Velocity-augmented kernel
myvel = velocity_directed('sigma', sigma, 'v_field', {V,V}, 'weight', 0.5);

% Create object
ke = kernel_eca('kernel', myrbf);

% Set the dataset
ke.set_data(X);

% Set the graph
ke.set_graph(G1);

%% Plot spectral analysis
% Plot spectrum
ke.plot_spectrum;

% Plot entropy contribution
ke.plot_entropy;

% Plot the embedding
ke.plot_embedding([1,2]);

% Plot the eigenvectors
ke.plot_eigenvec([1,2]);

%% Clustering
thr = 3e-15;
U = ke.embedding([1,2]);
num_ds = 2;

% Cluster
labels_learn = (num_ds+1)*ones(length(labels),1);
for i = 1:num_ds
    labels_learn(abs(U(:,i))>thr) = i;
end

% Extract results
correct_class = sum(labels_learn==labels)*100/M;
class_start = 1;
class_end = sum(labels(labels==1));
per_class = zeros(num_ds,3);
for i = 1 : num_ds
    batch = labels_learn(class_start:class_end);
    correct = sum(batch==i);
    unknown = sum(batch==(num_ds+1));
    wrong = length(batch) - correct - unknown;
    
    per_class(i,1) = correct*100/length(batch);
    per_class(i,2) = wrong*100/length(batch);
    per_class(i,3) = unknown*100/length(batch);
    
    if i~=3
        class_start = class_start + sum(labels(labels==i)/i);
        class_end = class_end + sum(labels(labels==i+1)/(i+1));
    end
end

%% Attractor
x_attractor = zeros(num_ds,dim);
n = 10;
for i = 1:num_ds
    [~, index] = sort(abs(U(:,i)),'descend');
    x_attractor(i,:) = mean(x(index(1:n), :));
end
mse_attractor = vecnorm((x_attractor-targets)./3/std(x),2,2);

%% Re-plot data
data(end,:) = labels_learn;
DrawData(data, x_attractor, draw_options);

%% K-means comparison
km = k_means('cluster', 2, 'step', 20, 'norm', 2, 'soft', true);
km.set_data(x);
[labels_km, centroids] = km.cluster;
correct_class_km = sum(labels_km==labels)*100/M;
data(end,:) = labels_km;
DrawData(data, x_attractor, draw_options);