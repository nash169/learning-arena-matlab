close all; clear; clc;

%% Data
xs = linspace(0, 100, 100);
ys = linspace(0, 100, 100);
[Xs, Ys] = meshgrid(xs,ys);
x = [Xs(:),Ys(:)];

x_i = [45,50;   % 30,50 - 45,50
       55,50];  % 70,50 - 55,50
%      6,14
%      34,33];

%% Kernel
kpar.sigma = 5.;
[k, dk, d2k] = Kernels('gauss',kpar);

a = 1; b = 1; c = 1; d = 1;
f = a*k(x_i(1,:),x) + b*k(x_i(2,:),x);

%% Draw contour
figure (1)
hold on;
axis square
contourf(Xs,Ys,reshape(f,100,100))
scatter(x_i(:,1),x_i(:,2),'k.')

%% draw isolines
x_sig = kpar.sigma;
feval = a*k(x_i(1,:),x_i(1,:)+x_sig) + b*k(x_i(2,:),x_i(2,:)+x_sig);
feval1 = a*k(x_i(1,:),x_i(1,:) + x_sig);
feval2 = b*k(x_i(2,:),x_i(2,:) + x_sig);

figure (2)
hold on;
axis equal;
contour(Xs,Ys,reshape(k(x_i(1,:),x),100,100), [feval1 feval1], 'LineWidth', 2, 'color', 'r')
contour(Xs,Ys,reshape(k(x_i(2,:),x),100,100), [feval2 feval2], 'LineWidth', 2, 'color', 'r')
contour(Xs,Ys,reshape(f,100,100), [feval feval], 'LineWidth', 2, 'color', 'b')
scatter(x_i(:,1), x_i(:,2))

%% Draw Hessian's Eigenvalues - Varying Sigma
figure (3)
axis square;
hold on;

figure (4)

[x_h, y_h] = meshgrid(40:5:60,40:5:60);
x_test = [x_h(:) y_h(:)];
v = [1:size(x_test,1)]'; w = num2str(v); z = cellstr(w);
dx = 0.1; dy = 0.1;

D = zeros(10,size(x_test,1),2);

for i=1:5
    kpar.sigma = i;
    [k, dk, d2k] = Kernels('gauss', kpar);
    f = -k(x_i(1,:),x) - k(x_i(2,:),x);
    
    figure (3)
    contourf(Xs,Ys,reshape(f,100,100))
    scatter(x_test(:,1),x_test(:,2),'filled')
    scatter(x_i(:,1), x_i(:,2), 'd', 'filled')
    text(x_test(:,1)+dx, x_test(:,2)+dy, z);
    
    figure (4)
    for j = 1:size(x_test,1)
        D(i,j,:) = eig(full(BlkMatrix(sum(-d2k(x_i,x_test(j,:))))));
        subplot(5,5,j)
        plot(1:i,D(1:i,j,1), 'b');
        hold on;
        plot(1:i,D(1:i,j,2), 'r')
        title(strcat('point ', num2str(j)))
        grid on;
    end
    
    pause(1);
end

%% Draw Hessian's Eigenvalues - Varying Distance
% figure (3)
% axis square;
% hold on;
% 
% figure (4)
% axis square;
% hold on;
% 
% log_D1 = [];
% log_D2 = [];
% 
% range = 14;
% 
% for i=1:range
%    x1 = x_i(1,:)+[i 0];
%    x2 = x_i(2,:)+[-i 0];
%    f = a*k(x1,x) + b*k(x2,x);
%    D1 = eig(full(BlkMatrix(sum(d2k([x1;x2],x1)))));
%    D2 = eig(full(BlkMatrix(sum(d2k([x1;x2],[50 60])))));
%    log_D1 = [log_D1 D1];
%    log_D2 = [log_D2 D2]; 
%    
%    figure (3)
%    contourf(Xs,Ys,reshape(f,100,100))
%    
%    figure (4)
%    subplot(2,2,1)
%    plot(1:i, log_D1(1,:))
%    axis([1 range -0.09 -0.03])
%    subplot(2,2,2)
%    plot(1:i, log_D1(2,:))
%    axis([1 range -0.09 -0.02])
%    subplot(2,2,3)
%    plot(1:i, log_D2(1,:))
% %    axis([1 range -0.09 -0.03])
%    subplot(2,2,4)
%    plot(1:i, log_D2(2,:))
% %    axis([1 range -0.09 -0.02])
%    
%    pause(0.5)
% %    scatter(x_i(:,1),x_i(:,2),'k.')
% end