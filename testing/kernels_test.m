close all; clear; clc;

%% Load demos
load PaperTest2.mat;
demo = DataStruct.demo;
demo_struct = DataStruct.demo_struct;
% demo = ReducedData(demo, 10);
% [demo] = RegularizeTraj(demo);

%% Process data
proc_options = struct('center_data', false,...
                      'tol_cutting', 1.,...
                      'dt', 0.1...
                      );
[X, targets] = ProcessDemos(demo, 2, demo_struct, proc_options);
%%

% X = X(:,825:end);
x_train = X(1:2,:)';
v_train = X(3:4,:)';
% x_a = (x_train(84,:) + x_train(156,:) + x_train(227,:))/3;
% v_train = v_train/norm(max(v_train));

xs = linspace(0, 100, 100);
ys = linspace(0, 100, 100);
[Xs, Ys] = meshgrid(xs,ys);
x = [Xs(:),Ys(:)];

%% Draw data
draw_options = struct('plot_pos', true,...  % Draw the demonstrated positions
                      'plot_vel', false...  % Draw the demonstrated velocities
                      );
fig_pos = DrawData(X, targets, draw_options);

%% Manual Data
% x_test = [15,50
%           25,50
%           35,50
%           45,50
%           55,50
%           65,50
%           75,50
%           85,50];
% 
% v_test = [(x_test(2,:)-x_test(1,:))/norm(x_test(2,:)-x_test(1,:));
%           (x_test(3,:)-x_test(2,:))/norm(x_test(3,:)-x_test(2,:));
%           (x_test(4,:)-x_test(3,:))/norm(x_test(4,:)-x_test(3,:));
%           0,0];
    
% dist = norm(x_i(2,:)-x_i(1,:));
% sig_dist = 0.3;
% 
% kpar.sigma = sig_dist*dist;

%% Kernels
kpar.sigma = 3.; %sig_dist*dist;
kpar.r = 30;
kpar.rot = [0 1;-1 0];
kpar.lambda = 5;
kpar.epsilon = 0.0003;
kpar.lyap_type = 'transpose';

% a = 0; b = 0; c = 0; d = 1; e=1; m=0; g=0; h=0;

% Test for the rbf kernel
% [k_diff, dk_diff, d2k_diff] = Kernels('gauss',kpar);
% 
% kpar.sigma = 1; %6.5
[k, dk, d2k] = Kernels('gauss',kpar);
% f = a*k(x_test(1,:),x) + b*k(x_test(2,:),x) + c*k(x_test(3,:),x) + ...
%     d*k(x_test(4,:),x) + e*k(x_test(5,:),x) + m*k(x_test(6,:),x) + ...
%     g*k(x_test(7,:),x) + h*k(x_test(8,:),x);
% df =  a*dk(x_test(1,:),x) + b*dk(x_test(2,:),x) + c*dk(x_test(3,:),x) + d*dk(x_test(4,:),x);
% f = 0;
% k_mod = @(x,y) k(x,y) - k(x,x_a).*k(x_a,y)./k(x_a,x_a);
% for i = 1:size(x_train,1)
%    f = f +  k_mod(x_train(i,:),x);
% end
% f = k([30 50],x) + k([40 50],x) + k([70 50],x) + k([75 50],x) + k([80 50],x);
% df = k([25 50],x).*[1 0] + k([50 50],x).*[0 1] + k([50 50],x).*[0 0];

% Test of the cosine kernel
k2 = Kernels('cosine');
% f = k2([50 0],x);
% f = 0;
% for i = 1:size(x_train,1)
%    f = f +  k2(x_train(i,:),x);
% end

% Test of the symmetric anisotrpic covariance kernel
% k3 = Kernels('gauss_ns_std',kpar);
% It is not possible to apply the original non-stationary to a single point
% because the covariance matrix is not calculates correctly.
% f3 = a*k3(x_i(247,:),x) + b*k3(x_i(114,:),x);
% f3 = sum(reshape(f3,size(x,1),[]),2);
% f3 = f3(1:size(x,1));

% Test of the anisotropic velocity kernel
k4 = Kernels('gauss_ns',kpar);
[k_test, dk_test, d2k_test] = Kernels2('gauss_anisotr_vel', kpar);
[k_vel, dk_vel] = Kernels2('gauss_anisotr_vel', kpar);
f =  k_vel(x_train(100,:),x, x_train(100,:), v_train(100,:));
% f = k4([30 50],x, [100 0]) + k4([40 50],x,[100 0]) + k4([70 50],x,[50 0]) + k4([75 50],x,[50 0]) + k4([80 50],x,[50 0]);
% f4 = 0;
% for i = 1:size(x_train,1)
%     f4 = f4 + k4(x_train(i,:),x,v_train(i,:));
% end
% f = k_test([20,50],x,[1,0]);
% df = dk_test([20,50],x,[1,0]);
% dtest = d2k_test([20,50],x,[1,0]);

% Test of the asymmetric anisotropic covariance kernel
k5 = Kernels('gauss_ns_std_train', kpar);
k5 = @(x,y) k5(x,y,x_train);
% f = k5(x_train(2,:),x);
% f = 0;
% for i = 1:size(x_train,1)
%    f = f +  k5(x_train(i,:),x);
% end

% Test of the Lyapunov rbf kernel
[k6, dk6] = Kernels2('gauss_lyapunov', kpar);
kpar.slope =.0001;
filter = sigmoid(kpar);
% f = k6([40 50],x,[1 0]);% + filter(k6([45 50],x,[1 0])).*k6([45 50],x,[1 0]);
% f6 = 0;
% for i = 1:size(x_train,1)
%    f6 = f6 +  k6(x_train(i,:),x,v_train(i,:));
% end

% f = k6([50 50],x,[2 0]);
% df = dk6([50,50],x,[2,0]);

kpar.degree = 2;
% kpar.const = 20;
[k_pol] = Kernels2('polynomial',kpar);
% f = k_pol([0 50],x) +  k_pol([50 0],x);
% f = 0;
% for i = 1:size(x_train,1)
%    f = f +  k_pol(x_train(i,:),x);
% end

[k_prova, dk_prova] = Kernels2('gauss_anisotr_lyap', kpar);
% kpar.slope =.001;
% filter = sigmoid(kpar);
% p = k_prova([50 50],x,[5 0]);
% dp = dk_prova([50 50],x,[5 0]);

%% Draw Kernel
figure
hold on;
axis square;
contourf(Xs,Ys,reshape(f,100,100))
colorbar;
% scatter(50,50,'k.')
scatter(x_train(:,1),x_train(:,2),'k.')
% streamslice(Xs, Ys, reshape(df(:,1),100,100), reshape(df(:,2),100,100))

figure
surf(Xs,Ys,reshape(f,100,100))

% quiver(x_train(40,1), x_train(40,2), v_train(40,1), v_train(40,2))
% quiver(x_train(:,1),x_train(:,2),v_train(:,1)*15,v_train(:,2)*15,'k','LineWidth',1,'AutoScale','off')

%% Enumerate Data
% a = [1:size(x_i,1)]'; b = num2str(a); c = cellstr(b);
% dx = 0.1; dy = 0.1;
% text(x_i(:,1)+dx, x_i(:,2)+dy, c);