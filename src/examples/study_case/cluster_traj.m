clear; close all; clc;

dt = 0.02;
dim = 3;

demo = load("demo_tr1.log");
demo = [demo'; 0:dt:(size(demo,1)-1)*dt];
demo = {demo};
demo_struct = {'position', 'time'};


preprocess_options = struct('center_data', false,...
                            'calc_vel', true, ...
                            'tol_cutting', 0.01, ...
                            'smooth_window', 25 ...
                            );
                        
[data, ~, ~, targets, ~] = ProcessDemos(demo, demo_struct, dim, preprocess_options);
X = data(1:dim,:)';
V = data(dim+1:2*dim,:)';
labels = data(end, :)';

max_d = max(vecnorm(V,2,2).*dt);
scale = 1.5;
sigma = scale*(max_d/3);

myrbf = rbf('sigma', 10);

% The first graph can be rebuild using epsilon neighborhoods
G1 = graph_build(X, 'type', 'eps-neighborhoods', 'r', 3*sigma);

% For the second graph it is necessary to use epsilon neighborhoods with
% non-euclidean distance (lyapunov kernel - with symmetric part set to zero)
mylyap = lyapunov('kernel', rbf('sigma', 5.), 'v_field', V, 'sym_weight', 0, 'isnan', 1, 'normalize', true);
G2 = graph_build(X, 'type', 'eps-neighborhoods', 'r', -0.8, 'fun', @(x,y) -mylyap.kernel(x,y));

% The third graph is just epsilon neighborhoods using cosine kernel as
% distance between points
mycosine = cosine('isnan', 1);
G3 = graph_build(V, 'type', 'eps-neighborhoods', 'r', -0.998, 'fun', @(x,y) -mycosine.kernel(x,y));

G = G1.*G3;

%% Manifold Learning
% Create object
ke = kernel_eca('kernel', myrbf);
% Set the dataset
ke.set_data(X);
% Set the graph
ke.set_graph(G);

%% Plot spectral analysis
% Plot spectrum
ke.plot_spectrum;
% Plot entropy contribution
ke.plot_entropy;
% Plot the embedding
ke.plot_embedding([1,2,3]);
% Plot the eigenvectors
ke.plot_eigenvec([1,2,3]);

%% Cluster data & find attractor location
U = abs(ke.embedding([1,2,3]));
labels(U(:,1)>1e-100) = 2;
labels(U(:,3)>1e-100) = 3;

colors = hsv(length(unique(labels)));
colors = colors(labels,:);

% Plot data
h = ke.plot_data(X, colors);