clear; close all; clc;

%% Load demos
load 2attracts_simple.mat;
demo = DataStruct.demo;
demo_struct = DataStruct.demo_struct;
% demo = ReducedData(demo, 5);

%% Process data
proc_options = struct('center_data', false,...
                      'tol_cutting', 1.,...
                      'dt', 0.1...
                      );
[X, targets] = ProcessDemos(demo, 2, demo_struct, proc_options);
x_i = X(1:2,:)';
xdot_i = X(3:4,:)';
[m,~] = size(x_i);
% Centering data, as expected, does not effect the result. Although scaling
% data might speed up the algorithm. Consider: x_i = MeanScale(x_i,'scale')

%% Draw data
draw_options = struct('plot_pos', true,...  % Draw the demonstrated positions
                      'plot_vel', false...  % Draw the demonstrated velocities
                      );
% fig_pos = DrawData(X, targets, draw_options);

%% Build kernels
kpar = struct('sigma', 5.,...
              'r', 3*5,...
              'sigma_vel', 0.01,...
              'sigma_attract', 1,...
              'lambda', 30,... *1/3
              'degree', 1.,...
              'const', 1.);
[rbf, drbf] = Kernels('gauss', kpar);
[rbf_c, drbf_c] = Kernels('gauss_compact', kpar);
cosine = Kernels('cosine');

[rbf_v, drbf_v] = Kernels('gauss_vel', kpar);
rbf_v = @(x,y) rbf_v(x,y,xdot_i);
drbf_v = @(x,y) drbf_v(x,y,xdot_i);

[rbf_vc, drbf_vc] = Kernels('gauss_vel_conf', kpar);
rbf_vc = @(x,y) rbf_vc(x,y,xdot_i);
drbf_vc = @(x,y) drbf_vc(x,y,xdot_i);


%% Build Graph
graph_options = struct('conntype','n-neighbors', ... % 'n-neighbors'
                       'epsilon', 5.3, ... 
                       'num_nb', 6, ...
                       'plot_graph', false ...
                       );
W = GraphBuild(x_i, graph_options);

%% Build matrices
gram_options = struct('norm', true,...
                      'vv_rkhs', false);

K = GramMatrix(rbf, gram_options, x_i, x_i);
K_dev = GramMatrix(drbf, gram_options, x_i, x_i);
G = ColVelMatrix(x_i, xdot_i, drbf);
S = K.*W;
D = diag(sum(S));
L = D-S;

%% Optimization problem

% Number of eigenvectors to extract
num_eigen = 1;

% Initial conditions
alpha0 = rand(m,1);

% Paramters for the optimization problem
f1 = OptimObjectives('kpca', K);
f2 = OptimObjectives('G-kpca', K);
f3 = OptimObjectives('max_coll_lyap', G, 1);

% Eigenvectors constraint for kPCA Optimization problem 1
c1 = OptimConstraints('l2Ball');
c2 = OptimConstraints('K-l2Ball', K);
%%%%%%%
c3 = OptimConstraints('lyap',G); 
c4 = OptimConstraints('lyap-sqsum',G);
%%%%%%%
c5 = OptimConstraints('neg-sum');
c6 = OptimConstraints('pos-orthant');

% Optimization options
options_optim = optimoptions('fmincon',...
                             'SpecifyObjectiveGradient',true,...
                             'SpecifyConstraintGradient',true,...
                             'MaxFunctionEvaluations',1e6);
                             
% Initialize eigenvalues vector and eigenvectors matrix
alphas = zeros(m, num_eigen);
eigens = zeros(num_eigen, 1);

tic;
for i=1:num_eigen
    ortho = OptimConstraints('ortho', alphas(:,1:end-1));
    [alpha,~,~,~,lambdas] = fmincon(@(x) Objective(x, f1),alpha0,[],[],[],[],[],[],...
                                    @(x) Constraint(x, c1, ortho), options_optim);
    alphas(:,i) = alpha;
    eigens(i) = lambdas.ineqnonlin(1);
end
toc;

% Storing Results
optimData = struct('xtrain', x_i, ...
                   'alphas', alphas, ...
                   'eigens', eigens, ...
                   'mappedData', [], ...
                   'gram', K, ...
                   'kernel', rbf, ...
                   'kernel_dev', drbf ...
                   );

%% Plot results
plot_options = struct('xlims', [0 100],...        % 1x2 vector  
                      'ylims', [0 100],...        % 1x2 vector
                      'resoultion', 'medium',...  % ['low','medium','high']
                      'type', '3D',...            % ['2D','3D']
                      'components', 1,...         % 1xn vector or scalar
                      'plot_data', true,...       % [true,false]
                      'labels', X(end,:),...      % 1xm vector 
                      'plot_stream', false,...    % [true,false]
                      'plot_eigens', false,...    % [true,false]
                      'plot_mapped', false,...    % ['2D','3D',false]
                      'plot_projData', false...   % [true,false]
                      );
PlotEigenfun(optimData, plot_options);