clear; close all; clc;

%% Load demos
load 1attracts_simple.mat;
demo = DataStruct.demo;
demo_struct = DataStruct.demo_struct;
demo = ReducedData(demo, 5);

%% Process data
proc_options = struct('center_data', false,...
                      'tol_cutting', 1.,...
                      'dt', 0.1...
                      );
[X, targets] = ProcessDemos(demo, 2, demo_struct, proc_options);
x_i = X(1:2,:)';
xdot_i = X(3:4,:)';
[m,dim] = size(x_i);

%% Draw data
draw_options = struct('plot_pos', true,...  % Draw the demonstrated positions
                      'plot_vel', false...  % Draw the demonstrated velocities
                      );
fig_pos = DrawData(X, targets, draw_options);

%% Build kernels
kpar = struct('sigma', 5.5,...
              'r', 3*5,...
              'sigma_vel', 0.01,...
              'sigma_attract', 1,...
              'lambda', 30,... *1/3
              'degree', 1.,...
              'const', 1.);
              
[rbf, drbf, d2rbf] = Kernels('gauss', kpar);
[rbf_c, drbf_c] = Kernels('gauss_compact', kpar);
cosine = Kernels('cosine');

[rbf_v, drbf_v] = Kernels('gauss_vel', kpar);
rbf_v = @(x,y) rbf_v(x,y,xdot_i);
drbf_v = @(x,y) drbf_v(x,y,xdot_i);

[rbf_vc, drbf_vc] = Kernels('gauss_vel_conf', kpar);
rbf_vc = @(x,y) rbf_vc(x,y,xdot_i);
drbf_vc = @(x,y) drbf_vc(x,y,xdot_i);

%% Build matrices
gram_options = struct('norm', false,...
                      'vv_rkhs', false);

K = GramMatrix(rbf, gram_options, x_i, x_i);
K_dev = GramMatrix(drbf, gram_options, x_i, x_i);
G = ColVelMatrix(x_i, xdot_i, drbf);

%% Create Objectives & Constraints

% Define problem variable and assign initial guess
a = sdpvar(m,1);
assign(a, rand(m,1));

% Define the eigenfunction
phi = @(x) a'*rbf(x_i,x);
dphi  = @(x) sum(repmat(a,1,2).*drbf(x_i,x));
d2phi  = @(x) sum(repmat(a,1,4).*d2rbf(x_i,x));

% Lyapunov constranint
lyap = [];
for i = 1:m
   lyap = [lyap, dphi(x_i(i,:))*xdot_i(i,:)'];
end

% Lyapunov squared constraint
lyap2 = lyap.^2;

% Lyapunov constraint normalized
lyap_n = [];
for i = 1:m
   lyap_n = [lyap_n, lyap(i)/norm(dphi(x_i(i,:)))/norm(xdot_i(i,:))];
end

% Lyapunov squared constraint normalized
lyap2_n = lyap_n.^2;

% Mean squared error
mse = 0;
for i = 1:m
   mse = mse + norm(dphi(x_i(i,:)) - xdot_i(i,:))^2;
end

% Convexity constraint
convex = [];
for i = 1:m
   convex = [convex reshape(d2phi(x_i(i,:)),2,2)' <= 0]; 
end

% Define Objective
% csi = .01;
Objective = 1/m*a'*K*a;
% Objective2 = sum(phi(x_i).^2);
% Objective3 = 1/m*a'*(G*G')*a;
% Objective4 = diag(G'*(a*a')*G)./...
% diag(sum(permute(K_dev,[2,1,3]).*(repmat(a*a',1,1,2)).*K_dev,3)).*vecnorm(xdot_i,2,2).^2;

% Objective5 = 1/m*a'*(K + csi*G*G')*a;

% obj = 0;
% for i = 1:m
%    if norm(xdot_i(i,:)) ~= 0
%        obj = obj + (dphi(x_i(i,:))*xdot_i(i,:)')^2;
%    end
% end
% obj = obj/m;

% Define Constraint Convexity
% Constraints = [];
% for i = 1 : m
%   Constraints = [Constraints, reshape(d2phi(x_i(i,:)),2,2)' >= 0];
% end
Constraints = [a'*a<=1];

%% Optimization problem

% Number of eigenvectors to extract
num_eigen = 1;
% Set option and solver
options = sdpsettings('verbose',0,'solver','fmincon', 'usex0', 1);   
% Initialize eigenvalues vector and eigenvectors matrix
alphas = zeros(size(x_i,1), num_eigen);
eigens = zeros(num_eigen, 1);

tic;
for i=1:num_eigen
    sol = optimize(convex,mse,options);
    if sol.problem == 0
        % Extract and display value
        alphas(:,i) = value(a);
        % Reassign initial guess
        assign(a, rand(m,1));
        % Add orthogonality constraint wrt the found soultions
        Constraints = [Constraints, a'*alphas(:,i) == 0];
    else
        disp('Hmm, something went wrong!');
        sol.info
        yalmiperror(sol.problem)
    end
end
toc;

optimData = struct('xtrain', x_i, ...
                   'alphas', alphas, ...
                   'eigens', eigens, ...
                   'mappedData', [], ...
                   'gram', K, ...
                   'kernel', rbf_v, ...
                   'kernel_dev', drbf_v ...
                   );

%% Plot results
plot_options = struct('xlims', [0 100],...        % 1x2 vector  
                      'ylims', [0 100],...        % 1x2 vector
                      'resoultion', 'medium',...  % ['low','medium','high']
                      'type', '2D',...            % ['2D','3D']
                      'components', 1,...       % 1xn vector or scalar
                      'plot_data', true,...       % [true,false]
                      'labels', X(end,:),...      % 1xm vector 
                      'plot_stream', true,...     % [true,false]
                      'plot_eigens', false,...     % [true,false]
                      'plot_mapped', false,...     % ['2D','3D',false]
                      'plot_projData', false...   % [true,false]
                      );
PlotEigenfun(optimData, plot_options);