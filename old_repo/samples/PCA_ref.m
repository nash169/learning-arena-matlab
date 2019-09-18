clear; close all; clc;

% Load Data
load ('pca_data.mat');

theta = pi/2;
R = [cos(theta) sin(theta); -sin(theta) cos(theta)];
% X = X*R';

% Plot Data
plot(X(:, 1), X(:, 2), 'bo');
axis([0.5 6.5 2 8]); axis square;

% Mean normalization and scaling
mu = mean(X);
X_norm = bsxfun(@minus, X, mu);
sigma = std(X_norm);
X_norm = bsxfun(@rdivide, X_norm, sigma);

% Eigenvalue problem
[m, n] = size(X_norm);
C = (X_norm'*X_norm)/m;
[U, S, ~] = svd(C);

% Draw eigenvectors
hold on;
drawLine(mu, mu + 1.5 * S(1,1) * U(:,1)', '-k', 'LineWidth', 2);
drawLine(mu, mu + 1.5 * S(2,2) * U(:,2)', '-k', 'LineWidth', 2);
hold off;

x1 = -5:0.1:5;
x2 = -5:0.1:5;

[X1,X2] = meshgrid(x1, x2);

f = @(X,A) diag(X*A*X');
c = @(X) vecnorm(X,2,2).^2 - 1;

% figure (2)
% surfc(X1,X2, reshape(f, length(x2), length(x1)));
% hold on
% surfc(X1,X2, reshape(c, length(x2), length(x1)));

C(1,1) = C(1,1) + 0;
% C(1,2) = C(1,2) + ;
% C(2,1) = C(2,1) + ;
C(2,2) = C(2,2) + 0;

figure (3)
contour(X1,X2, reshape(f([X1(:),X2(:)], C), length(x2), length(x1)));
contour(X1,X2, reshape(f([X1(:),X2(:)], C), length(x2), length(x1)),[f([U(1,1),U(2,1)], C) f([U(1,1),U(2,1)], C)],'LineWidth',2)
hold on
axis equal
contour(X1,X2, reshape(c([X1(:),X2(:)]), length(x2), length(x1)));
contour(X1,X2, reshape(c([X1(:),X2(:)]), length(x2), length(x1)),[0 0],'LineWidth',2)
scatter(U(1,1),U(2,1));
scatter(U(1,2),U(2,2));
contour(X1,X2, reshape(f([X1(:),X2(:)], S), length(x2), length(x1)))