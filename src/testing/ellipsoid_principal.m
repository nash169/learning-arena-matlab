clear; close all; clc;

a = 0.8; b = 0.2; c = 0.2;

% num_points = 3;
% A = rand(num_points);
% A = 0.5*(A+A') + eye(num_points)*num_points;
% A(1,1) = 1; A(2,2) = 1; A(3,3) = 1;
A = [1 a c; a 1 b; c b 1];

C = [0,0,0]';

p = sum(A,2);
D = diag(p);
M = D\A;
L = eye(3)-M;


[V,S,W] = eig(A);
[a, b] = sort(diag(S),'descend');
S = diag(a);
V = V(:,b);
W = W(:,b);

[V2,S2,W2] = eig(M);
[a, b] = sort(diag(S2),'descend');
S2 = diag(a);
V2 = V2(:,b);
W2 = W2(:,b);

plot_ellipse(A, C)
hold on;

quiver3(0,0,0,V(1,1),V(2,1),V(3,1),'r','MaxHeadSize',5, 'LineWidth', 2)
quiver3(0,0,0,V(1,2),V(2,2),V(3,2),'g','MaxHeadSize',5, 'LineWidth', 2)
quiver3(0,0,0,V(1,3),V(2,3),V(3,3),'b','MaxHeadSize',5, 'LineWidth', 2)
quiver3(0,0,0,p(1,1),p(2,1),p(3,1),'k')