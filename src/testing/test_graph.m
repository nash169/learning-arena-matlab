clear; close all; clc;

X = [1,1;
    2.5, 2;
    3.5,1.5];

m = size(X,1);

weights = [1; 0; 0];

myrbf = rbf('sigma', 1);
psi = kernel_expansion('reference', X, 'weights', weights, 'kernel', myrbf);
psi.set_data(100, -5,5,-5,5);

% psi.contour();

scatter(X(:,1), X(:,2), 'r', 'filled')
hold on;

% [mIdx,D] = knnsearch(X, X, 'K', 2, 'Distance', @(x,y) -myrbf.kernel(x,y));
G = graph_build(X, 'type', 'k-nearest', 'k', 2);

diff = repmat(X,m,1) - repelem(X,m,1);
x_pos = repelem(X,m,1);

quiver(x_pos(logical(G(:)),1),x_pos(logical(G(:)),2), diff(logical(G(:)),1), diff(logical(G(:)),2), 0)