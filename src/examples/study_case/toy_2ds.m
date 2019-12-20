clear; close all; clc;

%% Create position dataset
step = 3;
num_points = 9;
x = [10 25; 
     40 55; 
     70 75; 
     35 10; 
     50 40; 
     75 70;
     80 10; 
     70 35; 
     80 70];

theta = pi;
trasl = [90,-50];
R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
xr = (R*(x-mean(x))')' + mean(x) + trasl;
X = [x;xr];
labels = [ones(size(x,1),1); 2*ones(size(xr,1),1)];
colors = hsv(length(unique(labels)));
colors = colors(labels,:);

%% Create graph
G = 0.5*eye(num_points);
G(1,2) = 1; G(2,3) = 1;
G(4,5) = 1; G(5,6) = 1;
G(7,8) = 1; G(8,9) = 1;
G(3,6) = 1; G(6,9) = 1; G(3,9) = 1;
G = G+G';
G = blkdiag(G,G);

%% Randomize data
% idx = randperm(size(X,1));
% X = X(idx, :);
% labels = labels(idx);
% G = G(idx,idx);

%% Create kernel
length = 15.;
myrbf = rbf;
myrbf.set_params('sigma', length);
K = myrbf.gramian(X,X);
myrbf.plot_gramian;

%% Kernel ECA
ke = kernel_eca('kernel', myrbf);
% Set data
ke.set_data(X);
% Set graph
ke.set_graph(G);
% Solve the eigensystem for the transport
[D,V,W] = ke.eigensolve;
% Plot graph
ke.plot_graph;
% Plot spectrum
ke.plot_spectrum(1:num_points);
% Plot data
ke.plot_data(X, colors);
% Plot eigenvector
ke.plot_eigenvec([1,2,3,4]);