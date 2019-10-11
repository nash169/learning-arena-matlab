function S = sample(obj, x0, T, dt)
%SAMPLE Summary of this function goes here
%   Detailed explanation goes here

obj.check;
x = zeros(T/dt,length(x0));
x_dot = x;

x(1,:) = x0;
x_dot(1,:) = obj.calc_field(x0);

for i = 2:T/dt+1
    x(i,:) = x(i-1,:) + dt*x_dot(i-1,:);
    x_dot(i,:) = obj.calc_field(x(i,:));
end

obj.samples_ = [x, x_dot];
obj.is_sampled_ = true;

if nargout > 0; S = obj.samples_; end 
end
