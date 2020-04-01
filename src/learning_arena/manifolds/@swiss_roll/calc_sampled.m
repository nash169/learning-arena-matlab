function x = calc_sampled(obj, num_points)
%CALC_SAMPLED Summary of this function goes here
%   Detailed explanation goes here
A = obj.params_.width * (pi*sqrt(1+4*pi^2) + log(sqrt(1+4*pi^2) + 2*pi)/2);

theta = sqrt(A^2*rand(num_points, 1).^2-1);
linear = rand(num_points, 1); %*obj.params_.width;

x = obj.embedding([theta,linear]);

end

