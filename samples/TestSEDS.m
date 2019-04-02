%% SEDS Testing Case
clear; close all; clc;
load CurrentTest.mat

process_options.center_data = true;
process_options.tol_cutting = 1.;
process_options.dt = 0.1;
[X, targets] = ProcessDemos(demo, 2, demo_struct, process_options);
Data = X(1:end-1,:);

draw_options.plot_pos = true;
draw_options.plot_vel = true;
[fig_pos, fig_vel] = DrawData(X, targets, draw_options);

K = 6; % Number of Gaussian funcitons
[Priors_0, Mu_0, Sigma_0] = initialize_SEDS(Data,K);
ml_plot_gmm_pdf(Data(1:2,:), Priors_0, Mu_0(1:2,:), Sigma_0(1:2,1:2,:))

options.tol_mat_bias = 10^-6; % Small positive scalar to avoid instabilities in Gaussian kernel
options.display = 1;          % Displays the output of each iterations
options.tol_stopping=10^-10;  % Stoppping tolerance
options.max_iter = 500;       % Maximum number of iteration for the solver [default: i_max=1000]
options.objective = 'mse';    % use mean square error as criterion to optimize parameters of GMM
[Priors, Mu, Sigma]=SEDS_Solver(Priors_0,Mu_0,Sigma_0,Data,options);

figure('name','Streamlines','position',[800   90   560   320])
[X_grid, X_d] = plotStreamLines(Priors,Mu,Sigma, [0-targets(1) 100-targets(1) 0-targets(2) 100-targets(2)]);
hold on
plot(Data(1,:),Data(2,:),'r.')
plot(0,0,'k*','markersize',15,'linewidth',3)
xlabel('$\xi_1 (mm)$','interpreter','latex','fontsize',15);
ylabel('$\xi_2 (mm)$','interpreter','latex','fontsize',15);
title('Streamlines of the model')
set(gca,'position',[0.1300    0.1444    0.7750    0.7619])

lyap_options.xlims = [0-targets(1) 100-targets(1)];
lyap_options.ylims = [0-targets(2) 100-targets(2)];
lyap_options.resolution = 'low';
lyap_options.type = '2D';
lyap_options.plot_data = true;
lyap_options.labels = X(end,:);
lyap_options.plot_stream = true;

lyapFun = @(x) x'*x/2;
lyapFun_d = @(x) x;
lyap_options.lyap_dev = lyapFun_d;

[Lyap, Lyap_d] = PlotLyap(X(1:2,:), lyapFun, lyap_options);