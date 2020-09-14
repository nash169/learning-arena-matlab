function f = calc_field(obj, x)
    %CALC_FIELD Summary of this function goes here
    %   Detailed explanation goes here

    f = zeros(size(x, 1), obj.d_);
    f(:, 1) = x(:, 2);
    f(:, 2) = obj.params_.alpha * (obj.params_.beta * x(:, 1) - x(:, 1).^3 - x(:, 2));
end
