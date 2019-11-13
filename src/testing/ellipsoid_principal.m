clear; close all; clc;

N = 3;

% A = rand(N);
% A = 0.5*(A+A') + eye(num_points)*N;
% A(1,1) = 1; A(2,2) = 1; A(3,3) = 1;

a = 0.8; b = 0.3; c = 0.5;
A = [1 a c; a 1 b; c b 1];

[V,S,W] = eig(A);
[u, v] = sort(diag(S),'descend');
S = diag(u);
V = V(:,v);
W = W(:,v);

T = V(:,1)*V(:,1)';
p_w = sum(A,2)/N;
p_1 = [sum(T*[1, a, c]'), sum(T*[a, 1, b]'), sum(T*[c, b, 1]')]'/3;
p_m = sum(V*V'*A,2)/3;

plot_ellipse(A, [0,0,0]')
hold on;

quiver3(0,0,0,V(1,1),V(2,1),V(3,1),'r','MaxHeadSize',5, 'LineWidth', 2)
quiver3(0,0,0,V(1,2),V(2,2),V(3,2),'g','MaxHeadSize',5, 'LineWidth', 2)
quiver3(0,0,0,V(1,3),V(2,3),V(3,3),'b','MaxHeadSize',5, 'LineWidth', 2)
quiver3(0,0,0,p_w(1,1),p_w(2,1),p_w(3,1),'k')
quiver3(0,0,0,p_1(1,1),p_1(2,1),p_1(3,1),'g')