function x = sample(obj,num_points)
%SAMPLE Summary of this function goes here
%   Detailed explanation goes here
obj.check;

if ~obj.is_sampled_
    obj.samples_ = obj.calc_sampled(num_points);
end

if nargout > 0; x = obj.samples_; end 
end

