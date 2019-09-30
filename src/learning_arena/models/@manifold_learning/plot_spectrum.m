function fig = plot_spectrum(obj, num_eig)
% Plot spectrum
if nargin < 2; num_eig = 1:10; end
lambdas = diag(obj.eigensolve);
fig = figure;
plot(num_eig, lambdas(num_eig), '-o')
grid on
title(['Spectrum from eigenvalue ', num2str(num_eig(1)), ' to ', num2str(num_eig(end))])
end
