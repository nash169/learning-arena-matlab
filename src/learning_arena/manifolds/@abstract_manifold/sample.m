function x = sample(obj, num_points)
    %SAMPLE Summary of this function goes here
    %   Detailed explanation goes here
    if nargin < 2

        if ~obj.is_sampled_
            num_points = 1000;
            obj.samples_ = obj.calc_sampled(num_points);
            obj.is_sampled_ = true;
        end

    else
        obj.samples_ = obj.calc_sampled(num_points);
        obj.is_sampled_ = true;
    end

    if nargout > 0; x = obj.samples_; end
end
