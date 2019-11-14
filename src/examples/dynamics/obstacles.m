clear; close all; clc;

%% Test points
res = 100;
[x,y] = meshgrid(linspace(0,res,res), linspace(0,res,res));
X = [x(:), y(:)];

%% Basic energy
x_a = [25,50];
scale = 0.01;
V = scale*sum((X-x_a).*(X-x_a),2);
dV = scale*2*(X-x_a);

%% Kernel
U1 = gs_orthogonalize([1,1]);
U2 = gs_orthogonalize([1,-1]);
D1 = [1/10^2;1/6^2].*eye(2);
D2 = [1/10^2;1/6^2].*eye(2);
S1 = U1'*D1*U1;
S2 = U2'*D2*U2;
sigma = [S1; S2];
myrbf = rbf;
myrbf.set_params('sigma', 0, 'sigma_inv', sigma);

%% Expansion
x_ref = [60,40; 60, 60];
weights = [100,100]';
psi = kernel_expansion('kernel', myrbf, 'reference', x_ref, 'weights', weights);
O = psi.expansion(X);
dO = psi.gradient(X);

%% Plot
figure (1)
surf(x,y, reshape(V+O,res,[]))

figure (2)
contourf(x,y, reshape(V+O,res,[]))
hold on;
h = streamslice(x,y,reshape(-dV(:,1)-dO(:,1),res,[]),reshape(-dV(:,2)-dO(:,2),res,[]));
set(h, 'Color', 'r')
axis square