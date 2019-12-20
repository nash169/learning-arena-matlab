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

%% Create velocities dataset
v = [];
for i=1:3:size(x,1)
    v = [v; (x(i+1:i+step-1,:) - x(i:i+step-2,:)) ./ vecnorm(x(i+1:i+step-1,:) - x(i:i+step-2,:),2,2); 0 0];
end

lambdas = [3,2,1,3,2,1,3,2,1];
v = lambdas'.*v;

%% Create graph
G = 0.5*eye(num_points);
G(1,2) = 1; G(2,3) = 1;
G(4,5) = 1; G(5,6) = 1;
G(7,8) = 1; G(8,9) = 1;
G(3,6) = 1; G(6,9) = 1; G(3,9) = 1;
% G = G+G';

%% Create kernel
length = 15.;
myrbf = rbf;
myrbf.set_params('sigma', length);
K = myrbf.gramian(x,x);
myrbf.plot_gramian;

%% Laplacian Eigenmaps
le = laplacian_eigenmaps('kernel', myrbf);
% Set data
le.set_data(x);
% Set graph
le.set_graph(G);
% Solve the eigensystem for the transport
[D,V,W] = le.eigensolve;
% Plot graph
le.plot_graph;
% Plot spectrum
le.plot_spectrum(1:num_points);
% Plot embedding
le.plot_embedding([2,3]);

%% Gaussian Process
% % Create targets set
% x_a = ([V(3,2), V(3,3)] + [V(6,2), V(6,3)] + [V(9,2), V(9,3)])/3;
% y = vecnorm(x-x_a, 2, 2);
% 
% % Reset kernel parameters
% myrbf.set_params('sigma_n', 0.2, 'sigma_f', 1);
% 
% % Create GP
% mygp = gaussian_process('kernel', myrbf, 'targets', y);
% mygp.set_data(x);
% 
% % Plot GP
% mygp.set_grid(100, 0, 100, 0, 100);
% ops_exps = struct( ...
%     'grid', [0 100; 0 100], ...
%     'res', 100, ...
%     'plot_data', true, ...
%     'plot_stream', true ...
%     );
% mygp.plot;
% g = mygp.contour(ops_exps);

% Number visualization (to implement in manifold_learning class). Also add
% the possibility of plotting dataset in kernel_expansion class
% b = num2str([1:num_points]'); c = cellstr(b);
% dx = 0.5; dy = 0.5;
% figure
% scatter(x(:,1), x(:,2), 'filled')
% text(x(:,1)+dx, x(:,2)+dy, c)
% axis([0 100 0 100])
% grid on; hold on;
% quiver(x(:,1), x(:,2), v(:,1), v(:,2))