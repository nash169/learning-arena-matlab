clear; close all; clc;

%% Load demos
load 2attracts_simple.mat;
demo = DataStruct.demo;
demo_struct = DataStruct.demo_struct;
demo = ReducedData(demo, 8);

%% Process data
proc_options = struct('center_data', false,...
                      'tol_cutting', 1.,...
                      'dt', 0.1...
                      );
[X, targets] = ProcessDemos(demo, 2, demo_struct, proc_options);
x_i = X(1:2,:)';
xdot_i = X(3:4,:)';
[m,~] = size(x_i);
alpha = rand(m,1);

%% Kernel
ktype = 'gauss';
kpar.sigma = 5.;
[k, dk] = Kernels(ktype,kpar);
gram_options = struct('norm', false,...
                      'vv_rkhs', false);
K = GramMatrix(k, gram_options, x_i, x_i);
devK = GramMatrix(dk, gram_options, x_i, x_i);

%% Test G
G_test1 = zeros(m,m);
G_test2 = zeros(m,m);
for i = 1:m
    for j = 1:m
        G_test1(j,i) = (x_i(j,:) - x_i(i,:))*xdot_i(i,:)'/kpar.sigma^2*k(x_i(j,:),x_i(i,:)); 
        G_test2(j,i) = dk(x_i(j,:),x_i(i,:))*xdot_i(i,:)';
    end
end
G = ColVelMatrix(x_i, xdot_i, dk);

%% Test Lyapunov
L_test1 = zeros(m,1);
L_test2 = zeros(m,1);
for i = 1:m
    for j = 1:m
        L_test1(i) = L_test1(i) + (x_i(j,:) - x_i(i,:))*xdot_i(i,:)'/kpar.sigma^2*k(x_i(j,:),x_i(i,:))*alpha(j); 
        L_test2(i) = L_test2(i) + alpha(j)*dk(x_i(j,:),x_i(i,:))*xdot_i(i,:)';
    end
end
L = G'*alpha;

%% Test Square Sum Lyapunov
phi = @(x) alpha'*k(x_i,x);
dphi  = @(x) sum(alpha.*dk(x_i,x));

LSS_test1 = 0;
LSS_test2 = 0;
LSS_test3 = 0;
for i = 1:m
    LSS_test1 = LSS_test1 + (dphi(x_i(i,:))*xdot_i(i,:)')^2;
end
for i = 1:m
    LSS_temp = 0;
    for j = 1:m
        LSS_temp = LSS_temp + (x_i(j,:) - x_i(i,:))*xdot_i(i,:)'/kpar.sigma^2*k(x_i(j,:),x_i(i,:))*alpha(j); 
    end
    LSS_test2 = LSS_test2 + LSS_temp^2;
    LSS_test3 = LSS_test3 + (dphi(x_i(i,:))*xdot_i(i,:)')^2;
end
LSS = alpha'*G*G'*alpha;

dPhi = @(alpha) sum(sum(repmat(alpha,size(x_i,1),1).*dk(x_i,x_i).*repmat(xdot_i,size(x_i,1),1),2).^2);

%% Test Square Lyapunov
LS_test1 = zeros(m,1);
LS_test2 = zeros(m,1);
for i = 1:m
    LS_test1(i) = (dphi(x_i(i,:))*xdot_i(i,:)')^2;
end
for i = 1:m
    LS_temp = 0;
    for j = 1:m
        LS_temp = LS_temp -(x_i(j,:) - x_i(i,:))*xdot_i(i,:)'/kpar.sigma^2*k(x_i(j,:),x_i(i,:))*alpha(j); 
    end
    LS_test2(i) = LS_temp^2;
end
LS = diag(G'*alpha*alpha'*G);
LS_test3 = (G'*alpha).*(G'*alpha);

%% Test Proj Variance
J_test = 0;
for i = 1:m
   J_test = J_test + phi(x_i(i,:))^2;
end
J = alpha'*K^2*alpha;

%% Test Normed Lyapunov
NL_test = zeros(m,1);
for i = 1:m
    NL_test(i) = (dphi(x_i(i,:))*xdot_i(i,:)')/(norm(dphi(x_i(i,:)))*norm(xdot_i(i,:)));
end
NL = G'*alpha./(sqrt(diag(devK(:,:,1)'*alpha*alpha'*devK(:,:,1)) +diag(devK(:,:,2)'*alpha*alpha'*devK(:,:,2))).*vecnorm(xdot_i,2,2));

%% Test Normed Square Lyapunov
NLS_test = zeros(m,1);
for i = 1:m
    NLS_test(i) = ((dphi(x_i(i,:))*xdot_i(i,:)')/(norm(dphi(x_i(i,:)))*norm(xdot_i(i,:))))^2;
    if norm(xdot_i(i,:)) == 0
        NLS_test(i) = 0;
    end
end
NLS = diag(G'*alpha*alpha'*G)./((diag(devK(:,:,1)'*alpha*alpha'*devK(:,:,1))...
    + diag(devK(:,:,2)'*alpha*alpha'*devK(:,:,2))).*vecnorm(xdot_i,2,2).^2);

NLS_test2 = (G'*alpha).^2./(sum(sum(permute(devK,[2,1,3]).*alpha',2).^2,3).*vecnorm(xdot_i,2,2).^2);
% NLS_test2(isnan(NLS_test2)) = 0;

%% Test Normed Square Sum Lyapunov
NLSS_test = sum(NLS_test);
NLSS = (alpha'*G*G'*alpha)/sum((diag(devK(:,:,1)'*alpha*alpha'*devK(:,:,1))...
    + diag(devK(:,:,2)'*alpha*alpha'*devK(:,:,2))).*vecnorm(xdot_i,2,2).^2);

%(dphi(x_i(i,:))*xdot_i(i,:)')^2;%/
% diag(G'*alpha*alpha'*G)./
% N = 0;
% N_vec = zeros(m,1);
% for i = 1:m
%    N = N + (norm(dphi(x_i(i,:)))*norm(xdot_i(i,:)))^2;
%    N_vec(i) = norm(dphi(x_i(i,:)))^2;
% end
% 
% devK = GramMatrix(x_i,x_i,dk);
% N2_vec = diag(devK(:,:,1)'*alpha*alpha'*devK(:,:,1)) +diag(devK(:,:,2)'*alpha*alpha'*devK(:,:,2));
% N2 = (diag(devK(:,:,1)'*alpha*alpha'*devK(:,:,1)) +...
%     diag(devK(:,:,2)'*alpha*alpha'*devK(:,:,2)))'*vecnorm(xdot_i,2,2).^2;

% alpha = [0.0567    0.5219    0.3358    0.1757    0.2089    0.9052    0.6754    0.4685    0.9121...
% 0.1040    0.7455    0.7363    0.5619    0.1842    0.5972    0.2999    0.1341    0.2126]';