clear; close all; clc;

%% Load data
load ('pca_data.mat');
plot(X(:, 1), X(:, 2), 'bo');
axis([0.5 6.5 2 8]); axis square;

%% Mean normalization (data centering)
mu = mean(X);
X_norm = bsxfun(@minus, X, mu);

%% Feature scaling
X_norm = bsxfun(@rdivide, X_norm, std(X_norm));

%% Calculate covariance matrix
[m, ~] = size(X_norm);
C = (X_norm'*X_norm)/m;
% theta = pi/2;
% R = [cos(theta), sin(theta); -sin(theta), cos(theta)];
C = ones(2);

%% Solve eigensystem
[U, S, ~] = svd(C);

%% Draw results
hold on;
drawLine(mu, mu + 1.5 * S(1,1) * U(:,1)', '-k', 'LineWidth', 2);
drawLine(mu, mu + 1.5 * S(2,2) * U(:,2)', '-k', 'LineWidth', 2);
hold off;

%% Define fmincon inputs
fun = OptimObjectives('pca', C^2);
x0 = [0.5,1]';
nonlcon = OptimConstraints('l2Ball');
options = optimoptions('fmincon','SpecifyObjectiveGradient',true);

%% Solve the optimization problem
x = fmincon(fun,x0,[],[],[],[],[],[],nonlcon, options);

p=2;
f = @(x,A) diag(x*A*x');
c = @(x,A) diag(x*x') - 1;
% c = @(x) vecnorm(x,p,2).^p - 1;

x1 = -3:0.1:3;
x2 = x1;

[X1,X2] = meshgrid(x1, x2);
% c11 = C(1,1);
% c12 = C(1,2);
% c21 = C(2,1);
% c22 = C(2,2);
% 
% C(1,1) = c11;
% C(1,2) = -c12;
% C(2,1) = -c21;
% C(2,2) = c22;

z_fun = reshape(f([X1(:),X2(:)], C^2), length(x2), length(x1));
z_constr = reshape(c([X1(:),X2(:)], C), length(x2), length(x1));

f_eval = f(x', C^2);

figure
surf(X1,X2,z_fun);
hold on;
surf(X1,X2,z_constr);

figure
contour(X1,X2,z_fun)
hold on; axis equal;
contour(X1,X2,z_fun, [f_eval f_eval], 'LineWidth', 2, 'color', 'r')
contour(X1,X2,z_constr, [0 0], 'LineWidth', 2)
scatter(x(1),x(2),150)
drawLine([0 0], -0.5*U(:,1)', '-k', 'LineWidth', 2);
drawLine([0 0], 0.5*U(:,2)', '-k', 'LineWidth', 2);