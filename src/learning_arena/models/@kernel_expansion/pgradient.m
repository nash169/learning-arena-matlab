function [dp, n] = pgradient(obj, param, data)
% Get the derivative with respect to the hyper-parameters
obj.check;
if nargin < 2; param = obj.h_params_list_; end
if nargin > 2; obj.set_data(data); end
obj.input;

for i = 1 : length(param)
    if ~isfield(obj.dp_, param{i})
        switch param{i}
            case 'alpha'
                obj.dp_.alpha = obj.h_params_.kernel.gramian;
            case 'kernel'
                obj.dp_.kernel = obj.h_params_.kernel.pgradient; % Weights missing
            otherwise
                obj.dp_.(param{i}) = obj.calc_pgradient(param{i});
        end
    end
end

dp = obj.dp_;

if nargout > 1; n = obj.num_params(param); end
end

