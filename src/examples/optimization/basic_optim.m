function [sol, lambda] = basic_optim(plot)
    if nargin < 1; plot = false; end

    % Example of basic constraint optimization
    f = @(x) obj(x);
    c1 = @(x) cstr1(x);
    c2 = @(x) cstr2(x);

    options_optim = optimoptions('fmincon', ...
        'SpecifyObjectiveGradient', true, ...
        'SpecifyConstraintGradient', true);

    x0 = rand(2, 1);
    [sol, ~, ~, ~, lambda] = fmincon(@(x) combine_objectives(x, f), x0, [], [], [], [], [], [], ...
        @(x) combine_constraints(x, c1, c2), options_optim);

    if plot
        % Plot functional
        res = 60;
        [x, y] = meshgrid(linspace(-3, 3, res), linspace(-3, 3, res));
        X = [x(:), y(:)];
        f_test = (X(:, 1) - 2).^2 + 2 * (X(:, 2) - 1).^2;
        c1_test = X(:, 1) + 4 * X(:, 2) - 3;
        c2_test = X(:, 2) - X(:, 1);

        figure (1)
        surfc(x, y, reshape(f_test, res, res))
        hold on
        surfc(x, y, reshape(c1_test, res, res), 'FaceAlpha', 0.5)
        surfc(x, y, reshape(c2_test, res, res), 'FaceAlpha', 0.5)
        axis square

        figure (2)
        contour(x, y, reshape(f_test, res, res));
        hold on
        contour(x, y, reshape(c1_test, res, res));
        contour(x, y, reshape(c2_test, res, res));
        contour(x, y, reshape(f_test, res, res), [f(sol) f(sol)], 'LineWidth', 2)
        contour(x, y, reshape(c1_test, res, res), [c1(sol) c1(sol)], 'r', 'LineWidth', 2)
        contour(x, y, reshape(c2_test, res, res), [c2(sol) c2(sol)], 'LineWidth', 2)
        scatter(sol(1), sol(2), 'r', 'filled')
        axis square
    end

end

% FUNCTIONAL
function [f, g] = obj(x)
    f = (x(1) - 2)^2 + 2 * (x(2) - 1)^2;

    if nargout > 1
        g = [2 * (x(1) - 2); 4 * (x(2) - 1)];
    end

end

% CONSTRAINT 1
function [c, ceq, DC, DCeq] = cstr1(x)
    c = x(1) + 4 * x(2) - 3;
    ceq = [];

    if nargout > 2
        DC = [1; 4];
        DCeq = [];
    end

end

% CONSTRAINT 2
function [c, ceq, DC, DCeq] = cstr2(x)
    c = x(2) - x(1);
    ceq = [];

    if nargout > 2
        DC = [-1; 1];
        DCeq = [];
    end

end
