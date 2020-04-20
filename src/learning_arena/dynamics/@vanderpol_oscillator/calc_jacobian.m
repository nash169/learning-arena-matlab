function J = calc_jacobian(obj, x)
    %CALC_FIELD Summary of this function goes here
    %   Detailed explanation goes here
    num_points = size(x, 1);

    J = zeros(size(x, 1), 2 * obj.d_);
    J(:, 2) = ones(num_points, 1);
    J(:, 3) = -2 * obj.params_.alpha * x(:, 1) .* x(:, 2) - obj.params_.omega^2;
    J(:, 4) = -obj.params_.alpha * (x(:, 1).^2 + obj.params_.k);

    J = c_reshape(J, [], obj.d_);
end
