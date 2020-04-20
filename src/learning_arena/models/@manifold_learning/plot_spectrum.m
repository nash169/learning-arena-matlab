function fig = plot_spectrum(obj, num_eig, fig)
    % Plot spectrum
    if nargin < 2; num_eig = 1:10; end
    if nargin < 3; fig = figure; else; figure(fig); end

    lambdas = diag(obj.eigensolve);

    plot(num_eig, lambdas(num_eig), '-o')
    grid on
    title(['Spectrum from eigenvalue ', num2str(num_eig(1)), ' to ', num2str(num_eig(end))])
end
