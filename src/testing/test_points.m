clear; close all; clc

n_points = 9;
b = num2str([1:n_points]'); c = cellstr(b);
dx = 0.5; dy = 0.5;

x = [50, 50;
     25, 50;
     50, 75;
     75, 50;
     0, 50; %
     50, 100;
     100,50
     50, 25
     50, 0];
 
G = 0.5*eye(n_points);
G(1,2) = 1; 
G(1,3) = 1;
G(1,4) = 1;
G(2,5) = 1;
G(3,6) = 1;
G(4,7) = 1;
G(1,8) = 1;
G(8,9) = 1;

G = G+G';

length = 20.;
myrbf = rbf;
myrbf.set_params('sigma', 15.);
K = myrbf.gramian(x,x);

myrbf.plot_gram;

alpha = 1;
epsilon = 2*length^2;
S = K.*G;
D = diag(sum(S,2));
S_alpha  = D^-alpha*S*D^-alpha;
D_alpha = diag(sum(S_alpha,2));
M_alpha = D_alpha\S_alpha;
L_alpha = (eye(size(M_alpha)) - M_alpha)/epsilon;

L = eye(size(S)) - D\S;

[V, D] = eigs(L, n_points, 'smallestabs');

figure
plot(1:n_points, diag(D), '-o')
grid on

figure
scatter(x(:,1), x(:,2), 'filled')
axis([0 100 0 100])
grid on
hold on
scatter(x(7,1), x(7,2), 'r', 'filled')
text(x(:,1)+dx, x(:,2)+dy, c)

h = figure;
scatter(x(:,1), x(:,2), 'filled')
axis([0 100 0 100])
grid on
GraphDraw(x,G,h);


figure
scatter3(V(:,2), V(:,3), V(:,4), 'filled')
grid on
hold on
scatter3(V(7,2), V(7,3), V(7,4), 'r', 'filled')

% ops_exps = struct( ...
%     'grid', [0 100; 0 100], ...
%     'res', 100, ...
%     'plot_data', false, ...
%     'plot_stream', true ...
%     );
% 
% res = 100;
% psi = kernel_expansion;
% psi.set_data(x);
% psi.set_grid(res, 0, 100, 0, 100);
% psi.set_params('weights', V(:,1));
% psi.set_params('kernel', myrbf);
% psi.plot;
% psi.contour(ops_exps);
% 
% psi.set_params('weights', V(:,2));
% psi.plot;
% psi.contour(ops_exps);
% 
% psi.set_params('weights', V(:,3));
% psi.plot;
% psi.contour(ops_exps);
% 
% psi.set_params('weights', V(:,4));
% psi.plot;
% psi.contour(ops_exps);