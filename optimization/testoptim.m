close all; clear; clc;
x1 = -3:0.1:3;
x2 = x1;

[X1,X2] = meshgrid(x1, x2);

f = (X1(:)-2).^2 + 2*(X2(:)-1).^2;
c = X1(:)  + 4*X2(:) - 3;

f2 = X1(:) + X2(:);
% c2 = X1(:).^2  + X2(:).^2 - 1;
c2 = vecnorm([X1(:) X2(:)],2,2).^2 - 1;

A = [-1 -4];
b = -3;
Aeq = [-1 -4];
beq = -3;

[x,fval,exitflag,output,lambda,grad,hessian] = fmincon(@test_function, [0.4149 0.1701],A,b);

figure (1)
surfc(X1,X2, reshape(f, length(x2), length(x1)));
hold on
surfc(X1,X2, reshape(c, length(x2), length(x1)));

figure (3)
contour(X1,X2, reshape(f, length(x2), length(x1)));
hold on
axis equal
contour(X1,X2, reshape(c, length(x2), length(x1)));
contour(X1,X2, reshape(c, length(x2), length(x1)),[0 0],'LineWidth',2)

figure (4)
contour(X1,X2, reshape(f2, length(x2), length(x1)));
hold on
axis equal
contour(X1,X2, reshape(c2, length(x2), length(x1)));
contour(X1,X2, reshape(c2, length(x2), length(x1)),[0 0],'LineWidth',2)

figure (2)
L = f; 
surf(X1,X2, reshape(f2, length(x2), length(x1)));
hold on
surfc(X1,X2, reshape(c2, length(x2), length(x1)));
% lambda = 1;
% L = f + lambda*c;
% surf(X1,X2, reshape(L, length(x2), length(x1)));
% L = f + lambda*c;
% surf(X1,X2, reshape(L, length(x2), length(x1)));
% surfc(X1,X2, reshape(c, length(x2), length(x1)));