function [dp, n] = pgradient(obj, param, varargin)
% This function calculates the derivatives of the kernel with
% respect to the parameters.
if nargin < 2; param = obj.h_params_list_; end
if nargin > 2; obj.set_data(varargin{:}); end
obj.check;

for i = 1 : length(param)
    if ~isfield(obj.dp_, param{i})
        switch param{i}
            case 'sigma_f'
                obj.dp_.sigma_f = 2*obj.h_params_.sigma_f*obj.calc_kernel;
            case 'sigma_n'
                obj.dp_.sigma_n = 2*obj.h_params_.sigma_n*(vecnorm(obj.diff_,2,2)==0);
            otherwise
                obj.dp_.(param{i}) = obj.h_params_.sigma_f^2*obj.calc_pgradient(param{i});
        end
    end
end

dp = obj.dp_;
if nargout > 1; n = obj.num_params(param); end
end

