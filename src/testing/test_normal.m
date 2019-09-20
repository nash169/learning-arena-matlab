clear; close all; clc;
length = 5.;
U =  gs_orthogonalize([1,1]);
D = [length^2, 0; 0 length^2/2];
sigma = U'*D*U;
mean = [50, 50];

my_gauss = gauss_normal('mean', mean, 'sigma', sigma);
my_gauss.set_grid(100, 0, 100, 0, 100);

ops_fig = struct( ...
    'res', 100, ...
    'grid', [0 100; 0 100], ...
    'plot_stream', true ...
    );

my_gauss.plot;
my_gauss.contour(ops_fig);

mypdf = pdf_normal('mean', mean, 'std', sigma);
mypdf.plot;
mypdf.contour(ops_fig);