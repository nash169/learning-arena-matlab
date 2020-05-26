function f = calc_field(obj, x)
    %CALC_FIELD Summary of this function goes here
    %   Detailed explanation goes here
    f = zeros(size(x, 1), obj.d_);

    f(:, 1) = obj.params_.sigma() * (x(:, 2) - x(:, 1));
    f(:, 2) = x(:, 1) * (obj.params_.rho() - x(:, 3)) - x(:, 2);
    f(:, 3) = x(:, 1) * x(:, 2) - obj.params_.beta() * x(:, 3);
end
