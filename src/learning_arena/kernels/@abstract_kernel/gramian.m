function K = gramian(obj, varargin)
    % This function return the gramian evaluation. You can pass the data
    % directly here if you want.
    if ~obj.is_gramian_
        obj.K_ = reshape(obj.kernel(varargin{:}), obj.m_, obj.n_);
    end

    K = obj.K_;
end
